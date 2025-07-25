import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maryams_school_fees/data.dart';

class AddStudentsGroup extends StatefulWidget {
  final SqlDb sqlDb;
  final Function readData;
  final int school;

  const AddStudentsGroup({
    Key? key,
    required this.sqlDb,
    required this.readData,
    required this.school,
  }) : super(key: key);

  @override
  _AddStudentsGroupState createState() => _AddStudentsGroupState();
}

class _AddStudentsGroupState extends State<AddStudentsGroup> {
  final _formKey = GlobalKey<FormState>();
  final List<StudentField> studentFields = [];

  late List<String> levels;
  final List<String> sections = ['أ', 'ب', 'ج', 'د'];
  final Map<String, List<String>> stages = {
    'ابتدائي': [
      'الأول الإبتدائي',
      'الثاني الإبتدائي',
      'الثالث الإبتدائي',
      'الرابع الإبتدائي',
      'الخامس الإبتدائي',
      'السادس الإبتدائي'
    ],
    'متوسط': ['الأول المتوسط', 'الثاني المتوسط', 'الثالث المتوسط'],
    'إعدادي': [
      'الرابع',
      'الخامس',
      'السادس',
    ],
  };

  void _setLevels() {
    if (widget.school == 1) {
      levels = ['ابتدائي'];
    } else if (widget.school == 2 || widget.school == 3) {
      levels = ['متوسط', 'إعدادي'];
    }
  }

  @override
  void initState() {
    super.initState();
    _setLevels();
    _addStudentField();
    print('${widget.school} رقم المدرسة');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(studentFields.first.nameFocusNode);
    });
  }

  void _addStudentField() {
    setState(() {
      if (studentFields.isEmpty) {
        studentFields.add(StudentField(
          nameController: TextEditingController(),
          totalController: TextEditingController(),
          phoneNumberController: TextEditingController(),
          nameFocusNode: FocusNode(),
          level: levels.first,
          stage: stages[levels.first]!.first,
          section: 'أ',
          dateCommencement: DateTime.now(),
        ));
      } else {
        var lastStudentField = studentFields.last;
        studentFields.add(StudentField(
          nameController: TextEditingController(),
          totalController: TextEditingController(
              text: lastStudentField.totalController.text),
          phoneNumberController: TextEditingController(),
          nameFocusNode: FocusNode(),
          level: lastStudentField.level,
          stage: lastStudentField.stage,
          section: lastStudentField.section,
          dateCommencement: lastStudentField.dateCommencement,
          stream: lastStudentField.stream,
        ));
      }

      // تركيز الانتباه على حقل الاسم الرباعي للصف الجديد
      WidgetsBinding.instance.addPostFrameCallback((_) {
        studentFields.last.nameFocusNode.requestFocus();
      });
    });
  }

  void _removeStudentField(int index) {
    setState(() {
      studentFields.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة مجموعة طلاب"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text("اضافة معلومات الطلاب"),
                SizedBox(height: 14),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: studentFields.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: StudentFormField(
                            studentField: studentFields[index],
                            levels: levels,
                            stages: stages,
                            sections: sections,
                            onRemove: () => _removeStudentField(index),
                            onUpdate: () {
                              setState(() {});
                            },
                          ),
                        ),
                        Divider(
                          color: Colors.white,
                          thickness: 2,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 10),
                IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: _addStudentField,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      for (var studentField in studentFields) {
                        String dateCommencementStr = DateFormat('yyyy-MM-dd')
                            .format(studentField.dateCommencement!);
                        int response = await widget.sqlDb.insertData(
                          "INSERT INTO 'students' ('name', 'stage', 'dateCommencement', 'totalInstallment', 'level', 'stream', 'section', 'phoneNumber', 'school') VALUES ('${studentField.nameController.text}', '${studentField.stage}', '$dateCommencementStr', ${studentField.totalController.text}, '${studentField.level}', '${studentField.stream}', '${studentField.section}', '${studentField.phoneNumberController.text}' , '${widget.school}')",
                        );
                        print('Response: $response');
                      }
                      widget
                          .readData(); // تحديث البيانات بعد إدخال الطلاب الجدد
                      Navigator.pop(context);
                    }
                  },
                  child: Text("إضافة المجموعة"),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var field in studentFields) {
      field.nameFocusNode.dispose();
    }
    super.dispose();
  }
}

class StudentField {
  final TextEditingController nameController;
  final TextEditingController totalController;
  final TextEditingController phoneNumberController;
  final FocusNode nameFocusNode;

  DateTime? dateCommencement;
  String level;
  String stage;
  String? stream;
  String section;

  StudentField({
    required this.nameController,
    required this.totalController,
    required this.phoneNumberController,
    required this.nameFocusNode,
    required this.level,
    required this.stage,
    this.stream,
    required this.section,
    this.dateCommencement,
  });
}

class StudentFormField extends StatelessWidget {
  final StudentField studentField;
  final List<String> levels;
  final Map<String, List<String>> stages;
  final List<String> sections;
  final VoidCallback onRemove;
  final VoidCallback onUpdate;

  const StudentFormField({
    Key? key,
    required this.studentField,
    required this.levels,
    required this.stages,
    required this.sections,
    required this.onRemove,
    required this.onUpdate,
  }) : super(key: key);

  void _setTotalInstallment() {
    switch (studentField.stage) {
      case 'الأول الإبتدائي':
      case 'الثاني الإبتدائي':
      case 'الثالث الإبتدائي':
        studentField.totalController.text = '500000';
        break;
      case 'الرابع الإبتدائي':
      case 'الخامس الإبتدائي':
        studentField.totalController.text = '600000';
        break;
      case 'السادس الإبتدائي':
        studentField.totalController.text = '650000';
        break;
      case 'الأول المتوسط':
        studentField.totalController.text = '700000';
        break;
      case 'الثاني المتوسط':
        studentField.totalController.text = '800000';
        break;
      case 'الثالث المتوسط':
        studentField.totalController.text = '900000';
        break;
      case 'الرابع':
        studentField.totalController.text = '1000000';
        break;
      case 'الخامس':
        studentField.totalController.text = '1100000';
        break;
      case 'السادس':
        studentField.totalController.text = '1250000';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: studentField.nameController,
                focusNode: studentField.nameFocusNode,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: 'الاسم الرباعي',
                  hintStyle: TextStyle(color: Colors.amber),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم الرباعي';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: studentField.level,
                hint: Text('المرحلة'),
                onChanged: (newValue) {
                  studentField.level = newValue!;
                  studentField.stage = stages[studentField.level]!.first;
                  studentField.stream = null;
                  _setTotalInstallment();
                  onUpdate();
                },
                items: levels.map((level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'يرجى اختيار المرحلة' : null,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: studentField.stage,
                hint: Text('الصف'),
                onChanged: (newValue) {
                  studentField.stage = newValue!;
                  _setTotalInstallment();
                  onUpdate();
                },
                items: stages[studentField.level]!.map((stage) {
                  return DropdownMenuItem<String>(
                    value: stage,
                    child: Text(stage),
                  );
                }).toList(),
                validator: (value) => value == null ? 'يرجى اختيار الصف' : null,
              ),
            ),
            SizedBox(width: 10),
            if (studentField.level == 'إعدادي')
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: studentField.stream,
                  hint: Text('العلمي - الأدبي'),
                  onChanged: (newValue) {
                    studentField.stream = newValue!;
                    onUpdate();
                  },
                  items: ['العلمي', 'الأدبي'].map((stream) {
                    return DropdownMenuItem<String>(
                      value: stream,
                      child: Text(stream),
                    );
                  }).toList(),
                  validator: (value) =>
                      (studentField.level == 'إعدادي' && value == null)
                          ? 'يرجى اختيار الاختصاص'
                          : null,
                ),
              ),
            if (studentField.level == 'إعدادي') SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: studentField.section,
                hint: Text('الشعبة'),
                onChanged: (newValue) {
                  studentField.section = newValue!;
                  onUpdate();
                },
                items: sections.map((section) {
                  return DropdownMenuItem<String>(
                    value: section,
                    child: Text(section),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'يرجى اختيار الشعبة' : null,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: studentField.totalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'القسط الكلي',
                  hintStyle: TextStyle(color: Colors.amber),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال القسط الكلي';
                  }
                  if (int.tryParse(value) == null) {
                    return 'يرجى إدخال رقم صالح';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: studentField.phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'رقم الهاتف (اختياري)',
                  hintStyle: TextStyle(color: Colors.amber),
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: studentField.dateCommencement ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  studentField.dateCommencement = pickedDate;
                  onUpdate();
                }
              },
              child: Text(studentField.dateCommencement == null
                  ? 'اختر تاريخ'
                  : DateFormat('yyyy-MM-dd')
                      .format(studentField.dateCommencement!)),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: onRemove,
            ),
          ],
        ),
      ],
    );
  }
}
