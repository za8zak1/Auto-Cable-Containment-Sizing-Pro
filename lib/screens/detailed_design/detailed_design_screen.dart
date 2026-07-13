import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/design_provider.dart';
import '../../models/sizing_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/circular_gauge.dart';
import '../../widgets/labeled_field.dart';

class DetailedDesignScreen extends StatefulWidget {
  const DetailedDesignScreen({super.key});

  @override
  State<DetailedDesignScreen> createState() => _DetailedDesignScreenState();
}

class _DetailedDesignScreenState extends State<DetailedDesignScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _kwCtrl;
  late TextEditingController _lengthCtrl;
  late TextEditingController _pfCtrl;
  late TextEditingController _voltageCtrl;
  late TextEditingController _demandCtrl;
  late TextEditingController _groupingCtrl;
  late TextEditingController _ambientCtrl;
  late TextEditingController _safetyCtrl;
  late TextEditingController _maxVdCtrl;
  int _lastKnownRecordCount = -1;

  @override
  void initState() {
    super.initState();
    final design = context.read<DesignProvider>();
    final i = design.input;
    _nameCtrl = TextEditingController(text: i.projectName);
    _kwCtrl = TextEditingController(text: i.realPowerKw.toString());
    _lengthCtrl = TextEditingController(text: i.cableLengthM.toString());
    _pfCtrl = TextEditingController(text: i.powerFactor.toString());
    _voltageCtrl = TextEditingController(text: i.voltage.toString());
    _demandCtrl = TextEditingController(text: i.demandFactor.toString());
    _groupingCtrl = TextEditingController(text: i.groupingDeratingFactor.toString());
    _ambientCtrl = TextEditingController(text: i.ambientDeratingFactor.toString());
    _safetyCtrl = TextEditingController(text: i.safetyFactor.toString());
    _maxVdCtrl = TextEditingController(text: i.maxVoltageDropPercent.toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _kwCtrl.dispose();
    _lengthCtrl.dispose();
    _pfCtrl.dispose();
    _voltageCtrl.dispose();
    _demandCtrl.dispose();
    _groupingCtrl.dispose();
    _ambientCtrl.dispose();
    _safetyCtrl.dispose();
    _maxVdCtrl.dispose();
    super.dispose();
  }

  void _recompute() {
    context.read<DesignProvider>().recompute(context.read<DatabaseProvider>().records);
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseProvider>();
    final design = context.watch<DesignProvider>();

    if (db.recordCount != _lastKnownRecordCount) {
      _lastKnownRecordCount = db.recordCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) design.recompute(db.records);
      });
    }

    final active = design.activeResult;
    final input = design.input;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _ResultHeroDetailed(active: active, input: input),
        const SizedBox(height: 22),
        const SectionHeader(
          icon: Icons.assignment_rounded,
          title: 'Project and load',
          subtitle: 'Choose known current or calculate from kW/kVA',
        ),
        const SizedBox(height: 14),
        LabeledTextField(
          label: 'Project / feeder name',
          controller: _nameCtrl,
          onChanged: (v) {
            design.updateInput((i) => i.copyWith(projectName: v));
          },
        ),
        const SizedBox(height: 14),
        LabeledDropdown<LoadInputMode>(
          label: 'Input mode',
          value: input.inputMode,
          items: const {
            LoadInputMode.calculateFromKw: 'Calculate from kW',
            LoadInputMode.knownCurrent: 'Known current',
          },
          onChanged: (v) {
            design.updateInput((i) => i.copyWith(inputMode: v));
            _recompute();
          },
        ),
        const SizedBox(height: 14),
        LabeledTextField(
          label: 'Real power P',
          suffix: 'kW',
          controller: _kwCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            design.updateInput(
                (i) => i.copyWith(realPowerKw: double.tryParse(v) ?? i.realPowerKw));
            _recompute();
          },
        ),
        const SizedBox(height: 14),
        LabeledReadout(label: 'Calculated Ib', value: '${input.designCurrentA.toStringAsFixed(1)} A'),
        const SizedBox(height: 14),
        LabeledReadout(
          label: 'Equivalent P / S',
          value:
              '${input.realPowerKw.toStringAsFixed(1)} kW / ${input.equivalentKva.toStringAsFixed(1)} kVA',
        ),
        const SizedBox(height: 14),
        LabeledTextField(
          label: 'Demand factor',
          controller: _demandCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            design.updateInput(
                (i) => i.copyWith(demandFactor: double.tryParse(v) ?? i.demandFactor));
            _recompute();
          },
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          icon: Icons.thermostat_rounded,
          title: 'Derating and voltage drop',
          subtitle: 'Grouping, ambient, safety factor and VD limit',
        ),
        const SizedBox(height: 14),
        LabeledTextField(
          label: 'Cable length',
          suffix: 'm',
          controller: _lengthCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            design.updateInput(
                (i) => i.copyWith(cableLengthM: double.tryParse(v) ?? i.cableLengthM));
            _recompute();
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: LabeledTextField(
                label: 'Grouping factor',
                controller: _groupingCtrl,
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  design.updateInput((i) =>
                      i.copyWith(groupingDeratingFactor: double.tryParse(v) ?? i.groupingDeratingFactor));
                  _recompute();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledTextField(
                label: 'Ambient factor',
                controller: _ambientCtrl,
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  design.updateInput((i) =>
                      i.copyWith(ambientDeratingFactor: double.tryParse(v) ?? i.ambientDeratingFactor));
                  _recompute();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: LabeledTextField(
                label: 'Safety factor',
                controller: _safetyCtrl,
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  design.updateInput(
                      (i) => i.copyWith(safetyFactor: double.tryParse(v) ?? i.safetyFactor));
                  _recompute();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledTextField(
                label: 'Max VD',
                suffix: '%',
                controller: _maxVdCtrl,
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  design.updateInput((i) =>
                      i.copyWith(maxVoltageDropPercent: double.tryParse(v) ?? i.maxVoltageDropPercent));
                  _recompute();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LabeledDropdown<VdMode>(
          label: 'Voltage drop mode',
          value: input.vdMode,
          items: const {
            VdMode.rPlusX: 'R + X (recommended for long feeders)',
            VdMode.reactanceIgnored: 'R only',
          },
          onChanged: (v) {
            design.updateInput((i) => i.copyWith(vdMode: v));
            _recompute();
          },
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          icon: Icons.filter_alt_rounded,
          title: 'Cable preference filters',
          subtitle: 'Narrow the database before ranking candidates',
        ),
        const SizedBox(height: 14),
        LabeledDropdown<String?>(
          label: 'Material',
          value: design.materialFilter,
          items: {null: 'Any material', for (final m in db.materials) m: m},
          onChanged: (v) {
            design.setMaterialFilter(v);
          },
        ),
        const SizedBox(height: 14),
        LabeledDropdown<String?>(
          label: 'Cable family',
          value: design.familyFilter,
          items: {null: 'Any family', for (final f in db.families) f: f},
          onChanged: (v) {
            design.setFamilyFilter(v);
          },
        ),
        const SizedBox(height: 24),
        SectionHeader(
          icon: Icons.compare_arrows_rounded,
          title: 'Top candidate comparison',
          subtitle: 'Tap a candidate to overwrite the recommendation',
          trailing: design.manualSelection != null
              ? TextButton(
                  onPressed: design.clearManualSelection,
                  child: const Text('Reset'),
                )
              : null,
        ),
        const SizedBox(height: 14),
        const InsightBanner(
          text:
              'Manual overwrite: tap any candidate below to select it as the active '
              'cable recommendation. Select only candidates that still PASS ampacity '
              'and voltage-drop checks, unless you intentionally want a REVIEW result.',
        ),
        const SizedBox(height: 14),
        if (design.ranked.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No candidates match the current filters.')),
          )
        else
          ...design.ranked.take(12).map((r) {
            final isSelected = active != null && identical(r, active);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CandidateCard(
                result: r,
                selected: isSelected,
                onTap: () => design.selectManually(r),
              ),
            );
          }),
      ],
    );
  }
}

class _ResultHeroDetailed extends StatelessWidget {
  final CandidateResult? active;
  final SizingInput input;
  const _ResultHeroDetailed({required this.active, required this.input});

  @override
  Widget build(BuildContext context) {
    final found = active != null;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  input.projectName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.call_split_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('1 set', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              PassFailChip(pass: found && active!.overallPass, overrideLabel: found ? null : 'REVIEW'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            found
                ? 'Selected: ${active!.cable.displayLabel} • 1 set'
                : 'No candidate selected yet - adjust the inputs below.',
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GaugeStatTile(
                  icon: Icons.speed_rounded,
                  label: 'Ampacity',
                  valueText: found
                      ? '${active!.ampacityUtilisationPercent.toStringAsFixed(1)}%'
                      : '-',
                  percent: found ? active!.ampacityUtilisationPercent : 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GaugeStatTile(
                  icon: Icons.show_chart_rounded,
                  label: 'VD',
                  valueText: found ? '${active!.voltageDropPercent.toStringAsFixed(1)}%' : '-',
                  percent: found
                      ? (active!.voltageDropPercent / input.maxVoltageDropPercent) * 100
                      : 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final CandidateResult result;
  final bool selected;
  final VoidCallback onTap;

  const _CandidateCard({required this.result, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = result.cable;
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: selected ? AppColors.pass : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: result.overallPass
                    ? AppColors.pass.withValues(alpha: 0.15)
                    : AppColors.fail.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                result.overallPass ? Icons.check_rounded : Icons.close_rounded,
                size: 16,
                color: result.overallPass ? AppColors.pass : AppColors.fail,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.code,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      ),
                      if (selected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.pass.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('SELECTED',
                              style: TextStyle(
                                  color: AppColors.pass,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(c.displayLabel,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5, height: 1.3)),
                  const SizedBox(height: 6),
                  Text('Tap select',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${result.deratedCccA.toStringAsFixed(0)} A',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                Text(
                  '${result.voltageDropPercent.toStringAsFixed(1)}% VD',
                  style: TextStyle(
                    color: result.vdPass ? AppColors.pass : AppColors.fail,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
