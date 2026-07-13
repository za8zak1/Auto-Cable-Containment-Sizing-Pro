import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/design_provider.dart';
import '../../models/sizing_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/labeled_field.dart';

class QuickDesignScreen extends StatefulWidget {
  const QuickDesignScreen({super.key});

  @override
  State<QuickDesignScreen> createState() => _QuickDesignScreenState();
}

class _QuickDesignScreenState extends State<QuickDesignScreen> {
  late TextEditingController _kwCtrl;
  late TextEditingController _currentCtrl;
  late TextEditingController _lengthCtrl;
  late TextEditingController _pfCtrl;
  late TextEditingController _voltageCtrl;
  int _lastKnownRecordCount = -1;

  @override
  void initState() {
    super.initState();
    final design = context.read<DesignProvider>();
    final i = design.input;
    _kwCtrl = TextEditingController(text: i.realPowerKw.toString());
    _currentCtrl = TextEditingController(text: (i.knownCurrentA ?? 0).toString());
    _lengthCtrl = TextEditingController(text: i.cableLengthM.toString());
    _pfCtrl = TextEditingController(text: i.powerFactor.toString());
    _voltageCtrl = TextEditingController(text: i.voltage.toString());
  }

  @override
  void dispose() {
    _kwCtrl.dispose();
    _currentCtrl.dispose();
    _lengthCtrl.dispose();
    _pfCtrl.dispose();
    _voltageCtrl.dispose();
    super.dispose();
  }

  void _recompute() {
    final design = context.read<DesignProvider>();
    design.recompute(context.read<DatabaseProvider>().records);
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
        _ResultHero(active: active, input: input),
        const SizedBox(height: 22),
        const SectionHeader(
          icon: Icons.tune_rounded,
          title: 'Main design inputs',
          subtitle: 'Suitable for fast site and proposal checks',
        ),
        const SizedBox(height: 14),
        LabeledDropdown<LoadInputMode>(
          label: 'Load input',
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
        if (input.inputMode == LoadInputMode.calculateFromKw) ...[
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
        ] else ...[
          LabeledTextField(
            label: 'Known current Ib',
            suffix: 'A',
            controller: _currentCtrl,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              design.updateInput(
                  (i) => i.copyWith(knownCurrentA: double.tryParse(v) ?? i.knownCurrentA));
              _recompute();
            },
          ),
        ],
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
        LabeledTextField(
          label: 'Power factor',
          suffix: 'PF',
          controller: _pfCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            design.updateInput(
                (i) => i.copyWith(powerFactor: double.tryParse(v) ?? i.powerFactor));
            _recompute();
          },
        ),
        const SizedBox(height: 14),
        LabeledTextField(
          label: 'Voltage',
          suffix: 'V',
          controller: _voltageCtrl,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            design.updateInput((i) => i.copyWith(voltage: double.tryParse(v) ?? i.voltage));
            _recompute();
          },
        ),
        const SizedBox(height: 14),
        LabeledDropdown<bool>(
          label: 'Phase',
          value: input.threePhase,
          items: const {true: 'Three phase', false: 'Single phase'},
          onChanged: (v) {
            design.updateInput((i) => i.copyWith(threePhase: v));
            _recompute();
          },
        ),
      ],
    );
  }
}

class _ResultHero extends StatelessWidget {
  final CandidateResult? active;
  final SizingInput input;
  const _ResultHero({required this.active, required this.input});

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
              Icon(found ? Icons.check_circle_rounded : Icons.bolt_rounded,
                  color: Colors.white, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  found ? active!.cable.code : 'No cable found',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
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
              if (found)
                PassFailChip(pass: active!.overallPass)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text('REVIEW',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            found
                ? 'Selected: ${active!.cable.displayLabel} • 1 set'
                : 'Adjust the filter or design inputs to find a suitable cable.',
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
        ],
      ),
    );
  }
}
