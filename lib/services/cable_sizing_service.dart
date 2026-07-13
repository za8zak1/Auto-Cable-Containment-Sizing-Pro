import 'dart:math' as math;
import '../models/cable_record.dart';
import '../models/sizing_models.dart';

/// Pure calculation engine - no Flutter/UI dependencies, so it is easy to
/// unit test on its own.
///
/// NOTE: the ampacity/R/X figures it consumes come from whichever
/// [CableRecord]s are passed in. With the bundled placeholder database the
/// results are for UI demonstration only - see `CableDatabase`'s disclaimer.
class CableSizingService {
  const CableSizingService();

  /// Evaluates a single cable candidate against the given design input.
  CandidateResult evaluate(SizingInput input, CableRecord cable) {
    final ib = input.designCurrentA;

    final deratedCcc = cable.cccAmps *
        input.groupingDeratingFactor *
        input.ambientDeratingFactor *
        input.parallelSets;

    final utilisation =
        deratedCcc == 0 ? 999.0 : (ib * input.safetyFactor / deratedCcc) * 100;

    final ampacityPass = (ib * input.safetyFactor) <= deratedCcc;

    final vdPercent = _voltageDropPercent(input, cable, ib);
    final vdPass = vdPercent <= input.maxVoltageDropPercent;

    return CandidateResult(
      cable: cable,
      designCurrentA: ib,
      deratedCccA: deratedCcc,
      ampacityUtilisationPercent: utilisation,
      voltageDropPercent: vdPercent,
      ampacityPass: ampacityPass,
      vdPass: vdPass,
      suggestedBreaker: _suggestBreaker(ib, deratedCcc),
    );
  }

  double _voltageDropPercent(SizingInput input, CableRecord cable, double ib) {
    final lengthKm = input.cableLengthM / 1000.0;
    final sets = input.parallelSets == 0 ? 1 : input.parallelSets;
    final r = cable.rOhmPerKm / sets;
    final x = cable.xOhmPerKm / sets;

    final cosPhi = input.powerFactor.clamp(0.0, 1.0).toDouble();
    final sinPhi = math.sqrt((1.0 - cosPhi * cosPhi).clamp(0.0, 1.0));

    double dropVolts;
    if (input.threePhase) {
      if (input.vdMode == VdMode.rPlusX) {
        dropVolts = 1.732050808 * ib * lengthKm * (r * cosPhi + x * sinPhi);
      } else {
        dropVolts = 1.732050808 * ib * lengthKm * r * cosPhi;
      }
    } else {
      if (input.vdMode == VdMode.rPlusX) {
        dropVolts = 2.0 * ib * lengthKm * (r * cosPhi + x * sinPhi);
      } else {
        dropVolts = 2.0 * ib * lengthKm * r * cosPhi;
      }
    }
    if (input.voltage == 0) return 0;
    return (dropVolts / input.voltage) * 100;
  }

  String _suggestBreaker(double ib, double deratedCcc) {
    final ratingBasis = math.max(ib, 0.0);
    const standardMcb = [6, 10, 16, 20, 25, 32, 40, 50, 63, 80, 100];
    const standardMccb = [125, 160, 200, 250, 320, 400, 500, 630];
    const standardAcb = [800, 1000, 1250, 1600, 2000, 2500, 3200, 4000];

    for (final r in standardMcb) {
      if (r >= ratingBasis && r <= deratedCcc) return 'MCB $r A';
    }
    for (final r in standardMccb) {
      if (r >= ratingBasis && r <= deratedCcc) return 'MCCB $r A';
    }
    for (final r in standardAcb) {
      if (r >= ratingBasis && r <= deratedCcc) return 'ACB $r A';
    }
    // Fall back to the next standard rating even if it slightly exceeds CCC,
    // so the UI always has something to show (result panel will still show
    // FAIL/REVIEW from the ampacity check).
    for (final r in [...standardMcb, ...standardMccb, ...standardAcb]) {
      if (r >= ratingBasis) return '≈ $r A (verify against CCC)';
    }
    return 'Verify manually';
  }

  /// Filters + ranks candidates from [pool], smallest adequate size first,
  /// then returns the full ranked list (both passing and failing) so the UI
  /// can present a "top candidate comparison" list like the reference app.
  List<CandidateResult> rankCandidates({
    required SizingInput input,
    required List<CableRecord> pool,
    String? materialFilter,
    String? familyFilter,
    String? constructionFilter,
  }) {
    Iterable<CableRecord> filtered = pool;
    if (materialFilter != null) {
      filtered = filtered.where((c) => c.material == materialFilter);
    }
    if (familyFilter != null) {
      filtered = filtered.where((c) => c.family == familyFilter);
    }
    if (constructionFilter != null) {
      filtered = filtered.where((c) => c.construction == constructionFilter);
    }

    final results = filtered.map((c) => evaluate(input, c)).toList();
    results.sort((a, b) {
      // Passing candidates first, then by size ascending.
      if (a.overallPass != b.overallPass) {
        return a.overallPass ? -1 : 1;
      }
      return a.cable.sizeSqmm.compareTo(b.cable.sizeSqmm);
    });
    return results;
  }

  /// Returns the first (smallest) passing candidate, or null if none pass.
  CandidateResult? recommend({
    required SizingInput input,
    required List<CableRecord> pool,
    String? materialFilter,
    String? familyFilter,
    String? constructionFilter,
  }) {
    final ranked = rankCandidates(
      input: input,
      pool: pool,
      materialFilter: materialFilter,
      familyFilter: familyFilter,
      constructionFilter: constructionFilter,
    );
    for (final r in ranked) {
      if (r.overallPass) return r;
    }
    return null;
  }
}
