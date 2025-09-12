// import 'package:flutter/material.dart';

// /// SummaryPage
// /// Clean, data-first UI that showcases engagement, events, and impact.
// /// Pure Flutter SDK (no 3rd-party deps). Drop into your app and navigate to it.
// class SummaryPage extends StatefulWidget {
//   const SummaryPage({super.key});

//   @override
//   State<SummaryPage> createState() => _SummaryPageState();
// }

// class _SummaryPageState extends State<SummaryPage> {
//   String _range = 'This Month';

//   // Mock summary numbers — replace with your Firestore/REST data
//   int totalMembers = 286;
//   int activeMembers = 143;
//   int newMembers = 24;
//   int totalEvents = 71;
//   int completedEvents = 53;
//   int upcomingEvents = 10;
//   int activeEvents = 8;
//   double volunteerHours = 1276; // lifetime

//   // Simple monthly trend data (for bar chart)
//   final List<_BarPoint> monthlyTrend = const [
//     _BarPoint('Jan', 6),
//     _BarPoint('Feb', 4),
//     _BarPoint('Mar', 7),
//     _BarPoint('Apr', 8),
//     _BarPoint('May', 5),
//     _BarPoint('Jun', 9),
//     _BarPoint('Jul', 11),
//     _BarPoint('Aug', 10),
//     _BarPoint('Sep', 7),
//     _BarPoint('Oct', 6),
//     _BarPoint('Nov', 8),
//     _BarPoint('Dec', 12),
//   ];

//   // Top volunteers mock
//   final List<_Volunteer> topVolunteers = const [
//     _Volunteer(name: 'Ayesha Khan', hours: 42, events: 11),
//     _Volunteer(name: 'Umar Farooq', hours: 38, events: 9),
//     _Volunteer(name: 'Zara Iqbal', hours: 35, events: 8),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final surface = theme.colorScheme.surface;

//     final completed = completedEvents.toDouble();
//     final expired =
//         (totalEvents - completedEvents - upcomingEvents - activeEvents)
//             .clamp(0, 999)
//             .toDouble();
//     final statusSum =
//         (activeEvents + upcomingEvents + completed + expired).toDouble();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Summary'),
//         centerTitle: false,
//         actions: [
//           IconButton(
//             tooltip: 'Share',
//             onPressed: () {},
//             icon: const Icon(Icons.ios_share_rounded),
//           ),
//           IconButton(
//             tooltip: 'Export',
//             onPressed: () {},
//             icon: const Icon(Icons.file_download_outlined),
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: SafeArea(
//         child: CustomScrollView(
//           slivers: [
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _HeaderFilter(
//                       range: _range,
//                       onChanged: (v) => setState(() => _range = v),
//                     ),
//                     const SizedBox(height: 12),
//                     // KPI Grid
//                     _KpiGrid(
//                       children: [
//                         _StatCard(
//                           title: 'Total Members',
//                           value: totalMembers.toString(),
//                           icon: Icons.group_rounded,
//                         ),
//                         _StatCard(
//                           title: 'Active This Month',
//                           value: activeMembers.toString(),
//                           trend: '+12% vs prev',
//                           icon: Icons.how_to_reg_rounded,
//                         ),
//                         _StatCard(
//                           title: 'New Members',
//                           value: newMembers.toString(),
//                           trend: '+6 this week',
//                           icon: Icons.person_add_alt_1_rounded,
//                         ),
//                         _StatCard(
//                           title: 'Total Events',
//                           value: totalEvents.toString(),
//                           icon: Icons.event_note_rounded,
//                         ),
//                         _StatCard(
//                           title: 'Completed',
//                           value: completedEvents.toString(),
//                           icon: Icons.verified_rounded,
//                         ),
//                         _StatCard(
//                           title: 'Volunteer Hours',
//                           value: volunteerHours.toStringAsFixed(0),
//                           icon: Icons.timer_rounded,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Event status stacked bar
//                     const _SectionHeader(title: 'Event Status Overview'),
//                     const SizedBox(height: 8),
//                     _Card(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const _LegendRow(items: [
//                             _LegendItem(
//                                 'Active', Icons.circle, Colors.blueAccent),
//                             _LegendItem('Upcoming', Icons.circle, Colors.amber),
//                             _LegendItem('Completed', Icons.circle, Colors.teal),
//                             _LegendItem(
//                                 'Expired', Icons.circle, Colors.redAccent),
//                           ]),
//                           const SizedBox(height: 12),
//                           _StackedStatusBar(
//                             segments: [
//                               _Segment(
//                                   value: activeEvents.toDouble(),
//                                   color: Colors.blueAccent),
//                               _Segment(
//                                   value: upcomingEvents.toDouble(),
//                                   color: Colors.amber),
//                               _Segment(value: completed, color: Colors.teal),
//                               _Segment(value: expired, color: Colors.redAccent),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '$activeEvents active • $upcomingEvents upcoming • $completedEvents completed • ${expired.toInt()} expired',
//                             style: theme.textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     // Monthly trend bar chart
//                     const _SectionHeader(title: 'Monthly Events Trend'),
//                     const SizedBox(height: 8),
//                     _Card(
//                       child: SizedBox(
//                         height: 220,
//                         child: _SimpleBarChart(points: monthlyTrend),
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     // Volunteer contribution
//                     const _SectionHeader(title: 'Top Volunteers'),
//                     const SizedBox(height: 8),
//                     _Card(
//                       child: Column(
//                         children: [
//                           for (final v in topVolunteers)
//                             _TopVolunteerTile(volunteer: v),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     // Achievements / Milestones
//                     const _SectionHeader(title: 'Milestones'),
//                     const SizedBox(height: 8),
//                     const _Card(
//                       child: Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: [
//                           _MilestoneChip('🎉 50 Events Completed'),
//                           _MilestoneChip('🙌 100 Active Volunteers'),
//                           _MilestoneChip('🏆 Community Award 2025'),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: surface.withOpacity(0.98),
//     );
//   }
// }

// // ---------- UI Building Blocks ----------

// class _HeaderFilter extends StatelessWidget {
//   const _HeaderFilter({
//     required this.range,
//     required this.onChanged,
//   });

//   final String range;
//   final ValueChanged<String> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             'Impact Summary',
//             style: theme.textTheme.titleLarge
//                 ?.copyWith(fontWeight: FontWeight.w700),
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: range,
//               items: const [
//                 DropdownMenuItem(
//                     value: 'This Month', child: Text('This Month')),
//                 DropdownMenuItem(
//                     value: 'Last 3 Months', child: Text('Last 3 Months')),
//                 DropdownMenuItem(
//                     value: 'Year to Date', child: Text('Year to Date')),
//                 DropdownMenuItem(value: 'All Time', child: Text('All Time')),
//               ],
//               onChanged: (v) => v == null ? null : onChanged(v),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _KpiGrid extends StatelessWidget {
//   const _KpiGrid({required this.children});
//   final List<Widget> children;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, c) {
//         final crossAxisCount = c.maxWidth > 1100
//             ? 4
//             : c.maxWidth > 800
//                 ? 3
//                 : 2;
//         return GridView.count(
//           physics: const NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           crossAxisCount: crossAxisCount,
//           mainAxisSpacing: 12,
//           crossAxisSpacing: 12,
//           childAspectRatio: 1.9,
//           children: children,
//         );
//       },
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   const _StatCard({
//     required this.title,
//     required this.value,
//     required this.icon,
//     this.trend,
//   });

//   final String title;
//   final String value;
//   final String? trend;
//   final IconData icon;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return _Card(
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             padding: const EdgeInsets.all(12),
//             child: Icon(icon, size: 24, color: theme.colorScheme.primary),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(title, style: theme.textTheme.labelMedium),
//                 const SizedBox(height: 6),
//                 Text(value,
//                     style: theme.textTheme.headlineSmall
//                         ?.copyWith(fontWeight: FontWeight.bold)),
//                 if (trend != null) ...[
//                   const SizedBox(height: 4),
//                   Text(trend!,
//                       style: theme.textTheme.bodySmall
//                           ?.copyWith(color: theme.hintColor)),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _Card extends StatelessWidget {
//   const _Card({required this.child});
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           )
//         ],
//         border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
//       ),
//       child: child,
//     );
//   }
// }

// class _SectionHeader extends StatelessWidget {
//   const _SectionHeader({required this.title});
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: Theme.of(context)
//           .textTheme
//           .titleMedium
//           ?.copyWith(fontWeight: FontWeight.w700),
//     );
//   }
// }

// class _LegendItem {
//   final String label;
//   final IconData icon;
//   final Color color;
//   const _LegendItem(this.label, this.icon, this.color);
// }

// class _LegendRow extends StatelessWidget {
//   const _LegendRow({required this.items});
//   final List<_LegendItem> items;

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 12,
//       runSpacing: 8,
//       children: items
//           .map((e) => Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(e.icon, size: 10, color: e.color),
//                   const SizedBox(width: 6),
//                   Text(e.label),
//                 ],
//               ))
//           .toList(),
//     );
//   }
// }

// class _Segment {
//   final double value;
//   final Color color;
//   const _Segment({required this.value, required this.color});
// }

// class _StackedStatusBar extends StatelessWidget {
//   const _StackedStatusBar({required this.segments});
//   final List<_Segment> segments;

//   @override
//   Widget build(BuildContext context) {
//     final total = segments.fold<double>(0, (p, c) => p + c.value);
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: Row(
//         children: [
//           for (final s in segments)
//             Expanded(
//               flex: ((s.value / (total == 0 ? 1 : total)) * 1000)
//                   .round()
//                   .clamp(0, 1000),
//               child: Container(height: 14, color: s.color),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _BarPoint {
//   final String x;
//   final int y;
//   const _BarPoint(this.x, this.y);
// }

// class _SimpleBarChart extends StatelessWidget {
//   const _SimpleBarChart({required this.points});
//   final List<_BarPoint> points;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, c) {
//         return CustomPaint(
//           painter: _BarChartPainter(
//               points: points, textStyle: Theme.of(context).textTheme.bodySmall),
//           size: Size(c.maxWidth, 220),
//         );
//       },
//     );
//   }
// }

// class _BarChartPainter extends CustomPainter {
//   _BarChartPainter({required this.points, this.textStyle});
//   final List<_BarPoint> points;
//   final TextStyle? textStyle;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..style = PaintingStyle.fill
//       ..color = Colors.blueAccent.withOpacity(0.9);

//     final axisPaint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1
//       ..color = Colors.black.withOpacity(0.08);

//     const padding = 24.0;
//     final chartHeight = size.height - padding * 2 - 16; // 16 for labels
//     final chartWidth = size.width - padding * 2;

//     final maxY = (points.map((e) => e.y).fold<int>(0, (p, c) => c > p ? c : p))
//         .toDouble()
//         .clamp(1, 999);
//     final barWidth = chartWidth / (points.length * 1.6);

//     // Axes
//     final origin = Offset(padding, size.height - padding);
//     canvas.drawLine(
//         origin, Offset(size.width - padding, size.height - padding), axisPaint);
//     canvas.drawLine(origin, const Offset(padding, padding), axisPaint);

//     tpPainter(String s, Offset o) {
//       final tp = TextPainter(
//           text: TextSpan(text: s, style: textStyle),
//           textDirection: TextDirection.ltr);
//       tp.layout();
//       tp.paint(canvas, o);
//     }

//     for (int i = 0; i < points.length; i++) {
//       final p = points[i];
//       final x = padding + (i + 0.5) * (chartWidth / points.length);
//       final h = (p.y / maxY) * chartHeight;
//       final rect = RRect.fromRectAndRadius(
//         Rect.fromLTWH(x - barWidth / 2, origin.dy - h, barWidth, h),
//         const Radius.circular(6),
//       );
//       canvas.drawRRect(rect, paint);

//       // X labels
//       final labelOffset = Offset(x - 8, origin.dy + 2);
//       tpPainter(p.x, labelOffset);
//     }

//     // Y gridlines (0, 25%, 50%, 75%, 100%)
//     for (int i = 0; i <= 4; i++) {
//       final y = origin.dy - (i / 4) * chartHeight;
//       canvas.drawLine(
//           Offset(padding, y), Offset(size.width - padding, y), axisPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class _Volunteer {
//   final String name;
//   final int hours;
//   final int events;
//   const _Volunteer(
//       {required this.name, required this.hours, required this.events});
// }

// class _TopVolunteerTile extends StatelessWidget {
//   const _TopVolunteerTile({required this.volunteer});
//   final _Volunteer volunteer;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final initials = volunteer.name.trim().isEmpty
//         ? '—'
//         : volunteer.name
//             .trim()
//             .split(RegExp(r"\s+"))
//             .map((e) => e[0])
//             .take(2)
//             .join()
//             .toUpperCase();

//     return ListTile(
//       leading: CircleAvatar(child: Text(initials)),
//       title: Text(volunteer.name,
//           style:
//               theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
//       subtitle: Text('${volunteer.events} events'),
//       trailing: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.primary.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.timer_outlined, size: 16),
//             const SizedBox(width: 6),
//             Text('${volunteer.hours}h'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _MilestoneChip extends StatelessWidget {
//   const _MilestoneChip(this.label);
//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.primary.withOpacity(0.06),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
//       ),
//       child: Text(label,
//           style: theme.textTheme.bodyMedium
//               ?.copyWith(fontWeight: FontWeight.w600)),
//     );
//   }
// }
import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("This is SummaryPage"),
      ),
    );
  }
}
