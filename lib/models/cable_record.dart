/// One row of the LV cable engineering database.
///
/// This mirrors the fields referenced throughout the UI (CCC, R, X,
/// material, family/insulation type, construction, protection rating)
/// so the sizing engine and the Cable Lookup screen share one shape.
class CableRecord {
  final String id;

  /// e.g. "1 x 4C", "4C x 1", "1C"
  final String construction;

  /// e.g. "PVC/PVC", "XLPE/PVC", "PVC/SWA/PVC", "XLPE/SWA/PVC",
  /// "PVC/AWA/PVC", "XLPE/AWA/PVC", "ABC"
  final String family;

  /// "Copper" or "Aluminium"
  final String material;

  /// Nominal conductor cross-sectional area in mm^2
  final double sizeSqmm;

  /// Current-carrying capacity (ampacity) in air, reference method per
  /// IEC 60364-5-52 / Malaysian practice, in amperes.
  final double cccAmps;

  /// AC resistance, ohm/km
  final double rOhmPerKm;

  /// AC reactance, ohm/km
  final double xOhmPerKm;

  /// Suggested protection device rating class, e.g. "MCB", "MCCB", "ACB"
  final String protectionClass;

  final String brandGroup;
  final String sourceNote;

  const CableRecord({
    required this.id,
    required this.construction,
    required this.family,
    required this.material,
    required this.sizeSqmm,
    required this.cccAmps,
    required this.rOhmPerKm,
    required this.xOhmPerKm,
    required this.protectionClass,
    required this.brandGroup,
    required this.sourceNote,
  });

  factory CableRecord.fromJson(Map<String, dynamic> json) {
    return CableRecord(
      id: json['id'] as String,
      construction: json['construction'] as String,
      family: json['family'] as String,
      material: json['material'] as String,
      sizeSqmm: (json['sizeSqmm'] as num).toDouble(),
      cccAmps: (json['cccAmps'] as num).toDouble(),
      rOhmPerKm: (json['rOhmPerKm'] as num).toDouble(),
      xOhmPerKm: (json['xOhmPerKm'] as num).toDouble(),
      protectionClass: json['protectionClass'] as String,
      brandGroup: json['brandGroup'] as String,
      sourceNote: json['sourceNote'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'construction': construction,
        'family': family,
        'material': material,
        'sizeSqmm': sizeSqmm,
        'cccAmps': cccAmps,
        'rOhmPerKm': rOhmPerKm,
        'xOhmPerKm': xOhmPerKm,
        'protectionClass': protectionClass,
        'brandGroup': brandGroup,
        'sourceNote': sourceNote,
      };

  /// Short catalogue-style code, e.g. "CO-XLPEPVC-4C-70SQ"
  String get code {
    final matCode = material.toLowerCase().startsWith('cu') ||
            material.toLowerCase() == 'copper'
        ? 'CO'
        : 'AL';
    final famCode = family.replaceAll('/', '').replaceAll(' ', '').toUpperCase();
    final consCode =
        construction.replaceAll(' ', '').replaceAll('x', 'X').toUpperCase();
    final sizeCode = sizeSqmm % 1 == 0
        ? sizeSqmm.toStringAsFixed(0)
        : sizeSqmm.toString();
    return '$matCode-$famCode-$consCode-${sizeCode}SQ';
  }

  String get displayLabel =>
      '$construction (${construction.contains('x 1') || construction.contains('X1') ? 'single-core cable' : 'multicore cable'}) • $family • $material • ${sizeSqmm % 1 == 0 ? sizeSqmm.toStringAsFixed(0) : sizeSqmm} mm²';
}
