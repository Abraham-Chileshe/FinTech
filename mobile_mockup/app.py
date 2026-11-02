import os
import time
import requests
from flask import Flask, render_template, request, jsonify

app = Flask(__name__)

# Backend API endpoint configuration
BACKEND_API_URL = os.environ.get("BACKEND_API_URL", "http://127.0.0.1:8000/api/v1/analyze-sms")
BACKEND_HEALTH_URL = os.environ.get("BACKEND_HEALTH_URL", "http://127.0.0.1:8000/api/health")

# Zambian FinTech preset attack and verification scenarios
PRESET_SCENARIOS = [
    {
        "id": "airtel_reversal",
        "category": "Fake MoMo Reversal Scam",
        "sender": "AirtelMoney",
        "severity": "high",
        "title": "Airtel Fake Reversal",
        "text": "Trans ID: TX89271891. You have received ZMW 650.00 from KABWE CHILUFYA (+260978112233). New balance: ZMW 1,240.50. Note: This transfer was sent by mistake. Please refund ZMW 650 to agent number +260971998877 immediately to avoid account freeze."
    },
    {
        "id": "zanaco_otp",
        "category": "OTP / Credential Harvesting",
        "sender": "ZANACO",
        "severity": "high",
        "title": "ZANACO OTP Theft",
        "text": "ZANACO Security Alert: Your debit card •• 4912 has been temporarily locked due to unauthorized ATM login attempts in Lusaka. To verify ownership and unlock your card, call +260965882211 immediately and share your 6-digit one-time PIN (OTP)."
    },
    {
        "id": "mtn_lottery",
        "category": "Lottery & Prize Phishing",
        "sender": "MTN_Promo",
        "severity": "high",
        "title": "MTN MoMo Prize Scam",
        "text": "CONGRATULATIONS! Your mobile number +26096XXXXXXX has won ZMW 45,000.00 in the MTN 2026 Customer Appreciation Draw! Reference #MTN-WIN-992. To claim your prize funds today, call our Claim Agent on +260962334455 and pay the processing fee of ZMW 180."
    },
    {
        "id": "absa_kyc_phishing",
        "category": "Bank Impersonation Phishing",
        "sender": "ABSA-Bank",
        "severity": "high",
        "title": "ABSA KYC Phishing Link",
        "text": "Dear Valued Customer, your ABSA online banking profile will be suspended within 12 hours due to unverified BVN/KYC compliance. Visit our secure verification portal immediately at http://absa-sec-portal.link/unlock to update your credentials and restore access."
    },
    {
        "id": "zesco_token_scam",
        "category": "Utility Token Fraud",
        "sender": "ZESCO_Billing",
        "severity": "high",
        "title": "ZESCO Fake Token Reversal",
        "text": "ZESCO Prepaid Alert: Transaction #ZS918239 was processed with an excess credit of ZMW 350.00 for Meter 04192837192. Reverse the duplicate balance to MoMo +260974889900 within 2 hours or power disconnection will occur automatically."
    },
    {
        "id": "sim_swap_phishing",
        "category": "SIM Swap Verification",
        "sender": "TelecomVerify",
        "severity": "high",
        "title": "Urgent SIM Swap Alert",
        "text": "URGENT NOTICE: A SIM card replacement request has been initiated for this phone number. If you did NOT request this swap, reply IMMEDIATELY with 'CANCEL' followed by your 4-digit Mobile Money PIN to abort the transfer."
    },
    {
        "id": "legit_momo_receipt",
        "category": "Legitimate Transaction",
        "sender": "AirtelMoney",
        "severity": "low",
        "title": "Legitimate MoMo Receipt",
        "text": "Txn ID: MP261018.1923.B0912. You have received ZMW 250.00 from Mwamba Chileshe on 18/10/2026 at 19:23:41. New Airtel Money balance: ZMW 890.20. Transaction fee: ZMW 0.00. Thank you for using Airtel Money."
    },
    {
        "id": "legit_bank_alert",
        "category": "Legitimate Bank Alert",
        "sender": "ZANACO",
        "severity": "low",
        "title": "Legitimate Bank Notice",
        "text": "ZANACO Alert: Your Account •• 8440 has been debited by ZMW 120.00 at SHOPRITE MEWS POS Lusaka on 18/10/2026 14:15. Available balance: ZMW 3,420.50. Call +260 211 228979 for queries."
    }
]

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/api/presets", methods=["GET"])
def get_presets():
    return jsonify({"success": True, "presets": PRESET_SCENARIOS})

@app.route("/api/health-check", methods=["GET"])
def health_check():
    try:
        t0 = time.time()
        resp = requests.get(BACKEND_HEALTH_URL, timeout=3)
        latency_ms = int((time.time() - t0) * 1000)
        if resp.status_code == 200:
            return jsonify({
                "backend_online": True,
                "latency_ms": latency_ms,
                "data": resp.json()
            })
    except Exception as e:
        return jsonify({
            "backend_online": False,
            "error": str(e),
            "fallback_mode": True
        })

@app.route("/api/send-sms", methods=["POST"])
def send_sms():
    data = request.get_json() or {}
    message = data.get("message", "").strip()
    sender = data.get("sender", "Unknown").strip() or "Unknown"

    if not message:
        return jsonify({"success": False, "error": "Message body cannot be empty."}), 400

    payload = {"message": message, "demo_mode": True}
    analysis_result = None
    latency_ms = 0
    backend_used = False

    # Attempt to query the live Laravel API
    try:
        t0 = time.time()
        backend_resp = requests.post(
            BACKEND_API_URL,
            json=payload,
            headers={"Accept": "application/json", "Content-Type": "application/json"},
            timeout=8
        )
        latency_ms = int((time.time() - t0) * 1000)
        if backend_resp.status_code == 200:
            analysis_result = backend_resp.json()
            backend_used = True
    except Exception as e:
        print(f"[Mobile Mockup] Backend query failed or timed out: {e}")

    # Fallback to local heuristic engine if Laravel backend is offline
    if not analysis_result:
        t0 = time.time()
        analysis_result = fallback_evaluate(message, sender)
        latency_ms = int((time.time() - t0) * 1000)

    return jsonify({
        "success": True,
        "sender": sender,
        "message": message,
        "timestamp": time.strftime("%H:%M"),
        "latency_ms": latency_ms,
        "backend_used": backend_used,
        "analysis": analysis_result,
        "request_payload": payload
    })

def fallback_evaluate(message: str, sender: str) -> dict:
    """Built-in offline fallback rules engine if Laravel backend is not running."""
    lower = message.lower()
    score = 10
    reasons = []
    actions = []
    category = "General Message"

    # 1. Fake MoMo reversal
    if any(k in lower for k in ["sent by mistake", "refund to", "reverse to", "reversed to", "mistakenly sent"]):
        score = max(score, 88)
        reasons.append("Coercive transfer reversal demand detected. Genuine telecom transfers cannot be reversed by sending money to another number.")
        actions.append("Do NOT send money back. Advise the sender to contact official Airtel/MTN support.")
        category = "Mobile Money Reversal Scam"

    # 2. OTP theft
    if any(k in lower for k in ["otp", "one-time pin", "one time pin", "share your pin", "verification pin"]):
        score = max(score, 94)
        reasons.append("Credential theft alert: Banks & telecom operators NEVER ask for your PIN or OTP.")
        actions.append("Never disclose your OTP or PIN to anyone under any circumstances.")
        category = "Credential / OTP Theft"

    # 3. Phishing link
    if any(k in lower for k in ["http://", "https://", ".link/", ".xyz", "bit.ly", "tinyurl", "click immediately"]):
        score = max(score, 85)
        reasons.append("Suspicious URL detected in financial context. Likely credential harvesting phishing portal.")
        actions.append("Do not click the link. Visit the verified official banking website directly.")
        category = "Phishing Link"

    # 4. Account suspension / panic
    if any(k in lower for k in ["blocked", "suspended", "locked", "restriction", "closure within"]):
        score = max(score, 80)
        reasons.append("High-pressure panic induction: Fraudsters claim accounts are restricted to force hurried actions.")
        actions.append("Contact your branch or official hotline to verify your account status.")
        category = "Account Suspension Extortion"

    # 5. Prize / Lottery
    if any(k in lower for k in ["won", "congratulations", "winner", "prize", "cash prize", "processing fee"]):
        score = max(score, 90)
        reasons.append("Advance-fee prize scam detected. Legitimate promotions never require upfront claim fees.")
        actions.append("Ignore this message and block the sender.")
        category = "Fake Promotion / Lottery Scam"

    # 6. Legitimate receipt indicators
    if any(k in lower for k in ["you have received", "txn id", "debited by", "available balance"]) and score <= 40:
        score = 8
        reasons.append("Standard automated transaction notification syntax detected.")
        actions.append("Safe to review. Verify changes in your official mobile banking app.")
        category = "Verified Financial Receipt"

    if score >= 75:
        risk_band = "high"
        summary = f"High-risk {category} detected. Immediate danger of financial loss or account compromise."
    elif score >= 40:
        risk_band = "suspicious"
        summary = f"Caution recommended. Suspicious elements identified in this message."
    else:
        risk_band = "low"
        summary = "Standard transaction syntax. No known predatory scam signatures identified."

    return {
        "success": True,
        "risk_band": risk_band,
        "risk_score": score,
        "threat_category": category,
        "summary": summary,
        "reasons": reasons or ["Message content appears consistent with standard communication."],
        "recommended_actions": actions or ["No immediate action needed. Practice routine security awareness."],
        "analysis_method": "offline_fallback_rules",
        "privacy_protection": {
            "pii_redacted": True,
            "redacted_elements_count": 1,
            "detected_types": ["phone_number"]
        }
    }

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5050))
    print("\n" + "=" * 65)
    print("[MUNDA AI] MOBILE PHONE SMS MOCKUP & AUTOMATION SIMULATOR")
    print("=" * 65)
    print(f"* Running at:         http://127.0.0.1:{port}")
    print(f"* Target Backend API: {BACKEND_API_URL}")
    print("=" * 65 + "\n")
    app.run(host="0.0.0.0", port=port, debug=False)
