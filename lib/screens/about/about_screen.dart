import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.heroGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.electrical_services_rounded,
                      color: AppColors.primaryBlue, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Auto Cable Sizing Pro',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                      SizedBox(height: 2),
                      Text('Modern engineering app',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Purpose', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Auto Cable Sizing Pro assists LV electrical and solar EPC engineers with '
                'automatic cable recommendation - ampacity checking, voltage drop (R or R + X mode), '
                'protection device suggestion, and quick or detailed design workflows referenced '
                'against IEC 60364-5-52 sizing principles.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Important note', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'This app is a design-assist tool. It does not replace the judgement of a '
                'competent engineer, the requirements of TNB / Suruhanjaya Tenaga (ST), or '
                'the manufacturer\'s current datasheet. Always verify the final cable and '
                'protection device selection before construction issue.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Version', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('1.0.0'),
              subtitle: const Text('Flutter rebuild - initial GitHub release'),
            ),
          ),
        ],
      ),
    );
  }
}
