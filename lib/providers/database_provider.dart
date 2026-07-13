import 'package:flutter/material.dart';
import '../data/cable_database.dart';
import '../models/cable_record.dart';

class DatabaseProvider extends ChangeNotifier {
  final CableDatabase _db = CableDatabase.instance;

  bool _loading = false;
  String? _error;

  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoaded => _db.isLoaded;

  List<CableRecord> get records => _db.records;
  String get sourceVersion => _db.sourceVersion;
  String get disclaimer => _db.disclaimer;

  int get recordCount => _db.records.length;
  List<String> get families => _db.families;
  List<String> get materials => _db.materials;
  List<String> get brandGroups => _db.brandGroups;

  /// Distinct protection-device ratings referenced by the loaded database,
  /// used for the dashboard's "Protection ratings" stat.
  int get protectionRatingCount => _db.records
      .map((e) => '${e.protectionClass}-${e.cccAmps.round()}')
      .toSet()
      .length;

  Future<void> load() async {
    if (_db.isLoaded) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _db.load();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  int countByFamily(String family) => _db.countByFamily(family);
  int countByMaterial(String material) => _db.countByMaterial(material);

  double familyPercent(String family) =>
      recordCount == 0 ? 0 : (countByFamily(family) / recordCount) * 100;

  double materialPercent(String material) =>
      recordCount == 0 ? 0 : (countByMaterial(material) / recordCount) * 100;
}
