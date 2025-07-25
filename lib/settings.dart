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
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showPromotionDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'الترحيل للعام القادم',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPromotionDialog() async {
    final TextEditingController passwordController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'تأكيد الترحيل للعام القادم',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تحذير: هذه العملية لا يمكن التراجع عنها!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'سيتم تنفيذ العمليات التالية:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('1. ترحيل جميع الطلاب للصفوف التالية'),
              Text('2. حذف جميع الأقساط المدفوعة'),
              Text('3. حذف جميع الرسوم الإضافية'),
              SizedBox(height: 20),
              Text(
                'أدخل كلمة المرور للتأكيد:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                  hintText: 'أدخل كلمة المرور',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (passwordController.text == '1444944494') {
                  Navigator.of(context).pop();
                  await _performStudentPromotion();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('كلمة المرور غير صحيحة'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('تأكيد الترحيل'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performStudentPromotion() async {
    try {
      // إظهار مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('جاري تنفيذ عملية الترحيل...'),
              ],
            ),
          );
        },
      );

      // 1. ترحيل الطلاب للصفوف التالية
      await _promoteStudents();

      // 2. حذف جميع الأقساط
      await sqlDb.deleteData("DELETE FROM installments");

      // 3. حذف جميع الرسوم الإضافية
      await sqlDb.deleteData("DELETE FROM additionalFees");

      Navigator.of(context).pop(); // إغلاق مؤشر التحميل

      // إظهار رسالة النجاح
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'تم الترحيل بنجاح',
              style: TextStyle(color: Colors.green),
            ),
            content: Text(
              'تم ترحيل جميع الطلاب للصفوف التالية وحذف جميع الأقساط والرسوم الإضافية.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('موافق'),
              ),
            ],
          );
        },
      );

    } catch (e) {
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل في حالة الخطأ
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء عملية الترحيل: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _promoteStudents() async {
    // خريطة الترحيل للصفوف
    Map<String, Map<String, dynamic>> promotionMap = {
      // المرحلة الابتدائية
      'الأول الإبتدائي': {'newStage': 'الثاني الإبتدائي', 'newLevel': 'ابتدائي', 'newSchool': 1},
      'الثاني الإبتدائي': {'newStage': 'الثالث الإبتدائي', 'newLevel': 'ابتدائي', 'newSchool': 1},
      'الثالث الإبتدائي': {'newStage': 'الرابع الإبتدائي', 'newLevel': 'ابتدائي', 'newSchool': 1},
      'الرابع الإبتدائي': {'newStage': 'الخامس الإبتدائي', 'newLevel': 'ابتدائي', 'newSchool': 1},
      'الخامس الإبتدائي': {'newStage': 'السادس الإبتدائي', 'newLevel': 'ابتدائي', 'newSchool': 1},
      'السادس الإبتدائي': {'newStage': 'الأول المتوسط', 'newLevel': 'متوسط', 'newSchool': 3},
      
      // المرحلة المتوسطة
      'الأول المتوسط': {'newStage': 'الثاني المتوسط', 'newLevel': 'متوسط', 'newSchool': 3},
      'الثاني المتوسط': {'newStage': 'الثالث المتوسط', 'newLevel': 'متوسط', 'newSchool': 3},
      'الثالث المتوسط': {'newStage': 'الرابع', 'newLevel': 'إعدادي', 'newSchool': 3, 'newStream': 'العلمي'},
      
      // المرحلة الإعدادية
      'الرابع': {'newStage': 'الخامس', 'newLevel': 'إعدادي', 'newSchool': 3},
      'الخامس': {'newStage': 'السادس', 'newLevel': 'إعدادي', 'newSchool': 3},
    };

    // الحصول على جميع الطلاب
    List<Map> students = await sqlDb.readData("SELECT * FROM students");

    for (Map student in students) {
      String currentStage = student['stage'];
      
      if (promotionMap.containsKey(currentStage)) {
        Map<String, dynamic> promotion = promotionMap[currentStage]!;
        
        String updateQuery = '''
          UPDATE students 
          SET stage = '${promotion['newStage']}',
              level = '${promotion['newLevel']}',
              school = ${promotion['newSchool']}
        ''';
        
        // إضافة Stream إذا كان مطلوباً
        if (promotion.containsKey('newStream')) {
          updateQuery += ", stream = '${promotion['newStream']}'";
        }
        
        updateQuery += " WHERE id = ${student['id']}";
        
        await sqlDb.updateData(updateQuery);
      } else if (currentStage == 'السادس') {
        // الطلاب في السادس يتخرجون - يمكن حذفهم أو تركهم كما هم
        // هنا سنتركهم كما هم
        print('الطالب ${student['name']} في الصف السادس - متخرج');
      }
    }
  }
}