import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class _ChecklistItem {
  final String title;
  final String note;
  bool checked;
  _ChecklistItem(this.title, this.note, {this.checked = false});
}

class ComplianceChecklistScreen extends StatefulWidget {
  const ComplianceChecklistScreen({super.key});

  @override
  State<ComplianceChecklistScreen> createState() => _ComplianceChecklistScreenState();
}

class _ComplianceChecklistScreenState extends State<ComplianceChecklistScreen> {
  final Map<String, List<_ChecklistItem>> _sections = {
    'TNB / Suruhanjaya Tenaga (ST)': [
      _ChecklistItem('Cable route and easement approved',
          'Confirm route does not breach TNB clearance/easement requirements.'),
      _ChecklistItem('Metering point and CT ratio confirmed',
          'Cross-check with TNB\'s latest supply application approval.'),
      _ChecklistItem('Earthing system agreed with Authority Having Jurisdiction',
          'TT/TN-S/TN-C-S as applicable to the site supply arrangement.'),
    ],
    'IEC 60364-5-52 sizing basis': [
      _ChecklistItem('Reference installation method selected correctly',
          'Confirms which CCC column of the database applies.'),
      _ChecklistItem('Grouping and ambient derating factors applied',
          'Cross-checked against actual containment fill and site temperature.'),
      _ChecklistItem('Voltage drop within limits at final circuit',
          'Typically 5% overall (supply to final load) unless project spec states otherwise.'),
    ],
    'Protection coordination': [
      _ChecklistItem('Breaker rating between Ib and cable CCC',
          'Ib ≤ In ≤ Iz, per IEC 60364-4-43.'),
      _ChecklistItem('Fault rating (kA) verified at switchboard',
          'Confirm against prospective fault level from single-line diagram.'),
      _ChecklistItem('Discrimination/selectivity checked with upstream device',
          'Time-current curves reviewed where applicable.'),
    ],
    'Before construction issue': [
      _ChecklistItem('Manufacturer datasheet cross-checked',
          'Confirm CCC/R/X used match the actual cable to be procured.'),
      _ChecklistItem('As-built containment fill verified',
          'Trunking/tray/conduit fill factor matches design assumption.'),
      _ChecklistItem('Drawing revision and BOQ reconciled',
          'Ensure the issued drawing matches the sizing calculation revision.'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final total = _sections.values.expand((e) => e).length;
    final checked = _sections.values.expand((e) => e).where((e) => e.checked).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Compliance Checklist')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircularProgressIndicator(
                    value: total == 0 ? 0 : checked / total,
                    backgroundColor: Colors.grey.shade200,
                    strokeWidth: 6,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$checked of $total items checked',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(
                          'Design review checklist - not a substitute for TNB/ST '
                          'submission requirements, which may vary by project.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (final section in _sections.entries) ...[
            Text(section.key,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  for (final item in section.value)
                    CheckboxListTile(
                      value: item.checked,
                      onChanged: (v) => setState(() => item.checked = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.pass,
                      title: Text(item.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text(item.note,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
