import 'package:flutter/material.dart';
import 'package:maryams_school_fees/data.dart';
import 'package:maryams_school_fees/main.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SqlDb sqlDb = SqlDb();
  final TextEditingController _academicYearController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  String? _currentAcademicYear;
  String? _storedPassword;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    List<Map> academicYearResult = await sqlDb.readData(
        "SELECT value FROM appSettings WHERE key = 'academicYear'");
    List<Map> passwordResult = await sqlDb.readData(
        "SELECT value FROM appSettings WHERE key = 'appPassword'");

    setState(() {
      _currentAcademicYear = academicYearResult.isNotEmpty ? academicYearResult.first['value'] : '';
      _storedPassword = passwordResult.isNotEmpty ? passwordResult.first['value'] : '';
      _academicYearController.text = _currentAcademicYear ?? '';
    });
  }

  Future<void> _updateDarkMode(bool value) async {
    await sqlDb.updateData(
        "UPDATE appSettings SET value = '${value.toString()}' WHERE key = 'darkMode'");
    setState(() {
    });
    Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
  }

  Future<void> _updateAcademicYear() async {
    if (_academicYearController.text.isNotEmpty) {
      await sqlDb.updateData(
          "UPDATE appSettings SET value = '${_academicYearController.text}' WHERE key = 'academicYear'");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث العام الدراسي بنجاح')),
      );
      _loadSettings();
    }
  }

  Future<void> _updatePassword() async {
    if (_oldPasswordController.text == _storedPassword) {
      if (_newPasswordController.text.isNotEmpty) {
        await sqlDb.updateData(
            "UPDATE appSettings SET value = '${_newPasswordController.text}' WHERE key = 'appPassword'");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
        );
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _loadSettings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الرجاء إدخال كلمة المرور الجديدة')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('كلمة المرور القديمة غير صحيحة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('العام الدراسي الحالي: ${_currentAcademicYear ?? "غير محدد"}'),
            SizedBox(height: 10),
            TextField(
              controller: _academicYearController,
              decoration: InputDecoration(
                labelText: 'العام الدراسي الجديد',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateAcademicYear,
              child: Text('تحديث العام الدراسي'),
            ),
            SizedBox(height: 30),
            Text('تغيير كلمة المرور'),
            SizedBox(height: 10),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور القديمة',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updatePassword,
              child: Text('تغيير كلمة المرور'),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الوضع الداكن'),
                Switch(
                  value: themeNotifier.isDarkMode,
                  onChanged: (value) {
                    _updateDarkMode(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}