import 'package:flutter/material.dart';
import 'package:maryams_school_fees/data.dart';

class AllInstallments extends StatefulWidget {
  final int school;

  const AllInstallments({super.key, required this.school});

  @override
  State<AllInstallments> createState() => _AllInstallmentsState();
}

class _AllInstallmentsState extends State<AllInstallments> {
  SqlDb sqlDb = SqlDb();
  bool isLoading = true;
  List<Map<String, Object?>> installments = [];
  int totalAmount = 0;

  Future readData() async {
    List<Map> response = await sqlDb.readData(
      '''
      SELECT installments.*, students.name, students.school, students.stage, students.stream, students.section
      FROM installments 
      INNER JOIN students ON installments.IDStudent = students.id
      WHERE students.school = ${widget.school}
      '''
    );
    setState(() {
      installments = response.cast<Map<String, Object?>>();
      totalAmount = installments.fold(0, (sum, item) => sum + (int.tryParse(item['amount'].toString()) ?? 0));
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Colors.white);
    final headerTextStyle = textStyle.copyWith(
      color: Colors.white,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("جميع الاقساط"),
        actions: [
          Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "المجموع الكلي: $totalAmount الف دينار عراقي",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        SizedBox(width: 20,)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (installments.isEmpty)
              Center(child: Text("لا توجد أقساط لهذه المدرسة"))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: installments.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    var installment = installments[index];
                    return Container(
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 25, 2, 79),
                      ),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4),
                                  margin: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(color: Colors.amber),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                                Text(
                                  "اسم الطالب: ",
                                  style: textStyle,
                                ),
                                Text(
                                  "${installment['name']}",
                                  style: textStyle,
                                ),
                                Spacer(),
                                Text(
                                  "رقم المدرسة: ${installment['school']}",
                                  style: textStyle,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "الصف: ${installment['stage']}",
                                  style: textStyle,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "${installment['stream'] == "null" ? '' : installment['stream']}",
                                  style: textStyle,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "الشعبة: ${installment['section'] ?? 'غير محدد'}",
                                  style: textStyle,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "مبلغ القسط: ",
                                  style: textStyle,
                                ),
                                Text(
                                  "${installment['amount']}",
                                  style: textStyle,
                                ),
                                Text(
                                  "  الف دينار عراقي   ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Spacer(),
                                Text(
                                  "${installment['date']}",
                                  style: headerTextStyle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}