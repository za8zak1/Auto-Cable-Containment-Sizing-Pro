import 'package:auto_cable_sizing_pro/providers/database_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled cable database asset loads and parses', () async {
    final provider = DatabaseProvider();

    await provider.load();

    expect(provider.error, isNull, reason: provider.error);
    expect(provider.isLoaded, isTrue);
    expect(provider.recordCount, greaterThan(0));
    expect(provider.families, isNotEmpty);
    expect(provider.materials, isNotEmpty);
  });
}
