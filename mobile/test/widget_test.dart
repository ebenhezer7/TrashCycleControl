import 'package:flutter_test/flutter_test.dart';
import 'package:trashcycle_control/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: true));
    expect(find.byType(MyApp), findsOneWidget);
  });
}
