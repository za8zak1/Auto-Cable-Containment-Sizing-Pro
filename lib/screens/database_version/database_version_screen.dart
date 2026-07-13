import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';
import '../../theme/app_theme.dart';

class DatabaseVersionScreen extends StatelessWidget {
  const DatabaseVersionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Database Version')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.grid_on_rounded, color: AppColors.primaryBlue),
                      const SizedBox(width: 10),
                      Text('Version: ${db.sourceVersion}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${db.recordCount} cable records • ${db.families.length} families • '
                      '${db.materials.length} materials • ${db.brandGroups.length} brand groups'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFCDD2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.fail),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    db.disclaimer.isNotEmpty
                        ? db.disclaimer
                        : 'This is a design-assist tool. Always verify final cable selection '
                            'against IEC 60364-5-52, TNB/ST requirements and the manufacturer\'s '
                            'current datasheet before issuing for construction.',
                    style: const TextStyle(color: Color(0xFFB71C1C), height: 1.4, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Sources', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SourceRow('Ampacity reference method',
                      'IEC 60364-5-52 sizing tables (replace with manufacturer datasheet CCC for final issue).'),
                  SizedBox(height: 12),
                  _SourceRow('Voltage drop',
                      'R and X per unit length from cable manufacturer catalogue or IEC 60228/60502.'),
                  SizedBox(height: 12),
                  _SourceRow('Protection coordination',
                      'IEC 60364-4-43 (Ib ≤ In ≤ Iz) and standard MCB/MCCB/ACB rating steps.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Replacing this database',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Swap assets/data/cable_database_sample.json for your verified engineering '
                'database (same JSON shape - see CableRecord.fromJson in lib/models/cable_record.dart), '
                'then update pubspec.yaml assets if you rename the file.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final String title;
  final String body;
  const _SourceRow(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 2),
        Text(body, style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5, height: 1.35)),
      ],
    );
  }
}
