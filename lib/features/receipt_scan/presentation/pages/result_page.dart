// lib/features/result/presentation/pages/result_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/data/mockup_data.dart';

class ResultPage extends StatefulWidget {
  final String imagePath;
  final Function(MockReceipt)? onConfirm;
  const ResultPage({super.key, required this.imagePath, this.onConfirm});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  // Explicit animation: check icon
  late AnimationController _checkCtrl;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;

  // Implicit: category badge color
  String _selectedCategory = 'shopping';
  final _formKey = GlobalKey<FormState>();
  final _storeCtrl   = TextEditingController(text: 'Central World');
  final _amountCtrl  = TextEditingController(text: '650');
  final _dateCtrl    = TextEditingController(text: '15/06/2568');

  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    _checkOpacity = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeIn);

    // Simulate ML Kit + Gemini processing
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _checkCtrl.forward();
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _storeCtrl.dispose();
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountCtrl.text) ?? 0;
  int get _freeHoursFromThis {
    if (_amount >= 1000) return 4;
    if (_amount >= 500)  return 2;
    return 0;
  }

  Color get _catColor {
    switch (_selectedCategory) {
      case 'shopping':      return AppColors.catShopping;
      case 'restaurant':    return AppColors.catRestaurant;
      case 'beverageBakery': return AppColors.catBeverage;
      default:              return AppColors.warmGray;
    }
  }

  String get _catLabel {
    switch (_selectedCategory) {
      case 'shopping':      return 'Shopping';
      case 'restaurant':    return 'ร้านอาหาร';
      case 'beverageBakery': return 'เครื่องดื่ม/เบเกอรี่';
      default:              return 'ไม่ระบุ';
    }
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    final receipt = MockReceipt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      storeName: _storeCtrl.text,
      amount: _amount,
      category: _selectedCategory,
      categoryLabel: _catLabel,
      categoryColor: _catColor,
      date: DateTime.now(),
      freeHours: _freeHoursFromThis > 0
          ? '+$_freeHoursFromThis ชม.'
          : '+ยอดสะสม',
      imagePath: widget.imagePath,
    );
    widget.onConfirm?.call(receipt);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('ผลการสแกน'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isProcessing
          ? _buildProcessing()
          : _buildResult(theme, cs),
    );
  }

  Widget _buildProcessing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.maroon.withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: AppColors.maroon, strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('กำลังประมวลผล...',
            style: TextStyle(
              fontFamily: 'Sarabun', fontSize: 16,
              color: AppColors.warmGray,
            ),
          ),
          const SizedBox(height: 8),
          const Text('ML Kit กำลังอ่านข้อความ',
            style: TextStyle(
              fontFamily: 'Sarabun', fontSize: 13,
              color: AppColors.warmGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(ThemeData theme, ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Success header ──────────────────────────────
            FadeTransition(
              opacity: _checkOpacity,
              child: ScaleTransition(
                scale: _checkScale,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.maroon, AppColors.maroonLight],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // Hero: image icon links back to home
                      Hero(
                        tag: 'receipt-icon-new',
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 30),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('สแกนสำเร็จ',
                              style: TextStyle(
                                fontFamily: 'Sarabun',
                                fontSize: 18, fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('AI แยกหมวดหมู่แล้ว กรุณาตรวจสอบ',
                              style: TextStyle(
                                fontFamily: 'Sarabun',
                                fontSize: 13,
                                color: Colors.white.withAlpha((0.8 * 255).round()),
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

            const SizedBox(height: 20),

            // ── Receipt image preview ───────────────────────
            if (widget.imagePath.isNotEmpty &&
                File(widget.imagePath).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(widget.imagePath),
                  height: 160, fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            if (widget.imagePath.isNotEmpty &&
                File(widget.imagePath).existsSync())
              const SizedBox(height: 16),

            // ── Edit form ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('รายละเอียดใบเสร็จ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  // ชื่อร้าน
                  TextFormField(
                    controller: _storeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อร้านค้า',
                      prefixIcon: Icon(Icons.store_outlined,
                          color: AppColors.maroon),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'กรุณาระบุชื่อร้าน' : null,
                  ),
                  const SizedBox(height: 12),

                  // ยอดเงิน
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ยอดรวม (บาท)',
                      prefixIcon: Icon(Icons.payments_outlined,
                          color: AppColors.maroon),
                      prefixText: '฿ ',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'กรุณาระบุยอดเงิน';
                      if (double.tryParse(v) == null) return 'ตัวเลขไม่ถูกต้อง';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // วันที่
                  TextFormField(
                    controller: _dateCtrl,
                    decoration: const InputDecoration(
                      labelText: 'วันที่ในใบเสร็จ',
                      prefixIcon: Icon(Icons.calendar_today_outlined,
                          color: AppColors.maroon),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'กรุณาระบุวันที่' : null,
                  ),
                  const SizedBox(height: 16),

                  // หมวดหมู่
                  Text('หมวดหมู่',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.warmGray)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _CategoryChip(
                        label: 'Shopping',
                        icon: Icons.shopping_bag_outlined,
                        value: 'shopping',
                        selected: _selectedCategory == 'shopping',
                        color: AppColors.catShopping,
                        onTap: () => setState(
                            () => _selectedCategory = 'shopping'),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: 'ร้านอาหาร',
                        icon: Icons.restaurant_outlined,
                        value: 'restaurant',
                        selected: _selectedCategory == 'restaurant',
                        color: AppColors.catRestaurant,
                        onTap: () => setState(
                            () => _selectedCategory = 'restaurant'),
                      ),
                      const SizedBox(width: 8),
                      _CategoryChip(
                        label: 'เครื่องดื่ม',
                        icon: Icons.local_cafe_outlined,
                        value: 'beverageBakery',
                        selected: _selectedCategory == 'beverageBakery',
                        color: AppColors.catBeverage,
                        onTap: () => setState(
                            () => _selectedCategory = 'beverageBakery'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Parking rights preview ──────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _freeHoursFromThis > 0
                    ? AppColors.maroon.withAlpha((0.08 * 255).round())
                    : AppColors.paleBrownLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _freeHoursFromThis > 0
                      ? AppColors.maroon.withAlpha((0.3 * 255).round())
                      : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_parking,
                    color: _freeHoursFromThis > 0
                        ? AppColors.maroon : AppColors.warmGray,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _freeHoursFromThis > 0
                              ? 'ได้รับสิทธิ์จอดฟรีจากใบเสร็จนี้'
                              : 'ยอดสะสมเพื่อสิทธิ์จอดฟรี',
                          style: TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: _freeHoursFromThis > 0
                                ? AppColors.maroon : AppColors.warmGray,
                          ),
                        ),
                        Text(
                          _freeHoursFromThis > 0
                              ? '+$_freeHoursFromThis ชม. (รวม ${1 + _freeHoursFromThis} ชม.)'
                              : 'ต้องการ ฿${_amount < 500 ? (500 - _amount).toStringAsFixed(0) : 0} อีก',
                          style: const TextStyle(
                            fontFamily: 'Sarabun',
                            fontSize: 12, color: AppColors.warmGray),
                        ),
                      ],
                    ),
                  ),
                  if (_freeHoursFromThis > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.maroon,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${1 + _freeHoursFromThis} ชม.',
                        style: const TextStyle(
                          fontFamily: 'Sarabun',
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Confirm button ──────────────────────────────
            ElevatedButton.icon(
              onPressed: _confirm,
              icon: const Icon(Icons.check),
              label: const Text('ยืนยันและบันทึก'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label, required this.icon, required this.value,
    required this.selected, required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? color.withAlpha((0.12 * 255).round()) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : AppColors.divider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : AppColors.warmGray, size: 18),
              const SizedBox(height: 4),
              Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: selected ? color : AppColors.warmGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
