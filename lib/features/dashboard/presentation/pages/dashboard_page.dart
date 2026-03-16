// lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/mockup_data.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  const DashboardPage({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  late TabController _tabCtrl;

  List<MockReceipt> get _filteredReceipts {
    if (_searchQuery.isEmpty) return MockupData.allReceipts;
    return MockupData.allReceipts.where((r) =>
      r.storeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      r.categoryLabel.contains(_searchQuery),
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.maroon,
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                icon: Icon(
                  widget.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: Colors.white,
                ),
                onPressed: widget.onToggleTheme,
              ),
            ],
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.paleBrown,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontFamily: 'Sarabun', fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'สรุปภาพรวม'),
                Tab(text: 'Top Spenders'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _OverviewTab(
              searchCtrl: _searchCtrl,
              searchQuery: _searchQuery,
              filteredReceipts: _filteredReceipts,
              onSearch: (v) => setState(() => _searchQuery = v),
            ),
            _TopSpenderTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab 1: Overview
// ─────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String searchQuery;
  final List<MockReceipt> filteredReceipts;
  final ValueChanged<String> onSearch;

  const _OverviewTab({
    required this.searchCtrl,
    required this.searchQuery,
    required this.filteredReceipts,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Stats grid ─────────────────────────────────
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _StatCard(
              label: 'ยอดรวมเดือนนี้',
              value: '฿${MockupData.monthlyTotal.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.maroon,
            ),
            _StatCard(
              label: 'จำนวนครั้ง',
              value: '${MockupData.totalVisits} ครั้ง',
              icon: Icons.event_available_outlined,
              color: AppColors.catRestaurant,
            ),
            _StatCard(
              label: 'ชม.ฟรีสะสม',
              value: '${MockupData.totalFreeHours} ชม.',
              icon: Icons.timer_outlined,
              color: AppColors.catBeverage,
            ),
            _StatCard(
              label: 'ค่าจอดที่ประหยัด',
              value: '฿${MockupData.savedParkingFees.toStringAsFixed(0)}',
              icon: Icons.savings_outlined,
              color: AppColors.success,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Donut chart (category breakdown) ───────────
        _CategoryBreakdownCard(),

        const SizedBox(height: 16),

        // ── Weekly bar chart ────────────────────────────
        _WeeklySpendCard(),

        const SizedBox(height: 20),

        // ── Search ─────────────────────────────────────
        TextField(
          controller: searchCtrl,
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: 'ค้นหาร้านค้า หรือหมวดหมู่...',
            prefixIcon: const Icon(Icons.search,
                color: AppColors.warmGray),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: AppColors.warmGray),
                    onPressed: () {
                      searchCtrl.clear();
                      onSearch('');
                    },
                  )
                : null,
          ),
        ),

        const SizedBox(height: 12),

        // ── Receipt list ────────────────────────────────
        ...filteredReceipts.map((r) => _DashReceiptTile(receipt: r)),

        if (filteredReceipts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                const Icon(Icons.search_off,
                    size: 48, color: AppColors.warmGray),
                const SizedBox(height: 12),
                Text('ไม่พบรายการ "$searchQuery"',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Tab 2: Top Spenders
// ─────────────────────────────────────────────
class _TopSpenderTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Month badge ─────────────────────────────────
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
              const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Spender เดือนมิถุนายน',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text('ผู้ใช้จ่ายสูงสุดได้รับสิทธิ์จอดฟรี 3 วัน',
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Leaderboard ─────────────────────────────────
        ...MockupData.customers.asMap().entries.map((e) {
          final i = e.key;
          final c = e.value;
          return _LeaderboardCard(customer: c, rank: i + 1);
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(label,
                style: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 11, color: AppColors.warmGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('สัดส่วนหมวดหมู่',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...MockupData.categoryPercent.entries.map((e) {
            final color = e.key == 'Shopping'
                ? AppColors.catShopping
                : e.key == 'ร้านอาหาร'
                    ? AppColors.catRestaurant
                    : AppColors.catBeverage;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(e.key,
                            style: const TextStyle(
                              fontFamily: 'Sarabun', fontSize: 13)),
                        ],
                      ),
                      Text('${e.value.toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: e.value / 100),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v, minHeight: 8,
                        backgroundColor: AppColors.paleBrownLight,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WeeklySpendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final maxVal = MockupData.weeklySpend.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ยอดใช้จ่ายรายสัปดาห์',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: MockupData.weeklySpend.asMap().entries.map((e) {
                final ratio = e.value / maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('฿${(e.value / 1000).toStringAsFixed(1)}k',
                          style: const TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 10, color: AppColors.warmGray)),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: ratio),
                          duration: Duration(
                              milliseconds: 600 + e.key * 100),
                          curve: Curves.easeOut,
                          builder: (_, v, __) => Container(
                            height: 80 * v,
                            decoration: BoxDecoration(
                              color: AppColors.maroon.withOpacity(
                                  0.6 + v * 0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(MockupData.weekLabels[e.key]
                            .replaceAll('สัปดาห์ ', 'W'),
                          style: const TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 10, color: AppColors.warmGray)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashReceiptTile extends StatelessWidget {
  final MockReceipt receipt;
  const _DashReceiptTile({required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: receipt.categoryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_catIcon(receipt.category),
                color: receipt.categoryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(receipt.storeName,
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontWeight: FontWeight.w600, fontSize: 14)),
                Text(receipt.categoryLabel,
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 12, color: AppColors.warmGray)),
              ],
            ),
          ),
          Text('฿${receipt.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'Sarabun',
              fontWeight: FontWeight.w700, fontSize: 15,
              color: AppColors.maroon)),
        ],
      ),
    );
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'shopping':      return Icons.shopping_bag_outlined;
      case 'restaurant':    return Icons.restaurant_outlined;
      case 'beverageBakery': return Icons.local_cafe_outlined;
      default:              return Icons.receipt_outlined;
    }
  }
}

class _LeaderboardCard extends StatelessWidget {
  final MockCustomer customer;
  final int rank;
  const _LeaderboardCard({required this.customer, required this.rank});

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFirst
            ? AppColors.maroon.withOpacity(0.06)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst ? AppColors.maroon.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline,
          width: isFirst ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: rank == 1 ? Colors.amber
                  : rank == 2 ? const Color(0xFFC0C0C0)
                  : rank == 3 ? const Color(0xFFCD7F32)
                  : AppColors.paleBrownLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(Icons.emoji_events,
                      size: 18,
                      color: rank == 1 ? Colors.white : Colors.white70)
                  : Text('$rank',
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.warmGray)),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: customer.avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(customer.avatarInitials,
                style: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(customer.name,
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontWeight: FontWeight.w600, fontSize: 14)),
                    if (customer.isTopSpender) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('WINNER',
                          style: TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 9, fontWeight: FontWeight.w800,
                            color: Colors.white)),
                      ),
                    ],
                  ],
                ),
                Text('จอดรถ ${customer.parkingDaysUsed} ครั้ง',
                  style: const TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 12, color: AppColors.warmGray)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('฿${customer.totalSpend.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontWeight: FontWeight.w700, fontSize: 15,
                  color: AppColors.maroon)),
              if (customer.isTopSpender)
                const Text('ฟรี 3 วัน 🎉',
                  style: TextStyle(
                    fontFamily: 'Sarabun',
                    fontSize: 11, color: AppColors.success,
                    fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
