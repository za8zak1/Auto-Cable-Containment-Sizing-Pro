import 'package:flutter/material.dart';
import '../data/cable_database.dart';
import '../models/cable_record.dart';

class DatabaseProvider extends ChangeNotifier {
  final CableDatabase _db;

  List<CableRecord> _records = const [];
  String _sourceVersion = 'unloaded';
  String _disclaimer = '';
  bool _loading = false;
  bool _loaded = false;
  String? _error;

  DatabaseProvider({CableDatabase? database})
      : _db = database ?? CableDatabase.instance;

  /// Creates a fully loaded provider without reading an asset.
  ///
  /// This is intended for deterministic widget tests and previews. Production
  /// code continues to use [DatabaseProvider] and [load].
  DatabaseProvider.seeded(
    List<CableRecord> records, {
    String sourceVersion = 'seeded-test-data',
    String disclaimer = 'In-memory test data.',
  })  : _db = CableDatabase.instance,
        _records = List<CableRecord>.unmodifiable(records),
        _sourceVersion = sourceVersion,
        _disclaimer = disclaimer,
        _loaded = true;

  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoaded => _loaded;

  List<CableRecord> get records => _records;
  String get sourceVersion => _sourceVersion;
  String get disclaimer => _disclaimer;

  int get recordCount => _records.length;

  List<String> get families =>
      _records.map((e) => e.family).toSet().toList()..sort();

  List<String> get materials =>
      _records.map((e) => e.material).toSet().toList()..sort();

  List<String> get brandGroups =>
      _records.map((e) => e.brandGroup).toSet().toList()..sort();

  /// Distinct protection-device ratings referenced by the loaded database,
  /// used for the dashboard's "Protection ratings" statistic.
  int get protectionRatingCount => _records
      .map((e) => '${e.protectionClass}-${e.cccAmps.round()}')
      .toSet()
      .length;

  Future<void> load() async {
    if (_loaded || _loading) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _db.load();
      _records = List<CableRecord>.unmodifiable(_db.records);
      _sourceVersion = _db.sourceVersion;
      _disclaimer = _db.disclaimer;
      _loaded = true;
    } catch (error, stackTrace) {
      _error = '$error';
      _loaded = false;
      debugPrint('Cable database load failed: $error\n$stackTrace');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  int countByFamily(String family) =>
      _records.where((e) => e.family == family).length;

  int countByMaterial(String material) =>
      _records.where((e) => e.material == material).length;

  double familyPercent(String family) =>
      recordCount == 0 ? 0 : (countByFamily(family) / recordCount) * 100;

  double materialPercent(String material) =>
      recordCount == 0 ? 0 : (countByMaterial(material) / recordCount) * 100;
}
