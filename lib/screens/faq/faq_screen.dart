import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    (
      'Why does the app show REVIEW instead of PASS?',
      'REVIEW means either the derated CCC is below the design current x safety '
          'factor, or the voltage drop exceeds your configured limit. Try a larger '
          'size, a different family, or check your derating factors.',
    ),
    (
      'What is the difference between R only and R + X mode?',
      'R only ignores cable reactance and is a reasonable approximation for short, '
          'small-conductor circuits. R + X includes reactance and gives a more '
          'realistic result for long runs and larger conductors, matching common '
          'utility/consultant practice for feeders.',
    ),
    (
      'How is the suggested breaker rating chosen?',
      'The app picks the smallest standard MCB/MCCB/ACB rating that is greater than '
          'or equal to the design current and less than or equal to the derated CCC, '
          'per the IEC 60364-4-43 principle Ib ≤ In ≤ Iz. Always confirm the fault '
          '(kA) rating separately.',
    ),
    (
      'Can I replace the bundled cable database?',
      'Yes. Replace assets/data/cable_database_sample.json with your verified '
          'database in the same JSON shape (see CableRecord.fromJson). The bundled '
          'file is a clearly-labelled placeholder for demonstrating the app '
          'architecture only.',
    ),
    (
      'Does this app replace TNB/ST submission or manufacturer verification?',
      'No. It is a design-assist tool. Always verify the final cable and protection '
          'device selection against IEC 60364-5-52, TNB/ST requirements and the '
          'manufacturer\'s current datasheet before construction issue.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final (q, a) = _faqs[i];
          return Card(
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(q, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              children: [
                Text(a, style: TextStyle(color: Colors.grey.shade700, height: 1.45)),
              ],
            ),
          );
        },
      ),
    );
  }
}
