// lib/features/history/presentation/pages/history_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/mockup_data.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final dateFmt = DateFormat('dd MMM yyyy • HH:mm');

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('ประวัติการจอดรถ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Summary banner ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.maroon, AppColors.maroonDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _BannerStat(
                    label: 'จำนวนครั้ง',
                    value: '${MockupData.parkingHistory.length}',
                  ),
                ),
                Container(
                  width: 1, height: 40,
                  color: Colors.white.withAlpha((0.3 * 255).round())),
                Expanded(
                  child: _BannerStat(
                    label: 'ชม.ฟรีรวม',

                    value: '${MockupData.totalFreeHours} ชม.',
                  ),
                ),
                Container(
                  width: 1, height: 40,
                  color: Colors.white.withAlpha((0.3 * 255).round())),
                Expanded(
                  child: _BannerStat(
                    label: 'ค่าจอดจ่าย',
                    value: '฿${MockupData.parkingHistory.fold<double>(0, (s, p) => s + p.chargeAmount).toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text('รายการทั้งหมด',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          // ── History list ────────────────────────────────
          ...MockupData.parkingHistory.map((p) {
            final duration = p.exitTime.difference(p.entryTime);
            final hrs = duration.inHours;
            final mins = duration.inMinutes % 60;
            final isFree = p.chargeAmount == 0;

            return Hero(
              tag: 'parking-${p.id}',
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outline),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: isFree
                                  ? AppColors.success.withAlpha((0.1 * 255).round())
                                  : AppColors.warning.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isFree
                                  ? Icons.check_circle_outline
                                  : Icons.payment_outlined,
                              color: isFree
                                  ? AppColors.success : AppColors.warning,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dateFmt.format(p.entryTime),
                                  style: const TextStyle(
                                    fontFamily: 'Sarabun',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                                Text(
                                  isFree ? 'ออกได้ฟรี' : 'ชำระค่าจอดเพิ่ม',
                                  style: TextStyle(
                                    fontFamily: 'Sarabun',
                                    fontSize: 12,
                                    color: isFree
                                        ? AppColors.success
                                        : AppColors.warning,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            isFree ? 'ฟรี' : '฿${p.chargeAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontFamily: 'Sarabun',
                              fontSize: 20, fontWeight: FontWeight.w700,
                              color: isFree
                                  ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    const Divider(height: 1, indent: 16, endIndent: 16),

                    // Details
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                      child: Row(
                        children: [
                          _DetailChip(
                            icon: Icons.timer_outlined,
                            label: '$hrs ชม. $mins นาที',
                          ),
                          const SizedBox(width: 8),
                          _DetailChip(
                            icon: Icons.local_parking,
                            label: 'ฟรี ${p.freeHours} ชม.',
                            highlight: true,
                          ),
                          const SizedBox(width: 8),
                          _DetailChip(
                            icon: Icons.receipt_outlined,
                            label: '฿${p.totalSpend.toStringAsFixed(0)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label, value;
  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
          style: const TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 18, fontWeight: FontWeight.w700,
            color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 11,
            color: Colors.white.withAlpha((0.75 * 255).round()))),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;
  const _DetailChip({
    required this.icon, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.maroon.withAlpha((0.08 * 255).round())
            : AppColors.paleBrownLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
            size: 13,
            color: highlight ? AppColors.maroon : AppColors.warmGray),
          const SizedBox(width: 4),
          Text(label,
            style: TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 11, fontWeight: FontWeight.w500,
              color: highlight ? AppColors.maroon : AppColors.warmGray,
            ),
          ),
        ],
      ),
    );
  }
}
