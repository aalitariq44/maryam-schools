import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:maryams_school_fees/academicYear.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StudentAcceptance extends StatefulWidget {
  @override
  _StudentAcceptanceState createState() => _StudentAcceptanceState();
}

class _StudentAcceptanceState extends State<StudentAcceptance> {
  String _selectedSchool = 'مدرسة مريم التكميلية الأهلية';
  String _selectedSchoolEnglish = 'Maryam';

  final Map<String, String> _schoolNameMap = {
    'مدرسة مريم التكميلية الأهلية': 'Maryam',
    'ثانوية مريم الاهلية': 'Maryam',
  };
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _principalNameController =
      TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  String academicYear = AppSettings().academicYear;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d/M/yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Text('قبول الطالب', style: TextStyle(fontFamily: 'Amiri')),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _printDocument(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Maryam',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                              Text(
                                'Schools',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.indigo[100],
                            child: Image.asset(
                              'images/logo.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'وزارة التربية',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                              Text(
                                'المديرية العامة للتعليم الأهلي والأجنبي',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              label: 'العدد',
                              hint: 'أدخل العدد',
                              controller: _numberController,
                              icon: Icons.format_list_numbered,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.blue),
                                SizedBox(width: 5),
                                Text('التاريخ: $formattedDate',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontFamily: 'Amiri',
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.indigo[200], thickness: 1),
                      DropdownButtonFormField<String>(
                        value: _selectedSchool,
                        decoration: InputDecoration(
                          labelText: 'اختر المدرسة',
                          labelStyle: TextStyle(
                              color: Colors.blue, fontFamily: 'Amiri'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: _schoolNameMap.keys.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: TextStyle(fontFamily: 'Amiri')),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSchool = newValue!;
                            _selectedSchoolEnglish = _schoolNameMap[newValue]!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                        label: 'الى مدرسة',
                        hint: 'أدخل اسم المدرسة',
                        controller: _schoolNameController,
                        icon: Icons.school,
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                        label: 'اسم الطالب',
                        hint: 'أدخل اسم الطالب',
                        controller: _studentNameController,
                        icon: Icons.person,
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                        label: 'الصف الدراسي',
                        hint: 'أدخل الصف الدراسي',
                        controller: _classController,
                        icon: Icons.class_,
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                        label: 'اسم مدير المدرسة',
                        hint: 'أدخل اسم مدير المدرسة',
                        controller: _principalNameController,
                        icon: Icons.person_outline,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo[700],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: Colors.white),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'البصرة . الهارثة حي انتصار شارع المدرسة',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Amiri'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          "07732113132 - 07746920218",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: 'Amiri'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printDocument(BuildContext context) async {
    final pdf = await generatePdf();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewScreen(document: pdf),
      ),
    );
  }

  Future<pw.Document> generatePdf() async {
    final pdf = pw.Document();
    final amiriBold = await rootBundle.load("fonts/Amiri-Bold.ttf");
    final ttf = pw.Font.ttf(amiriBold);
    final logoImage = await rootBundle.load('images/logo.png');
    final newtechImage = await rootBundle.load('images/newtech.png');
    String formattedDate = DateFormat('d/M/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 0.5 * PdfPageFormat.cm,
          marginTop: 0.5 * PdfPageFormat.cm,
          marginRight: 0.5 * PdfPageFormat.cm,
          marginBottom: 0.5 * PdfPageFormat.cm,
        ),
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  height: 90,
                  margin: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF3F51B5),
                    border: pw.Border.all(color: PdfColors.white, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              _selectedSchoolEnglish,
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.Text(
                              "Schools",
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        width: 70,
                        alignment: pw.Alignment.center,
                        child: pw.Image(
                            pw.MemoryImage(logoImage.buffer.asUint8List()),
                            width: 70),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              "وزارة التربية",
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white),
                              textAlign: pw.TextAlign.center,
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.Text(
                              "المديرية العامة للتعليم الأهلي والاجنبي",
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white),
                              textAlign: pw.TextAlign.center,
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.Text(
                              _selectedSchool,
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white),
                              textAlign: pw.TextAlign.center,
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                pw.Container(
                  margin: pw.EdgeInsets.symmetric(horizontal: 10),
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("العدد: ${_numberController.text}",
                          style: pw.TextStyle(
                              font: ttf,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold),
                          textDirection: pw.TextDirection.rtl),
                      pw.Text(
                        "التاريخ : ${formattedDate}",
                        style: pw.TextStyle(
                            font: ttf,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Center(),
                      pw.SizedBox(height: 15),
                      pw.Center(
                        child: pw.Text(
                          "إلى / إدارة مدرسة ${_schoolNameController.text}",
                          style: pw.TextStyle(font: ttf, fontSize: 18),
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Center(
                        child: pw.Text(
                          "م / قبول طالب",
                          style: pw.TextStyle(font: ttf, fontSize: 18),
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            "تحية طيبة ... ",
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 18,
                            ),
                            textDirection: pw.TextDirection.rtl,
                            textAlign: pw.TextAlign.right,
                          ),
                          pw.SizedBox(width: 15),
                        ],
                      ),
                      pw.Center(
                        child: pw.RichText(
                          textAlign: pw.TextAlign.center,
                          textDirection: pw.TextDirection.rtl,
                          text: pw.TextSpan(
                            style: pw.TextStyle(font: ttf, fontSize: 18),
                            children: [
                              pw.TextSpan(text: "لا مانع لدينا من قبول "),
                              pw.TextSpan(
                                text: "${_studentNameController.text}",
                                style: pw.TextStyle(color: PdfColors.blue900),
                              ),
                              pw.TextSpan(text: " في الصف "),
                              pw.TextSpan(
                                text: "${_classController.text}",
                                style: pw.TextStyle(color: PdfColors.blue900),
                              ),
                            ],
                          ),
                        ),
                      ),
                      pw.Center(
                        child: pw.RichText(
                          textAlign: pw.TextAlign.center,
                          textDirection: pw.TextDirection.rtl,
                          text: pw.TextSpan(
                            style: pw.TextStyle(font: ttf, fontSize: 18),
                            children: [
                              pw.TextSpan(text: "بمدرستنا للعام الدراسي "),
                              pw.TextSpan(
                                text: academicYear,
                                style: pw.TextStyle(color: PdfColors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Center(
                        child: pw.Text(
                          "مع جزيل الشكر والتقدير ...",
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 18,
                          ),
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  " المستمسكات المطلوبة:",
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 16,
                                    color: PdfColors.red,
                                  ),
                                  textDirection: pw.TextDirection.rtl,
                                ),
                                pw.Text(
                                  "1-جلب وثيقة حديثة من اخر صف.",
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 12,
                                    color: PdfColors.blue900,
                                  ),
                                  textDirection: pw.TextDirection.rtl,
                                ),
                                pw.Text(
                                  "2-جلب صور حديثة عدد ٦.",
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 12,
                                    color: PdfColors.blue900,
                                  ),
                                  textDirection: pw.TextDirection.rtl,
                                ),
                                pw.Text(
                                  "3- جلب المستمسكات (البطاقة الموحدة للطالب- البطاقة الموحدة لوالده - البطاقة الموحدة لولدته ) استنساخ.",
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 12,
                                    color: PdfColors.blue900,
                                  ),
                                  textDirection: pw.TextDirection.rtl,
                                ),
                                pw.Text(
                                  "4- جلب درجات الصف الرابع والصف الخامس اذا كان الطالب في الصف السادس الاعدادي.",
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 12,
                                    color: PdfColors.blue900,
                                  ),
                                  textDirection: pw.TextDirection.rtl,
                                ),
                                pw.Text(
                                  "5-جلب البطاقة المدرسية.",
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 12,
                                    color: PdfColors.blue900,
                                  ),
                                  textDirection: pw.TextDirection.rtl,
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 15),
                        ],
                      ),
                      pw.SizedBox(height: 15),
                      pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Text(
                              "مدير المدرسة",
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold),
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              _principalNameController.text,
                              style: pw.TextStyle(font: ttf, fontSize: 16),
                              textDirection: pw.TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Footer
                pw.Container(
                  width: double.infinity,
                  margin: pw.EdgeInsets.only(top: 20),
                  padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: PdfColor.fromInt(0xFF3F51B5),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'البصرة . الهارثة حي انتصار شارع المدرسة',
                        style: pw.TextStyle(
                            font: ttf, fontSize: 14, color: PdfColors.white),
                        textDirection: pw.TextDirection.rtl,
                      ),
                      pw.Text(
                        "07732113132 - 07746920218",
                        style: pw.TextStyle(
                            font: ttf, fontSize: 14, color: PdfColors.white),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(pw.MemoryImage(newtechImage.buffer.asUint8List()),
                        width: 140),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "برمجة شركة الحلول التقنية الجديدة 07710995922     تليكرام tech_solu@",
                          style: pw.TextStyle(font: ttf, fontSize: 12),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.Text(
                          "تطوير كافة تطبيقات الأندرويد والايفون وسطح المكتب ومواقع الويب وإدارة قواعد البيانات",
                          style: pw.TextStyle(font: ttf, fontSize: 10),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _studentNameController.dispose();
    _classController.dispose();
    _principalNameController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue),
            SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: Colors.blue,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.blue[300], fontFamily: 'Amiri'),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.blue[50],
          ),
          style: TextStyle(color: Colors.blue[800], fontFamily: 'Amiri'),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final pw.Document document;

  const PdfPreviewScreen({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('معاينة المستند'),
      ),
      body: PdfPreview(
        build: (format) => document.save(),
        allowPrinting: true,
        allowSharing: false,
      ),
    );
  }
}
