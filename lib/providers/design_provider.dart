import 'package:flutter/material.dart';
import '../models/cable_record.dart';
import '../models/sizing_models.dart';
import '../services/cable_sizing_service.dart';

class DesignProvider extends ChangeNotifier {
  final CableSizingService _service = const CableSizingService();

  SizingInput input = const SizingInput();

  String? materialFilter;
  String? familyFilter = 'XLPE/PVC';
  String? constructionFilter;

  /// Manual overwrite: when set, this candidate is shown as the active
  /// recommendation instead of the auto-computed top candidate.
  CandidateResult? manualSelection;

  List<CandidateResult> _rankedCache = [];
  List<CableRecord> _lastPool = const [];

  List<CandidateResult> get ranked => _rankedCache;

  CandidateResult? get activeResult {
    if (manualSelection != null) return manualSelection;
    if (_rankedCache.isEmpty) return null;
    final firstPass = _rankedCache.where((r) => r.overallPass);
    return firstPass.isNotEmpty ? firstPass.first : null;
  }

  bool get hasNoCable => activeResult == null;

  void updateInput(SizingInput Function(SizingInput) updater) {
    input = updater(input);
    manualSelection = null;
    recompute(_lastPool);
  }

  void setMaterialFilter(String? v) {
    materialFilter = v;
    manualSelection = null;
    recompute(_lastPool);
  }

  void setFamilyFilter(String? v) {
    familyFilter = v;
    manualSelection = null;
    recompute(_lastPool);
  }

  void setConstructionFilter(String? v) {
    constructionFilter = v;
    manualSelection = null;
    recompute(_lastPool);
  }

  void selectManually(CandidateResult r) {
    manualSelection = r;
    notifyListeners();
  }

  void clearManualSelection() {
    manualSelection = null;
    notifyListeners();
  }

  void recompute(List<CableRecord> pool) {
    _lastPool = pool;
    _rankedCache = _service.rankCandidates(
      input: input,
      pool: pool,
      materialFilter: materialFilter,
      familyFilter: familyFilter,
      constructionFilter: constructionFilter,
    );
    notifyListeners();
  }
}
