import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/analysis_result.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/fraud_service.dart';

void main() {
  setUp(() {
    AuthService().resetDemo();
  });

  testWidgets('Munda Fraud Shield PIN login test transitions to HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MundaFraudShieldApp());

    // Verify PIN entry screen is displayed
    expect(find.textContaining('Enter your 4-digit Security PIN'), findsOneWidget);

    // Enter digits 1, 2, 3, 4
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify user is transitioned to HomeScreen
    expect(find.text('AI Shield & Threat Monitor'), findsOneWidget);
    expect(find.text('99.4% Protected'), findsOneWidget);
  });

  testWidgets('Registration screen displays mobile money PIN warning', (WidgetTester tester) async {
    AuthService().resetToNewUser();
    await tester.pumpWidget(const MundaFraudShieldApp());

    // Verify Register screen renders with the inline mobile money PIN warning
    expect(find.textContaining('Create Shield Account'), findsOneWidget);
    expect(find.textContaining('Do not use your Airtel Money, MTN MoMo, or bank PIN'), findsOneWidget);
  });

  test('FraudService analyzes SMS message and produces verified assessment', () async {
    final result = await FraudService.analyzeMessage(
      message: 'ZANACO-AUTH: OTP 849201 for K1,200 payment. Read out code to agent.',
      demoMode: true,
    );

    expect(result.success, isTrue);
    expect(result.riskBand, RiskBand.high);
    expect(result.riskScore, greaterThanOrEqualTo(70));
    expect(result.reasons, isNotEmpty);
    expect(result.recommendedActions, isNotEmpty);
    expect(result.disclaimer, contains('Low Concern'));
  });

  test('FraudService accurately categorizes legitimate financial receipt', () async {
    final result = await FraudService.analyzeMessage(
      message: 'ZanacoBank: Debit K 350.00 at Shoprite. Ref: TXN981240. New bal: K 2,450.50. Never share your PIN.',
      demoMode: true,
    );

    expect(result.success, isTrue);
    expect(result.riskBand, RiskBand.low);
    expect(result.riskScore, lessThan(35));
    expect(result.disclaimer, contains('Low Concern'));
  });
}
