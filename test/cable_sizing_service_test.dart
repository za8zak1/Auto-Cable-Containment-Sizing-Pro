import 'package:flutter_test/flutter_test.dart';
import 'package:auto_cable_sizing_pro/models/cable_record.dart';
import 'package:auto_cable_sizing_pro/models/sizing_models.dart';
import 'package:auto_cable_sizing_pro/services/cable_sizing_service.dart';

void main() {
  const service = CableSizingService();

  const cable = CableRecord(
    id: 'TEST-001',
    construction: '4C',
    family: 'XLPE/PVC',
    material: 'Copper',
    sizeSqmm: 35,
    cccAmps: 150,
    rOhmPerKm: 0.2,
    xOhmPerKm: 0.08,
    protectionClass: 'MCCB',
    brandGroup: 'Test',
    sourceNote: 'Unit-test fixture',
  );

  test('known-current ampacity and R-only voltage drop pass', () {
    const input = SizingInput(
      inputMode: LoadInputMode.knownCurrent,
      knownCurrentA: 100,
      voltage: 400,
      threePhase: true,
      powerFactor: 0.9,
      cableLengthM: 10,
      maxVoltageDropPercent: 3,
      vdMode: VdMode.reactanceIgnored,
    );

    final result = service.evaluate(input, cable);

    expect(result.designCurrentA, closeTo(100, 1e-9));
    expect(result.deratedCccA, closeTo(150, 1e-9));
    expect(result.ampacityPass, isTrue);
    expect(result.vdPass, isTrue);
    expect(result.voltageDropPercent, closeTo(0.07794, 0.0001));
    expect(result.suggestedBreaker, 'MCB 100 A');
  });

  test('parallel sets increase effective ampacity and reduce voltage drop', () {
    const oneSet = SizingInput(
      inputMode: LoadInputMode.knownCurrent,
      knownCurrentA: 120,
      parallelSets: 1,
      cableLengthM: 100,
    );
    const twoSets = SizingInput(
      inputMode: LoadInputMode.knownCurrent,
      knownCurrentA: 120,
      parallelSets: 2,
      cableLengthM: 100,
    );

    final one = service.evaluate(oneSet, cable);
    final two = service.evaluate(twoSets, cable);

    expect(two.deratedCccA, closeTo(one.deratedCccA * 2, 1e-9));
    expect(two.voltageDropPercent, closeTo(one.voltageDropPercent / 2, 1e-9));
  });

  test('ranking places the smallest passing cable first', () {
    const small = CableRecord(
      id: 'SMALL',
      construction: '4C',
      family: 'XLPE/PVC',
      material: 'Copper',
      sizeSqmm: 16,
      cccAmps: 80,
      rOhmPerKm: 0.4,
      xOhmPerKm: 0.08,
      protectionClass: 'MCCB',
      brandGroup: 'Test',
      sourceNote: 'Unit-test fixture',
    );
    const large = CableRecord(
      id: 'LARGE',
      construction: '4C',
      family: 'XLPE/PVC',
      material: 'Copper',
      sizeSqmm: 50,
      cccAmps: 200,
      rOhmPerKm: 0.15,
      xOhmPerKm: 0.08,
      protectionClass: 'MCCB',
      brandGroup: 'Test',
      sourceNote: 'Unit-test fixture',
    );
    const input = SizingInput(
      inputMode: LoadInputMode.knownCurrent,
      knownCurrentA: 100,
      cableLengthM: 10,
    );

    final ranked = service.rankCandidates(input: input, pool: [small, large]);

    expect(ranked.first.cable.id, 'LARGE');
    expect(ranked.first.overallPass, isTrue);
    expect(ranked.last.cable.id, 'SMALL');
    expect(ranked.last.overallPass, isFalse);
  });
}
