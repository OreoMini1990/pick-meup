import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:photo_pick_dating_new/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: PhotoPickDatingApp(),
      ),
    );

    // Verify that the app starts
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
