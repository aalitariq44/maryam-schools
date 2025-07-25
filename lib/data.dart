import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initDb();
    }
    return _db;
  }

  Future<Database> initDb() async {
    try {
      String databasePath = await getDatabasesPath();
      String path = join(databasePath, 'maryam_schools.db');
      Database myDb = await openDatabase(
        path,
        onCreate: _onCreate,
        version: 10,
        onUpgrade: _onUpgrade,
      );
      return myDb;
    } catch (e) {
      print("Error initializing database: $e");
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE "additionalFees" (
         "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
         "studentId" INTEGER NOT NULL,
         "feeType" TEXT NOT NULL,
         "amount" REAL NOT NULL,
         "paymentDate" TEXT NOT NULL,
         FOREIGN KEY("studentId") REFERENCES "students"("id")
       )
     ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE students ADD COLUMN phoneNumber TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE "appSettings" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "key" TEXT NOT NULL UNIQUE,
          "value" TEXT NOT NULL
        )
      ''');
      await db
          .insert('appSettings', {'key': 'academicYear', 'value': '2023-2024'});
    }
    if (oldVersion < 5) {
      await db.execute(
          'ALTER TABLE additionalFees ADD COLUMN isPaid INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE students ADD COLUMN notes TEXT');
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE additionalFees ADD COLUMN notes TEXT');
    }
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE "students_temp" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "name" TEXT NOT NULL,
          "stage" TEXT NOT NULL,
          "dateCommencement" TEXT,
          "totalInstallment" INT NOT NULL,
          "level" TEXT,
          "stream" TEXT,
          "section" TEXT,
          "phoneNumber" TEXT,
          "notes" TEXT
        )
      ''');
      await db.execute('''
        INSERT INTO students_temp
        SELECT id, name, stage, dateCommencement, totalInstallment, level, stream, section, phoneNumber, notes 
        FROM students
      ''');
      await db.execute('DROP TABLE students');
      await db.execute('ALTER TABLE students_temp RENAME TO students');
    }
    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE "schools" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "name" TEXT NOT NULL
        )
      ''');
      await db.insert('schools', {'name': 'ابتدائية مريم المختلطة'});
      await db.insert('schools', {'name': 'ثانوية مريم للبنات'});
      await db.insert('schools', {'name': 'ثانوية مريم للبنين'});
      await db.execute('ALTER TABLE students ADD COLUMN school TEXT');
    }

    if (oldVersion < 9) {
      await db
          .execute("UPDATE students SET school = 1 WHERE level = 'ابتدائي'");
      await db.execute(
          "UPDATE students SET school = 3 WHERE level IN ('متوسط', 'إعدادي')");
      await db.execute(
          "UPDATE students SET school = 2 WHERE stage = 'الثاني المتوسط' AND section = 'د'");
      await db.execute(
          "UPDATE students SET school = 2 WHERE stage = 'الأول المتوسط' AND section = 'د'");
      await db.execute(
          "UPDATE students SET section = 'أ' WHERE stage = 'الثاني المتوسط' AND section = 'د'");
      print("تم تحديث عمود المدرسة للطلاب");
    }

    if (oldVersion < 10) {
      // إنشاء جدول مؤقت بدون عمود nameStudent
      await db.execute('''
        CREATE TABLE "installments_temp" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "IDStudent" INTEGER NOT NULL,
          "amount" INT NOT NULL,
          "date" TEXT,
          FOREIGN KEY("IDStudent") REFERENCES "students"("id")
        )
      ''');

      // نقل البيانات من الجدول القديم إلى الجدول المؤقت
      await db.execute('''
        INSERT INTO installments_temp (id, IDStudent, amount, date)
        SELECT id, IDStudent, amount, date FROM installments
      ''');

      // حذف الجدول القديم
      await db.execute('DROP TABLE installments');

      // إعادة تسمية الجدول المؤقت
      await db.execute('ALTER TABLE installments_temp RENAME TO installments');

      print("تم حذف عمود nameStudent من جدول installments");
    }
    print("onUpgrade =====================================");
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE "students" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "name" TEXT NOT NULL,
          "stage" TEXT NOT NULL,
          "dateCommencement" TEXT,
          "totalInstallment" INT NOT NULL,
          "level" TEXT,
          "stream" TEXT,
          "section" TEXT,
          "phoneNumber" TEXT,
          "notes" TEXT,
          "school" INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE "installments" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "IDStudent" INTEGER NOT NULL,
          "amount" INT NOT NULL,
          "date" TEXT,
          FOREIGN KEY("IDStudent") REFERENCES "students"("id")
        )
      ''');

      await db.execute('''
        CREATE TABLE "additionalFees" (
         "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
         "studentId" INTEGER NOT NULL,
         "feeType" TEXT NOT NULL,
         "amount" REAL NOT NULL,
         "paymentDate" TEXT NOT NULL,
         "isPaid" INTEGER NOT NULL DEFAULT 0,
         "notes" TEXT,
         FOREIGN KEY("studentId") REFERENCES "students"("id")
       )
     ''');

      await db.execute('''
        CREATE TABLE "appSettings" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "key" TEXT NOT NULL UNIQUE,
          "value" TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE "schools" (
          "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          "name" TEXT NOT NULL
        )
      ''');

      await db
          .insert('appSettings', {'key': 'academicYear', 'value': '2024-2025'});

      await db.insert('schools', {'name': 'ابتدائية مريم المختلطة'});
      await db.insert('schools', {'name': 'ثانوية مريم للبنات'});
      await db.insert('schools', {'name': 'ثانوية مريم للبنين'});

      print("onCreate =====================================");
    } catch (e) {
      print("Error creating tables: $e");
    }
  }

  Future<List<Map>> readData(String sql) async {
    try {
      Database? myDb = await db;
      List<Map> response = await myDb!.rawQuery(sql);
      return response;
    } catch (e) {
      print("Error reading data: $e");
      return [];
    }
  }

  Future<int> insertData(String sql) async {
    try {
      Database? myDb = await db;
      int response = await myDb!.rawInsert(sql);
      return response;
    } catch (e) {
      print("Error inserting data: $e");
      return 0;
    }
  }

  Future<int> updateData(String sql) async {
    try {
      Database? myDb = await db;
      int response = await myDb!.rawUpdate(sql);
      return response;
    } catch (e) {
      print("Error updating data: $e");
      return 0;
    }
  }

  Future<int> deleteData(String sql) async {
    try {
      Database? myDb = await db;
      int response = await myDb!.rawDelete(sql);
      return response;
    } catch (e) {
      print("Error deleting data: $e");
      return 0;
    }
  }

  Future<void> myDeleteDatabase() async {
    try {
      String databasePath = await getDatabasesPath();
      String path = join(databasePath, 'maryam_schools.db');
      await deleteDatabase(path);
    } catch (e) {
      print("Error deleting database: $e");
    }
  }
}
