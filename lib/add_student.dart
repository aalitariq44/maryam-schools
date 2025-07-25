import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:maryams_school_fees/add_students_group.dart';
import 'package:maryams_school_fees/data.dart';

class AddStudent extends StatefulWidget {
  final SqlDb sqlDb;
  final Function readData;
  final int school;

  const AddStudent({
    Key? key,
    required this.sqlDb,
    required this.readData,
    required this.school,
  }) : super(key: key);

  @override
  _AddStudentState createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final totalController = TextEditingController();
  final phoneController = TextEditingController();
  final nameFocusNode = FocusNode();
  DateTime? dateCommencement = DateTime.now();
  String? level = 'ابتدائي';
  String? stage = 'الأول الإبتدائي';
  String? stream;
  String? section = 'أ';
  bool dateCommencementError = false;
  List<String> levels = [];

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
  @override
  void initState() {
    super.initState();
    _setLevels();
    _setTotalInstallment();
    print('${widget.school} رقم المدرسة');
    nameFocusNode.requestFocus();
  }

  void _setLevels() {
    if (widget.school == 1) {
      levels = ['ابتدائي'];
      level = 'ابتدائي';
    } else if (widget.school == 2 || widget.school == 3) {
      levels = ['متوسط', 'إعدادي'];
      level = 'متوسط';
    }
    _updateStage();
  }

  void _updateStage() {
    if (levels.contains(level)) {
      stage = stages[level]!.first;
    } else {
      stage = null;
    }
  }

  void _setTotalInstallment() {
    if (stage == null) return;
    switch (stage) {
      case 'الأول الإبتدائي':
      case 'الثاني الإبتدائي':
      case 'الثالث الإبتدائي':
        totalController.text = '500000';
        break;
      case 'الرابع الإبتدائي':
      case 'الخامس الإبتدائي':
        totalController.text = '600000';
        break;
      case 'السادس الإبتدائي':
        totalController.text = '600000';
        break;
      case 'الأول المتوسط':
        totalController.text = '800000';
        break;
      case 'الثاني المتوسط':
        totalController.text = '850000';
        break;
      case 'الثالث المتوسط':
        totalController.text = '900000';
        break;
      case 'الرابع':
        totalController.text = '1000000';
        break;
      case 'الخامس':
        totalController.text = '1250000';
        break;
      case 'السادس':
        totalController.text = '1500000';
        break;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (dateCommencement != null) {
        String dateCommencementStr =
            DateFormat('yyyy-MM-dd').format(dateCommencement!);
        int response = await widget.sqlDb.insertData(
          "INSERT INTO 'students' ('name', 'stage', 'dateCommencement', 'totalInstallment', 'level', 'stream', 'section', 'phoneNumber', 'school') VALUES ('${nameController.text}', '$stage', '$dateCommencementStr', ${totalController.text}, '$level', '$stream', '$section', '${phoneController.text}', '${widget.school}')",
        );
        if (response > 0) {
          widget.readData();
        }
        print('Response: $response');

        Navigator.pop(context);
        nameController.clear();
        totalController.clear();
        phoneController.clear();
        setState(() {
          dateCommencement = DateTime.now();
          level = 'ابتدائي';
          stage = 'الأول الإبتدائي';
          stream = null;
          section = 'أ';
          dateCommencementError = false;
          _setTotalInstallment();
        });
      } else {
        setState(() {
          dateCommencementError = true;
        });
      }
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      _submitForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKeyEvent,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: FocusTraversalGroup(
              policy: WidgetOrderTraversalPolicy(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text("اضافة معلومات الطالب"),
                  SizedBox(height: 14),
                  TextFormField(
                    controller: nameController,
                    focusNode: nameFocusNode,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
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
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: level,
                    hint: Text('المرحلة'),
                    onChanged: (newValue) {
                      setState(() {
                        level = newValue;
                        _updateStage();
                        stream = null;
                        _setTotalInstallment();
                      });
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
                  SizedBox(height: 10),
                  if (level != null)
                    DropdownButtonFormField<String>(
                      value: stage,
                      hint: Text('الصف'),
                      onChanged: (newValue) {
                        setState(() {
                          stage = newValue;
                          _setTotalInstallment();
                        });
                      },
                      items: stages[level]!.map((stage) {
                        return DropdownMenuItem<String>(
                          value: stage,
                          child: Text(stage),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'يرجى اختيار الصف' : null,
                    ),
                  SizedBox(height: 10),
                  if (level == 'إعدادي')
                    DropdownButtonFormField<String>(
                      value: stream,
                      hint: Text('العلمي - الأدبي'),
                      onChanged: (newValue) {
                        setState(() {
                          stream = newValue;
                        });
                      },
                      items: ['العلمي', 'الأدبي'].map((stream) {
                        return DropdownMenuItem<String>(
                          value: stream,
                          child: Text(stream),
                        );
                      }).toList(),
                      validator: (value) => (level == 'إعدادي' && value == null)
                          ? 'يرجى اختيار الاختصاص'
                          : null,
                    ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: section,
                    hint: Text('الشعبة'),
                    onChanged: (newValue) {
                      setState(() {
                        section = newValue;
                      });
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
                  SizedBox(height: 10),
                  TextFormField(
                    controller: totalController,
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
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitForm(),
                  ),
                  SizedBox(height: 14),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'رقم الهاتف (اختياري)',
                      hintStyle: TextStyle(color: Colors.amber),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 14),
                  Text("تاريخ المباشرة", style: TextStyle(color: Colors.amber)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: dateCommencement ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dateCommencement = pickedDate;
                          dateCommencementError = false;
                        });
                      }
                    },
                    child: Text(dateCommencement == null
                        ? 'اختر تاريخ'
                        : DateFormat('yyyy-MM-dd').format(dateCommencement!)),
                  ),
                  if (dateCommencementError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'يرجى اختيار تاريخ المباشرة',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(height: 20),
                  IconButton(
                    onPressed: _submitForm,
                    icon: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "اضافة",
                          style: TextStyle(fontSize: 20),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddStudentsGroup(
                                  sqlDb: widget.sqlDb,
                                  readData: widget.readData,
                                  school: widget.school,
                                ),
                              ),
                            );
                          },
                          child: Text("إضافة مجموعة"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
