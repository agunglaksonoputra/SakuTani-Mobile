import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermissions() async {
  if (Platform.isAndroid) {
    // Untuk Android 11+ (API 30+)
    if (await Permission.manageExternalStorage.isGranted) return;

    // Cek permission MANAGE_EXTERNAL_STORAGE (Android 11+)
    final manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) return;

    // Jika ditolak → arahkan ke pengaturan
    if (manageStatus.isPermanentlyDenied) {
      openAppSettings();
      throw Exception("Izin tidak diberikan. Silakan aktifkan secara manual di Pengaturan.");
    }

    // Untuk Android < 11
    final legacyStatus = await Permission.storage.request();
    if (!legacyStatus.isGranted) {
      throw Exception("Izin penyimpanan tidak diberikan.");
    }
  }
}
