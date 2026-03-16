// lib/features/receipt_scan/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/mockup_data.dart';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  const HomePage({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final _picker = ImagePicker();
  final List<MockReceipt> _receipts = List.from(MockupData.todayReceipts);

  // Explicit animation controller for FAB
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  double get _totalAmount =>
      _receipts.fold(0.0, (s, r) => s + r.amount);
  int get _freeHours {
    if (_totalAmount >= 1000) return 5;
    if (_totalAmount >= 500)  return 3;
    return 1;
  }

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();
    _fabScale = CurvedAnimation(parent: _fabController, curve: Curves.elasticOut);
  }

  @override
  void dispose() { _fabController.dispose(); super.dispose(); }

  Future<void> _addReceipt(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ResultPage(
        imagePath: file.path,
        onConfirm: (receipt) {
          setState(() => _receipts.add(receipt));
        },
      ),
    ));
  }

  void _deleteReceipt(String id) {
    setState(() => _receipts.removeWhere((r) => r.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final isDark = widget.isDark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.maroon,
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: Colors.white,
                ),
                onPressed: widget.onToggleTheme,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.maroon,
                      AppColors.maroonDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.local_parking,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Text('ParkScan',
                              style: TextStyle(
                                fontFamily: 'Sarabun',
                                fontSize: 22, fontWeight: FontWeight.w700,
                                color: Colors.white, letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Implicit: AnimatedContainer for parking status bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.15 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withAlpha((0.3 * 255).round()),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.timer_outlined,
                                  color: Colors.white.withAlpha((0.9 * 255).round()), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ยอดรวมวันนี้ ฿${_totalAmount.toStringAsFixed(0)} → ฟรี $_freeHours ชม.',
                                  style: TextStyle(
                                    fontFamily: 'Sarabun',
                                    fontSize: 13,
                                    color: Colors.white.withAlpha((0.95 * 255).round()),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _totalAmount >= 500
                                      ? AppColors.success
                                      : Colors.white.withAlpha((0.2 * 255).round()),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _totalAmount >= 500 ? '✓ มีสิทธิ์' : 'ยังไม่ถึง',
                                  style: const TextStyle(
                                    fontFamily: 'Sarabun',
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Parking meter card ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _ParkingMeterCard(
                totalAmount: _totalAmount,
                freeHours: _freeHours,
              ),
            ),
          ),

          // ── Section header ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Text('ใบเสร็จวันนี้',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.maroon.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${_receipts.length} รายการ',
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 12,
                        color: AppColors.maroon,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Receipt list ──────────────────────────────────
          _receipts.isEmpty
            ? SliverToBoxAdapter(
                child: _EmptyReceiptPlaceholder(onAdd: () => _showPicker()),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final r = _receipts[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _ReceiptCard(
                        receipt: r,
                        index: i,
                        onDelete: () => _deleteReceipt(r.id),
                      ),
                    );
                  },
                  childCount: _receipts.length,
                ),
              ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ── FAB (Explicit: ScaleTransition) ──────────────────
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton.extended(
          onPressed: _showPicker,
          backgroundColor: AppColors.maroon,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('เพิ่มใบเสร็จ',
            style: TextStyle(fontFamily: 'Sarabun', fontWeight: FontWeight.w600),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.warmGray.withAlpha((0.4 * 255).round()),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('เพิ่มใบเสร็จ',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _PickerOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'ถ่ายรูป',
                    onTap: () {
                      Navigator.pop(context);
                      _addReceipt(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerOption(
                    icon: Icons.photo_library_outlined,
                    label: 'แกลเลอรี่',
                    onTap: () {
                      Navigator.pop(context);
                      _addReceipt(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _ParkingMeterCard extends StatelessWidget {
  final double totalAmount;
  final int freeHours;
  const _ParkingMeterCard({required this.totalAmount, required this.freeHours});

  @override
  Widget build(BuildContext context) {
    final progress = (totalAmount / 1000).clamp(0.0, 1.0);
    final nextThreshold = totalAmount < 500 ? 500 : 1000;
    final remaining = (nextThreshold - totalAmount).clamp(0.0, 1000.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ยอดสะสมวันนี้',
                      style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text('฿${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 28, fontWeight: FontWeight.w700,
                        color: AppColors.maroon,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.maroon,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('ฟรีจอดรถ',
                      style: TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 11, color: Colors.white70)),
                    Text('$freeHours ชม.',
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 20, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Implicit: AnimatedContainer for progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: AppColors.paleBrownLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.maroon),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                remaining > 0
                    ? 'อีก ฿${remaining.toStringAsFixed(0)} เพื่อรับสิทธิ์ถัดไป'
                    : 'ได้รับสิทธิ์สูงสุดแล้ว!',
                style: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 12, color: AppColors.warmGray),
              ),
              Row(
                children: [
                  _ThresholdBadge(label: '฿500', active: totalAmount >= 500),
                  const SizedBox(width: 6),
                  _ThresholdBadge(label: '฿1,000', active: totalAmount >= 1000),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThresholdBadge extends StatelessWidget {
  final String label;
  final bool active;
  const _ThresholdBadge({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.maroon : AppColors.paleBrownLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
        style: TextStyle(
          fontFamily: 'Sarabun',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : AppColors.warmGray,
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatefulWidget {
  final MockReceipt receipt;
  final int index;
  final VoidCallback onDelete;
  const _ReceiptCard({required this.receipt, required this.index, required this.onDelete});

  @override
  State<_ReceiptCard> createState() => _ReceiptCardState();
}

class _ReceiptCardState extends State<_ReceiptCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + widget.index * 80),
    )..forward();
    _slide = Tween<Offset>(
      begin: const Offset(0.3, 0), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final r = widget.receipt;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
            leading: Hero(
              tag: 'receipt-icon-${r.id}',
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: r.categoryColor.withAlpha((0.12 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_categoryIcon(r.category),
                    color: r.categoryColor, size: 22),
              ),
            ),
            title: Text(r.storeName,
              style: const TextStyle(
                fontFamily: 'Sarabun',
                fontWeight: FontWeight.w600, fontSize: 15,
              ),
            ),
            subtitle: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: r.categoryColor.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(r.categoryLabel,
                    style: TextStyle(
                      fontFamily: 'Sarabun',
                      fontSize: 11,
                      color: r.categoryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('฿${r.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontWeight: FontWeight.w700,
                        fontSize: 16, color: AppColors.maroon,
                      ),
                    ),
                    Text(r.freeHours,
                      style: const TextStyle(
                        fontFamily: 'Sarabun',
                        fontSize: 11, color: AppColors.warmGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.warmGray, size: 20),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'shopping':      return Icons.shopping_bag_outlined;
      case 'restaurant':    return Icons.restaurant_outlined;
      case 'beverageBakery': return Icons.local_cafe_outlined;
      default:              return Icons.receipt_outlined;
    }
  }
}

class _EmptyReceiptPlaceholder extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyReceiptPlaceholder({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.paleBrownLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined,
                size: 40, color: AppColors.paleBrownDark),
          ),
          const SizedBox(height: 16),
          Text('ยังไม่มีใบเสร็จ',
            style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('กดปุ่มด้านล่างเพื่อถ่ายหรือเลือกใบเสร็จ',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มใบเสร็จ'),
          ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.paleBrownLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.maroon, size: 28),
            const SizedBox(height: 8),
            Text(label,
              style: const TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
