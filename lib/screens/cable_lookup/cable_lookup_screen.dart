import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';
import '../../models/cable_record.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CableLookupScreen extends StatefulWidget {
  const CableLookupScreen({super.key});

  @override
  State<CableLookupScreen> createState() => _CableLookupScreenState();
}

class _CableLookupScreenState extends State<CableLookupScreen> {
  String _query = '';
  String? _familyFilter;
  String? _materialFilter;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseProvider>();

    if (db.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (db.error != null || !db.isLoaded) {
      return DatabaseLoadErrorView(
        message: db.error ?? 'The bundled cable database is unavailable.',
        onRetry: db.load,
      );
    }

    var results = db.records.where((c) {
      final matchesQuery = _query.isEmpty ||
          c.code.toLowerCase().contains(_query.toLowerCase()) ||
          c.family.toLowerCase().contains(_query.toLowerCase()) ||
          c.construction.toLowerCase().contains(_query.toLowerCase());
      final matchesFamily = _familyFilter == null || c.family == _familyFilter;
      final matchesMaterial = _materialFilter == null || c.material == _materialFilter;
      return matchesQuery && matchesFamily && matchesMaterial;
    }).toList();

    results.sort((a, b) => a.sizeSqmm.compareTo(b.sizeSqmm));

    return Column(
      key: const Key('lookup_screen'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by size, family or construction',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'All families',
                selected: _familyFilter == null,
                onTap: () => setState(() => _familyFilter = null),
              ),
              for (final f in db.families)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _FilterChip(
                    label: f,
                    selected: _familyFilter == f,
                    onTap: () => setState(() => _familyFilter = f),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'All materials',
                selected: _materialFilter == null,
                onTap: () => setState(() => _materialFilter = null),
                compact: true,
              ),
              for (final m in db.materials)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _FilterChip(
                    label: m,
                    selected: _materialFilter == m,
                    onTap: () => setState(() => _materialFilter = m),
                    compact: true,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Text('${results.length} of ${db.recordCount} records',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? const Center(child: Text('No records match this filter.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _CableTile(cable: results[i]),
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 6 : 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w700,
            fontSize: compact ? 12 : 12.5,
          ),
        ),
      ),
    );
  }
}

class _CableTile extends StatelessWidget {
  final CableRecord cable;
  const _CableTile({required this.cable});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(cable.code, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(cable.displayLabel,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${cable.cccAmps.toStringAsFixed(0)} A',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            Text('CCC', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
        children: [
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'R (Ω/km)', value: cable.rOhmPerKm.toString())),
              Expanded(child: _MiniStat(label: 'X (Ω/km)', value: cable.xOhmPerKm.toString())),
              Expanded(child: _MiniStat(label: 'Protection', value: cable.protectionClass)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            cable.sourceNote,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11.5, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
