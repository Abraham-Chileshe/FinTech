# 📱 Munda AI — Mobile Phone SMS Mockup & Fraud Test Harness

A standalone visual mobile device simulator and automated SMS threat injection console for **Munda AI Fraud Shield**.

This tool simulates a realistic smartphone with dynamic notch animations, incoming SMS notifications, sound alerts, and live Munda AI threat interception HUDs, connected directly to the Laravel backend API (`POST /api/v1/analyze-sms`).

---

## 🌟 Features

### 1. 📱 Realistic Mobile Phone Device (iPhone Mockup)
- **Dynamic Island & Status Bar**: Responsive camera notch and top status bar (5G, battery, clock).
- **Incoming Push Banner**: Animates down from the top on SMS delivery with audio chime.
- **Munda AI Threat Interception HUD**:
  - Automatically activates when the backend classifies an incoming message as `HIGH_RISK` or `SUSPICIOUS`.
  - Shows animated risk score meter (e.g. `94% Risk`), detected indicators, and summary.
  - Interactive "Block Sender & Isolate Message" action button.
- **Messages App Conversation Thread**: Displays incoming chat bubbles with verified security badges.

### 2. 🎛️ Automation & Testing Console (Outside Device)
- **Mockup Textarea**: Free-form text input to write, edit, or paste arbitrary SMS text.
- **Custom Sender Identifier**: Easily switch between sender IDs (`AirtelMoney`, `MTN_MoMo`, `ZANACO`, `ABSA-Alerts`, `ZRA_Tax`, or phone numbers).
- **One-Click Attack Presets**: Curated Zambian FinTech scenarios:
  - ⚠️ Airtel Fake MoMo Reversal
  - 🚨 ZANACO OTP Theft
  - 🛑 MTN Prize Scam
  - 🏦 ABSA Account KYC Phishing Link
  - ⚡ ZESCO Fake Token Reversal
  - 📱 SIM Swap Verification Trap
  - ✅ Legitimate MoMo Cash Received Receipt
  - ✅ Legitimate Bank ATM Debit Alert
- **Automated Continuous Stream Mode**: Toggle switch to auto-inject realistic messages every 8 seconds for hands-free automation testing.
- **Live API Telemetry & Payload Inspector**: Real-time display of response latency, PII scrubbing verification, and formatted JSON output.

---

## 🚀 Quick Start

### 1. Prerequisites
- Python 3.8+ (with `flask` and `requests`)
- Laravel backend running at `http://127.0.0.1:8000` (`php artisan serve`)

### 2. Launch the Simulator
Run the Python application:

```bash
cd mobile_mockup
python app.py
```

Or on Windows, simply double-click `run_simulator.bat`.

### 3. Open in Browser
Visit **`http://127.0.0.1:5050`** in your browser.

---

## 📡 Backend API Integration
- **Target Endpoint**: `http://127.0.0.1:8000/api/v1/analyze-sms`
- **Fallback Mode**: If the Laravel backend is temporarily stopped, the simulator automatically falls back to its built-in local heuristics engine so testing can continue uninterrupted.
