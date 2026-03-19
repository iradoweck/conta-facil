import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conta_facil/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Splash screen shows app name', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ContaFacilApp()));

    // Verify that the splash screen text is present.
    expect(find.text('Conta Fácil'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
  });
}
