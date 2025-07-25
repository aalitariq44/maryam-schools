import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ignore: must_be_immutable
class BackupPage extends StatelessWidget {
  String databasePath = '.dart_tool\\sqflite_common_ffi\\databases';

  Future<void> localBackup(BuildContext context) async {
    try {
      final currentDate =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final backupFileName = 'maryam_schools.db';
      final backupFolderName = currentDate;

      showLoadingDialog(context, "جارٍ إنشاء النسخة الاحتياطية المحلية...");

      final sourceFile = File(join(databasePath, 'maryam_schools.db'));
      final destinationDir = Directory('F:\\Backups\\$backupFolderName');
      await destinationDir.create(recursive: true);
      final localBackupFile = File(join(destinationDir.path, backupFileName));
      await sourceFile.copy(localBackupFile.path);

      Navigator.of(context).pop(); // إخفاء دائرة التحميل

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إنشاء النسخة الاحتياطية المحلية بنجاح')),
      );
    } catch (e) {
      handleError(context, e, "خطأ في إنشاء النسخة الاحتياطية المحلية");
    }
  }

  Future<void> onlineBackup(BuildContext context) async {
    try {
      final currentDate =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final backupFileName = 'maryam_schools.db';
      final backupFolderName = currentDate;

      showLoadingDialog(context, "جارٍ رفع النسخة الاحتياطية على الإنترنت...");

      final sourceFile = File(join(databasePath, 'maryam_schools.db'));

      final response = await Supabase.instance.client.storage
          .from('database')
          .upload('$backupFolderName/$backupFileName', sourceFile);

      Navigator.of(context).pop(); // إخفاء دائرة التحميل

      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('تم رفع النسخة الاحتياطية على الإنترنت بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('تم رفع النسخة الاحتياطية على الإنترنت بنجاح')),
        );
      }
    } catch (e) {
      handleError(context, e, "خطأ في رفع النسخة الاحتياطية على الإنترنت");
    }
  }

  void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  void handleError(BuildContext context, dynamic error, String errorMessage) {
    Navigator.of(context).pop(); // إخفاء دائرة التحميل في حالة حدوث خطأ
    print("$errorMessage: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$errorMessage: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إنشاء نسخة احتياطية"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await localBackup(context);
              },
              child: Text("إنشاء نسخة احتياطية محلية"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await onlineBackup(context);
              },
              child: Text("رفع نسخة احتياطية على الإنترنت"),
            ),
          ],
        ),
      ),
    );
  }
}
