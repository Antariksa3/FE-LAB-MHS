import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_import/main.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const GenshinImportApp());
    expect(find.byType(GenshinImportApp), findsOneWidget);
  });
}
