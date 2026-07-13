import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/cable_record.dart';

/// Loads and holds the in-memory cable database.
///
/// The bundled asset (`assets/data/cable_database_sample.json`) is a
/// clearly-labelled PLACEHOLDER dataset used only to demonstrate the app's
/// architecture and UI. Swap it out for your verified engineering database
/// (same JSON shape - see `CableRecord.fromJson`) before using this app for
/// real design work. You can also wire this class up to read a CSV/JSON
/// file picked at runtime instead of a bundled asset.
class CableDatabase {
  CableDatabase._();
  static final CableDatabase instance = CableDatabase._();

  List<CableRecord> _records = [];
  String _sourceVersion = 'unloaded';
  String _disclaimer = '';
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<CableRecord> get records => List.unmodifiable(_records);
  String get sourceVersion => _sourceVersion;
  String get disclaimer => _disclaimer;

  Future<void> load({
    String assetPath = 'assets/data/cable_database_sample.json',
  }) async {
    final raw = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
    final meta = decoded['meta'] as Map<String, dynamic>?;
    _sourceVersion = meta?['version']?.toString() ?? 'unknown';
    _disclaimer = meta?['disclaimer']?.toString() ?? '';
    final list = (decoded['records'] as List).cast<Map<String, dynamic>>();
    _records = list.map(CableRecord.fromJson).toList();
    _loaded = true;
  }

  /// Loads records from an already-decoded JSON string (e.g. a file picked
  /// by the user at runtime to replace the bundled sample database).
  void loadFromJsonString(String raw) {
    final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
    final meta = decoded['meta'] as Map<String, dynamic>?;
    _sourceVersion = meta?['version']?.toString() ?? 'custom-import';
    _disclaimer = meta?['disclaimer']?.toString() ?? '';
    final list = (decoded['records'] as List).cast<Map<String, dynamic>>();
    _records = list.map(CableRecord.fromJson).toList();
    _loaded = true;
  }

  List<String> get families =>
      _records.map((e) => e.family).toSet().toList()..sort();

  List<String> get materials =>
      _records.map((e) => e.material).toSet().toList()..sort();

  List<String> get brandGroups =>
      _records.map((e) => e.brandGroup).toSet().toList()..sort();

  int countByFamily(String family) =>
      _records.where((e) => e.family == family).length;

  int countByMaterial(String material) =>
      _records.where((e) => e.material == material).length;
}
