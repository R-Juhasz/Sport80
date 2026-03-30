import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport80/screens/onboarding_screen.dart';
import 'package:sport80/theme/app_theme.dart';

void main() {
  testWidgets('Onboarding renders primary setup CTA', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const OnboardingScreen(),
        ),
      ),
    );

    expect(find.text('Finish setting up Sport 80.'), findsOneWidget);
    expect(find.text('Start Sport 80'), findsOneWidget);
  });
}
