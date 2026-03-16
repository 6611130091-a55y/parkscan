# 🅿️ ParkScan

**Smart Parking Receipt Scanner** — สแกนใบเสร็จ AI แยกหมวดหมู่ คำนวณสิทธิ์จอดรถฟรี

---

## 📁 โครงสร้างโปรเจค (Clean Architecture)

```
lib/
├── core/
│   ├── di/           injection.dart        ← get_it
│   ├── error/        failures.dart         ← Failure classes
│   ├── theme/        app_theme.dart        ← Maroon & Pale Brown
│   ├── data/         mockup_data.dart      ← Mock data
│   └── utils/        parking_calculator.dart
│
├── features/
│   ├── receipt_scan/
│   │   ├── domain/
│   │   │   ├── entities/   receipt.dart, parking_session.dart
│   │   │   ├── repositories/ receipt_repository.dart (abstract)
│   │   │   └── usecases/   usecases.dart
│   │   ├── data/
│   │   │   ├── models/     receipt_model.dart (freezed)
│   │   │   │               parking_session_model.dart (freezed)
│   │   │   ├── datasources/
│   │   │   │   ├── local/  app_database.dart (sqflite)
│   │   │   │   │           ml_kit_ds.dart
│   │   │   │   └── remote/ gemini_ds.dart + Hive cache
│   │   │   └── repositories/ receipt_repository_impl.dart
│   │   └── presentation/
│   │       ├── bloc/       scan_bloc.dart (BLoC)
│   │       └── pages/      home_page.dart, result_page.dart
│   │
│   ├── dashboard/
│   │   └── presentation/pages/ dashboard_page.dart
│   │
│   └── history/
│       └── presentation/pages/ history_page.dart
│
├── main_shell.dart   ← Bottom navigation
└── main.dart         ← Entry point

test/
├── unit/   parking_calculator_test.dart
│           scan_bloc_test.dart
└── widget/ result_page_test.dart

integration_test/
└── app_test.dart
```

---

## 🚀 ขั้นตอนติดตั้ง

### 1. สร้าง Flutter Project

```bash
flutter create parkscan
cd parkscan
```

### 2. ลบ lib/ และ test/ เดิมออก

```bash
rm -rf lib/ test/
```

### 3. แตก ZIP แล้วคัดลอกไฟล์ทับ

```
ZIP/lib/              → parkscan/lib/
ZIP/test/             → parkscan/test/
ZIP/integration_test/ → parkscan/integration_test/
ZIP/pubspec.yaml      → parkscan/pubspec.yaml
ZIP/.gitignore        → parkscan/.gitignore
ZIP/.env.example      → parkscan/.env.example
ZIP/README.md         → parkscan/README.md
```

### 4. ดาวน์โหลด Font Sarabun

ไปที่ https://fonts.google.com/specimen/Sarabun
ดาวน์โหลดแล้วสร้างโฟลเดอร์ `fonts/` และวางไฟล์:
```
parkscan/fonts/Sarabun-Regular.ttf
parkscan/fonts/Sarabun-Medium.ttf
parkscan/fonts/Sarabun-SemiBold.ttf
parkscan/fonts/Sarabun-Bold.ttf
```

### 5. สร้างไฟล์ .env

```bash
cp .env.example .env
```

เปิดไฟล์ `.env` แล้วใส่:
```
GEMINI_API_KEY=AIzaSy...key ของคุณ
```

> ขอ Key ฟรีที่: https://aistudio.google.com/app/apikey

### 6. ติดตั้ง packages

```bash
flutter pub get
```

### 7. Generate freezed files ⚠️ ห้ามข้าม!

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

รอจนเห็น `build succeeded`

### 8. ตั้งค่า Android

**android/app/build.gradle:**
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

**android/app/src/main/AndroidManifest.xml** เพิ่มก่อน `<application`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### 9. ตั้งค่า iOS (ถ้าจะรัน iPhone)

**ios/Runner/Info.plist** เพิ่ม:
```xml
<key>NSCameraUsageDescription</key>
<string>ต้องการกล้องเพื่อถ่ายใบเสร็จ</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ต้องการเข้าถึงรูปภาพเพื่อเลือกใบเสร็จ</string>
```

**ios/Podfile:**
```ruby
platform :ios, '14.0'
```

```bash
cd ios && pod install && cd ..
```

### 10. รันแอป

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## 🧪 รัน Tests

```bash
# Unit Tests
flutter test test/unit/

# Widget Tests
flutter test test/widget/

# ทั้งหมด + coverage
flutter test --coverage

# Integration Test (ต้องเปิด emulator ก่อน)
flutter test integration_test/app_test.dart
```

---

## 🅿️ กฎการจอดรถ

| ยอดซื้อ | สิทธิ์ฟรี | รวมฟรี |
|---|---|---|
| ฿0–฿499   | 0 ชม.  | **1 ชม.** (แรกเข้าเสมอ) |
| ฿500–฿999 | 2 ชม.  | **3 ชม.** |
| ฿1,000+   | 4 ชม.  | **5 ชม.** |

- เกินชม.ฟรี → **ชม.ละ ฿20** (ปัดขึ้น)
- วันที่ในใบเสร็จต้องตรงวันเข้าจอด
- Top Spender รายเดือน → จอดฟรี **3 วัน**

---

## 🎨 Color Theme

**Maroon & Pale Brown** — `#6B0F1A` + `#D4B8A8`
รองรับ Light / Dark mode, บันทึกใน SharedPreferences

---

## ❗ แก้ปัญหาที่พบบ่อย

**build_runner ล้มเหลว:**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**minSdkVersion error:**
แก้ `android/app/build.gradle` → `minSdkVersion 21`

**Gemini 403 error:**
ตรวจสอบ `.env` ว่า key ถูกต้องและไม่มีช่องว่าง

**ML Kit ไม่ทำงานบน iOS Simulator:**
ต้องใช้ **อุปกรณ์จริง** เท่านั้น
