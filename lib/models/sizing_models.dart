import 'cable_record.dart';

enum LoadInputMode { knownCurrent, calculateFromKw }

enum VdMode { reactanceIgnored, rPlusX }

/// Everything the sizing engine needs to evaluate one feeder.
class SizingInput {
  final String projectName;
  final LoadInputMode inputMode;

  /// Used when inputMode == knownCurrent
  final double? knownCurrentA;

  /// Used when inputMode == calculateFromKw
  final double realPowerKw;
  final double powerFactor;
  final double voltage;
  final bool threePhase;

  final double demandFactor;
  final double cableLengthM;
  final int parallelSets;
  final double groupingDeratingFactor;
  final double ambientDeratingFactor;
  final double safetyFactor;
  final double maxVoltageDropPercent;
  final VdMode vdMode;

  final String preferredMaterial; // "Copper" | "Aluminium"
  final String preferredFamily; // e.g. "XLPE/PVC"

  const SizingInput({
    this.projectName = 'C&I LV Feeder',
    this.inputMode = LoadInputMode.calculateFromKw,
    this.knownCurrentA,
    this.realPowerKw = 100,
    this.powerFactor = 0.85,
    this.voltage = 400,
    this.threePhase = true,
    this.demandFactor = 1.0,
    this.cableLengthM = 10,
    this.parallelSets = 1,
    this.groupingDeratingFactor = 1.0,
    this.ambientDeratingFactor = 1.0,
    this.safetyFactor = 1.0,
    this.maxVoltageDropPercent = 5.0,
    this.vdMode = VdMode.rPlusX,
    this.preferredMaterial = 'Copper',
    this.preferredFamily = 'XLPE/PVC',
  });

  /// Design current Ib, in amperes.
  double get designCurrentA {
    if (inputMode == LoadInputMode.knownCurrent) {
      return (knownCurrentA ?? 0) * demandFactor;
    }
    final kva = realPowerKw / (powerFactor == 0 ? 1 : powerFactor);
    if (threePhase) {
      return (realPowerKw * 1000 * demandFactor) /
          (1.732050808 * voltage * powerFactor);
    }
    // Single phase fallback
    return (kva * 1000 * demandFactor) / voltage;
  }

  double get equivalentKva =>
      realPowerKw / (powerFactor == 0 ? 1 : powerFactor);

  SizingInput copyWith({
    String? projectName,
    LoadInputMode? inputMode,
    double? knownCurrentA,
    double? realPowerKw,
    double? powerFactor,
    double? voltage,
    bool? threePhase,
    double? demandFactor,
    double? cableLengthM,
    int? parallelSets,
    double? groupingDeratingFactor,
    double? ambientDeratingFactor,
    double? safetyFactor,
    double? maxVoltageDropPercent,
    VdMode? vdMode,
    String? preferredMaterial,
    String? preferredFamily,
  }) {
    return SizingInput(
      projectName: projectName ?? this.projectName,
      inputMode: inputMode ?? this.inputMode,
      knownCurrentA: knownCurrentA ?? this.knownCurrentA,
      realPowerKw: realPowerKw ?? this.realPowerKw,
      powerFactor: powerFactor ?? this.powerFactor,
      voltage: voltage ?? this.voltage,
      threePhase: threePhase ?? this.threePhase,
      demandFactor: demandFactor ?? this.demandFactor,
      cableLengthM: cableLengthM ?? this.cableLengthM,
      parallelSets: parallelSets ?? this.parallelSets,
      groupingDeratingFactor:
          groupingDeratingFactor ?? this.groupingDeratingFactor,
      ambientDeratingFactor:
          ambientDeratingFactor ?? this.ambientDeratingFactor,
      safetyFactor: safetyFactor ?? this.safetyFactor,
      maxVoltageDropPercent:
          maxVoltageDropPercent ?? this.maxVoltageDropPercent,
      vdMode: vdMode ?? this.vdMode,
      preferredMaterial: preferredMaterial ?? this.preferredMaterial,
      preferredFamily: preferredFamily ?? this.preferredFamily,
    );
  }
}

/// Result of checking one [CableRecord] against a [SizingInput].
class CandidateResult {
  final CableRecord cable;
  final double designCurrentA;
  final double deratedCccA;
  final double ampacityUtilisationPercent;
  final double voltageDropPercent;
  final bool ampacityPass;
  final bool vdPass;
  final String suggestedBreaker;

  const CandidateResult({
    required this.cable,
    required this.designCurrentA,
    required this.deratedCccA,
    required this.ampacityUtilisationPercent,
    required this.voltageDropPercent,
    required this.ampacityPass,
    required this.vdPass,
    required this.suggestedBreaker,
  });

  bool get overallPass => ampacityPass && vdPass;
}
