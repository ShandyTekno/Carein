# AISKIN – Frontend prototype (Flutter)

## Cara pakai di project yang sudah ada
1. Salin folder `lib/` ke project Flutter Anda (timpa `main.dart`, jangan hapus file lain).
2. Tambahkan dependency di `pubspec.yaml`:
   ```yaml
   dependencies:
     google_fonts: ^6.2.1
     image_picker: ^1.1.2
   ```
3. Ganti `test/widget_test.dart` dengan versi di folder ini (test bawaan `MyApp` akan error).
4. `flutter pub get` lalu `flutter run`.

## Project baru
```
flutter create aiskin
```
lalu salin `lib/`, `pubspec.yaml`, dan `test/` dari folder ini.

## Izin platform
- **Android** (`android/app/src/main/AndroidManifest.xml`): pastikan ada
  `<uses-permission android:name="android.permission.INTERNET"/>` (untuk Google Fonts pada build release).
- **iOS** (`ios/Runner/Info.plist`): tambahkan `NSCameraUsageDescription` dan `NSPhotoLibraryUsageDescription`.

## Alur
Splash -> Login -> MainShell (Home / Analysis / History / Profile)
Analysis -> Processing -> Result -> Recommendation
History -> Analysis Detail (ResultScreen)
Semua data ada di `lib/models/dummy_models.dart` (`DummyData`).
