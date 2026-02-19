import 'package:flutter_test/flutter_test.dart';
import 'package:doktorapp/main.dart';

void main() {
  testWidgets('DoktorApp starts', (WidgetTester tester) async {
    await tester.pumpWidget(const DoktorApp());
    // App should build without errors
  });
}
