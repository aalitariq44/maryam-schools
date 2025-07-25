import 'package:flutter/material.dart';
import 'package:maryams_school_fees/app.dart';
import 'package:maryams_school_fees/data.dart';
import 'package:maryams_school_fees/student_acceptance.dart';
import 'package:maryams_school_fees/backup_page.dart';
import 'package:maryams_school_fees/settings.dart';

class SchoolsPage extends StatefulWidget {
  @override
  _SchoolsPageState createState() => _SchoolsPageState();
}

class _SchoolsPageState extends State<SchoolsPage> {
  SqlDb sqlDb = SqlDb();
  List<Map> schools = [];
  int totalStudents = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getSchools();
  }

  void getSchools() async {
    List<Map> response = await sqlDb.readData("SELECT * FROM schools");
    int calculatedTotalStudents = 0;
    for (var school in response) {
      calculatedTotalStudents += (school['student_count'] as int);
    }
    setState(() {
      schools = response;
      totalStudents = calculatedTotalStudents;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المدارس', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'إجمالي الطلاب: $totalStudents',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentAcceptance(),
                ),
              );
            },
            icon: Icon(Icons.app_registration), // Added an icon
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BackupPage(),
                ),
              );
            },
            icon: Icon(Icons.backup),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.blue[700],
      ),
      body: Container(
        decoration: BoxDecoration(),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: schools.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => App(
                              school: schools[index]['id'],
                              schoolName: schools[index]['name'],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue[100],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'images/logo.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            schools[index]['name'],
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'رقم المدرسة: ${schools[index]['id']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'عدد الطلاب: ${schools[index]['student_count']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
