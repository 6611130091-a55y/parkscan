// lib/core/data/mockup_data.dart
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';

// ── Customer model ───────────────────────────────────────
class MockCustomer {
  final String id;
  final String name;
  final String avatarInitials;
  final Color avatarColor;
  final double totalSpend;
  final int parkingDaysUsed;
  final bool isTopSpender;

  const MockCustomer({
    required this.id,
    required this.name,
    required this.avatarInitials,
    required this.avatarColor,
    required this.totalSpend,
    required this.parkingDaysUsed,
    this.isTopSpender = false,
  });
}

// ── Receipt model ────────────────────────────────────────
class MockReceipt {
  final String id;
  final String storeName;
  final double amount;
  final String category; // shopping | restaurant | beverageBakery
  final String categoryLabel;
  final Color categoryColor;
  final DateTime date;
  final String freeHours;
  final String imagePath;

  const MockReceipt({
    required this.id,
    required this.storeName,
    required this.amount,
    required this.category,
    required this.categoryLabel,
    required this.categoryColor,
    required this.date,
    required this.freeHours,
    this.imagePath = '',
  });
}

// ── Parking History model ────────────────────────────────
class MockParkingHistory {
  final String id;
  final DateTime entryTime;
  final DateTime exitTime;
  final int freeHours;
  final double chargeAmount;
  final double totalSpend;

  const MockParkingHistory({
    required this.id,
    required this.entryTime,
    required this.exitTime,
    required this.freeHours,
    required this.chargeAmount,
    required this.totalSpend,
  });

  int get parkedMinutes => exitTime.difference(entryTime).inMinutes;
}

// ════════════════════════════════════════════════════════
// MOCK DATA
// ════════════════════════════════════════════════════════

class MockupData {
  // ── 5 ลูกค้า ─────────────────────────────────────────
  static const List<MockCustomer> customers = [
    MockCustomer(
      id: 'c1',
      name: 'อริสา วงศ์ทอง',
      avatarInitials: 'อร',
      avatarColor: AppColors.maroon,
      totalSpend: 8450.00,
      parkingDaysUsed: 12,
      isTopSpender: true,
    ),
    MockCustomer(
      id: 'c2',
      name: 'ภัทรพล สุขสวัสดิ์',
      avatarInitials: 'ภท',
      avatarColor: Color(0xFFB85C2A),
      totalSpend: 6200.00,
      parkingDaysUsed: 9,
    ),
    MockCustomer(
      id: 'c3',
      name: 'ณัฐวดี มีสุข',
      avatarInitials: 'ณว',
      avatarColor: Color(0xFF7A9E7E),
      totalSpend: 4875.50,
      parkingDaysUsed: 7,
    ),
    MockCustomer(
      id: 'c4',
      name: 'กิตติศักดิ์ เจริญ',
      avatarInitials: 'กต',
      avatarColor: Color(0xFF4A6B8A),
      totalSpend: 3120.00,
      parkingDaysUsed: 5,
    ),
    MockCustomer(
      id: 'c5',
      name: 'สุภาพร รักดี',
      avatarInitials: 'สภ',
      avatarColor: Color(0xFF8A6B4A),
      totalSpend: 1890.00,
      parkingDaysUsed: 3,
    ),
  ];

  // ── ใบเสร็จวันนี้ (mockup หน้า 1) ────────────────────
  static final List<MockReceipt> todayReceipts = [
    MockReceipt(
      id: 'r1',
      storeName: 'Central World',
      amount: 650.00,
      category: 'shopping',
      categoryLabel: 'Shopping',
      categoryColor: AppColors.catShopping,
      date: DateTime(2025, 6, 15, 10, 30),
      freeHours: 'ฟรี 3 ชม.',
    ),
    MockReceipt(
      id: 'r2',
      storeName: 'After You Dessert',
      amount: 285.00,
      category: 'beverageBakery',
      categoryLabel: 'เครื่องดื่ม/เบเกอรี่',
      categoryColor: AppColors.catBeverage,
      date: DateTime(2025, 6, 15, 12, 15),
      freeHours: '+ยอดสะสม',
    ),
    MockReceipt(
      id: 'r3',
      storeName: 'Sukishi Korean BBQ',
      amount: 420.00,
      category: 'restaurant',
      categoryLabel: 'ร้านอาหาร',
      categoryColor: AppColors.catRestaurant,
      date: DateTime(2025, 6, 15, 13, 45),
      freeHours: '+ยอดสะสม',
    ),
  ];

  // ── ใบเสร็จทั้งหมด (mockup dashboard) ───────────────
  static final List<MockReceipt> allReceipts = [
    ...todayReceipts,
    MockReceipt(
      id: 'r4',
      storeName: 'Tops Supermarket',
      amount: 1250.00,
      category: 'shopping',
      categoryLabel: 'Shopping',
      categoryColor: AppColors.catShopping,
      date: DateTime(2025, 6, 14, 9, 0),
      freeHours: 'ฟรี 5 ชม.',
    ),
    MockReceipt(
      id: 'r5',
      storeName: 'The Coffee Club',
      amount: 180.00,
      category: 'beverageBakery',
      categoryLabel: 'เครื่องดื่ม/เบเกอรี่',
      categoryColor: AppColors.catBeverage,
      date: DateTime(2025, 6, 13, 11, 0),
      freeHours: '+ยอดสะสม',
    ),
    MockReceipt(
      id: 'r6',
      storeName: 'Sizzler',
      amount: 890.00,
      category: 'restaurant',
      categoryLabel: 'ร้านอาหาร',
      categoryColor: AppColors.catRestaurant,
      date: DateTime(2025, 6, 12, 18, 30),
      freeHours: 'ฟรี 3 ชม.',
    ),
  ];

  // ── ประวัติการจอดรถ ───────────────────────────────────
  static final List<MockParkingHistory> parkingHistory = [
    MockParkingHistory(
      id: 'p1',
      entryTime: DateTime(2025, 6, 15, 9, 0),
      exitTime:  DateTime(2025, 6, 15, 14, 30),
      freeHours: 5,
      chargeAmount: 0,
      totalSpend: 1355.00,
    ),
    MockParkingHistory(
      id: 'p2',
      entryTime: DateTime(2025, 6, 14, 10, 0),
      exitTime:  DateTime(2025, 6, 14, 16, 0),
      freeHours: 5,
      chargeAmount: 20,
      totalSpend: 1250.00,
    ),
    MockParkingHistory(
      id: 'p3',
      entryTime: DateTime(2025, 6, 12, 17, 0),
      exitTime:  DateTime(2025, 6, 12, 20, 30),
      freeHours: 3,
      chargeAmount: 0,
      totalSpend: 890.00,
    ),
    MockParkingHistory(
      id: 'p4',
      entryTime: DateTime(2025, 6, 10, 11, 0),
      exitTime:  DateTime(2025, 6, 10, 12, 30),
      freeHours: 1,
      chargeAmount: 0,
      totalSpend: 0,
    ),
  ];

  // ── Dashboard stats ───────────────────────────────────
  static const double monthlyTotal     = 8450.00;
  static const int    totalVisits      = 12;
  static const double avgSpendPerVisit = 704.16;
  static const int    totalFreeHours   = 38;
  static const double savedParkingFees = 760.00;

  // ── Category breakdown (%) ────────────────────────────
  static const Map<String, double> categoryPercent = {
    'Shopping':             52.0,
    'ร้านอาหาร':           31.0,
    'เครื่องดื่ม/เบเกอรี่': 17.0,
  };

  // ── Monthly spend by week ─────────────────────────────
  static const List<double> weeklySpend = [1850, 2340, 2100, 2160];
  static const List<String> weekLabels  = ['สัปดาห์ 1','สัปดาห์ 2','สัปดาห์ 3','สัปดาห์ 4'];
}
