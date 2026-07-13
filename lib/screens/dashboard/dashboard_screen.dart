import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/radial_family_chart.dart';
import '../quick_design/quick_design_screen.dart';
import '../detailed_design/detailed_design_screen.dart';
import '../cable_lookup/cable_lookup_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

enum _ChartMode { family, material }

class _DashboardScreenState extends State<DashboardScreen> {
  _ChartMode _mode = _ChartMode.family;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseProvider>();

    if (db.isLoading || !db.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final families = db.families;
    final materials = db.materials;

    final familySegments = <RadialSegment>[
      for (int i = 0; i < families.length; i++)
        RadialSegment(
          label: families[i],
          count: db.countByFamily(families[i]),
          percent: db.familyPercent(families[i]),
          color: AppColors.familyPalette[i % AppColors.familyPalette.length],
        ),
    ];
    final materialSegments = <RadialSegment>[
      for (int i = 0; i < materials.length; i++)
        RadialSegment(
          label: materials[i],
          count: db.countByMaterial(materials[i]),
          percent: db.materialPercent(materials[i]),
          color: [AppColors.accentAmber, AppColors.accentOrange][i % 2],
        ),
    ];

    final segments = _mode == _ChartMode.family ? familySegments : materialSegments;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _HeroCard(recordCount: db.recordCount),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.dns_rounded,
                iconColor: AppColors.primaryBlue,
                value: '${db.recordCount}',
                label: 'Cable records',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CableLookupScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.shield_rounded,
                iconColor: AppColors.pass,
                value: '${db.protectionRatingCount}',
                label: 'Protection ratings',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.hub_rounded,
                iconColor: const Color(0xFF8B5CF6),
                value: '${families.length}',
                label: 'Cable families',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.apartment_rounded,
                iconColor: AppColors.accentOrange,
                value: '${db.brandGroups.length}',
                label: 'Brand groups',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          icon: Icons.bar_chart_rounded,
          title: 'Database coverage',
          subtitle: 'Material and cable family database summary',
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Interactive radial chart',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                    _ModeToggleChip(
                      label: 'Family',
                      selected: _mode == _ChartMode.family,
                      onTap: () => setState(() => _mode = _ChartMode.family),
                    ),
                    const SizedBox(width: 8),
                    _ModeToggleChip(
                      label: 'Material',
                      selected: _mode == _ChartMode.material,
                      onTap: () => setState(() => _mode = _ChartMode.material),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Combined material and cable-family coverage by record count. '
                  'Tap any radial ring to select it and the centre value updates instantly.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),
                if (segments.isNotEmpty)
                  InsightBanner(
                    text:
                        '${_mode == _ChartMode.family ? "Family" : "Material"}: '
                        '${segments.first.label} has ${segments.first.count} records, equal to '
                        '${segments.first.percent.toStringAsFixed(1)}% of the full '
                        '${db.recordCount} cable-record database.',
                  ),
                const SizedBox(height: 20),
                RadialFamilyChart(segments: segments),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(
          icon: Icons.account_tree_rounded,
          title: 'Cable families',
          subtitle: '',
          trailing: CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
            child: Text('${families.length}',
                style: const TextStyle(
                    color: AppColors.primaryBlue, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: families.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, i) {
            final f = families[i];
            final color = AppColors.familyPalette[i % AppColors.familyPalette.length];
            return _FamilyCard(
              label: f,
              count: db.countByFamily(f),
              percent: db.familyPercent(f),
              color: color,
            );
          },
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          icon: Icons.alt_route_rounded,
          title: 'Design workflow',
          subtitle: '4-page structure for fast and detailed design',
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _WorkflowTile(
                  icon: Icons.grid_view_rounded,
                  title: 'Dashboard',
                  body: 'Review database status, design KPI and workflow tips.',
                ),
                _WorkflowTile(
                  icon: Icons.bolt_rounded,
                  title: 'Quick Design',
                  body: 'Input load current, length, PF and get instant cable + breaker result.',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const QuickDesignScreen())),
                ),
                _WorkflowTile(
                  icon: Icons.engineering_rounded,
                  title: 'Detailed Design',
                  body: 'Use project, load, derating, voltage drop, protective earth and short-circuit checks.',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DetailedDesignScreen())),
                ),
                _WorkflowTile(
                  icon: Icons.search_rounded,
                  title: 'Cable Lookup',
                  body: 'Filter and inspect every cable record with CCC, R, X and source notes.',
                  isLast: true,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CableLookupScreen())),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          icon: Icons.lightbulb_outline_rounded,
          title: 'Engineering tips',
          subtitle: 'Built into the app for site-friendly checking',
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
          children: const [
            EngineeringTipCard(
              icon: Icons.speed_rounded,
              title: 'Ampacity first',
              body: 'Check Ib × safety factor ≤ derated CCC × parallel sets before voltage drop.',
            ),
            EngineeringTipCard(
              icon: Icons.show_chart_rounded,
              title: 'Use R + X for long feeders',
              body: 'For long inverter-to-MSB or MSB-to-load feeders, R + X gives a more realistic voltage drop.',
            ),
            EngineeringTipCard(
              icon: Icons.shield_outlined,
              title: 'Breaker rule',
              body: 'Recommended MCB/MCCB/ACB rating is selected above design current; verify fault rating at switchboard.',
            ),
            EngineeringTipCard(
              icon: Icons.fact_check_outlined,
              title: 'Final issue check',
              body: 'Validate installation, grouping, ambient, earthing and manufacturer catalogue values before construction.',
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int recordCount;
  const _HeroCard({required this.recordCount});

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.electrical_services_rounded,
                color: AppColors.primaryBlue, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Auto Cable Sizing Pro',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Automatic cable recommendation with ampacity, voltage drop, '
                  'R + X mode, protection device suggestion, and practical design guidance.',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFDE2E2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: selected ? AppColors.fail : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.fail : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyCard extends StatelessWidget {
  final String label;
  final int count;
  final double percent;
  final Color color;

  const _FamilyCard({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('$count', style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (percent / 100).clamp(0, 1).toDouble(),
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 6),
            Text('${percent.toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _WorkflowTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool isLast;
  final VoidCallback? onTap;

  const _WorkflowTile({
    required this.icon,
    required this.title,
    required this.body,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.primaryTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: Colors.grey.shade200),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                      const SizedBox(height: 4),
                      Text(body,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.35)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
