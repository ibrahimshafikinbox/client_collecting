// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;

//   DatabaseHelper._internal();

//   factory DatabaseHelper() {
//     return _instance;
//   }

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await initializeDatabase();
//     return _database!;
//   }

//   Future<void> updateCustomerAmount(int customerId, double newAmount) async {
//     final db = await database;
//     await db.update(
//       'customers',
//       {'amount': newAmount},
//       where: 'id = ?',
//       whereArgs: [customerId],
//     );
//     print("Updated customer ID $customerId with amount $newAmount");
//   }

//   Future<Map<String, dynamic>?> getCustomerById(int customerId) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'customers',
//       where: 'id = ?',
//       whereArgs: [customerId],
//     );
//     if (maps.isNotEmpty) {
//       return maps.first;
//     } else {
//       return null;
//     }
//   }

//   Future<Database> initializeDatabase() async {
//     String path = join(await getDatabasesPath(), 'customers.db');
//     return await openDatabase(
//       path,
//       version: 2, // Increment the version number for migration
//       onCreate: (db, version) {
//         return db.execute(
//           '''
//           CREATE TABLE customers(
//             id INTEGER PRIMARY KEY,
//             name TEXT,
//             collect_day INTEGER,
//             nick_name TEXT,
//             phone TEXT,
//             description TEXT,
//             isActive INTEGER,
//             address TEXT,
//             amount REAL
//           )
//           ''',
//         );
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 2) {
//           await db.execute('''
//             ALTER TABLE customers ADD COLUMN amount REAL
//           ''');
//         }
//       },
//     );
//   }

//   Future<void> clearCustomers() async {
//     final db = await database;
//     await db.delete('customers');
//   }

//   Future<void> insertCustomer(Map<String, dynamic> customer) async {
//     final db = await database;
//     await db.insert('customers', customer);
//   }

//   Future<List<Map<String, dynamic>>> getCustomers() async {
//     final db = await database;
//     return await db.query('customers');
//   }
// }
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  // Initialize the database and create necessary tables
  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'customers.db');
    return await openDatabase(
      path,
      version: 3, // Increment version for migration if needed
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers(
            id INTEGER PRIMARY KEY,
            name TEXT,
            collect_day INTEGER,
            nick_name TEXT,
            phone TEXT,
            description TEXT,
            isActive INTEGER,
            address TEXT,
            amount REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE payment_queue(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE customers ADD COLUMN amount REAL
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS payment_queue(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              data TEXT
            )
          ''');
        }
      },
    );
  }

  // Update the customer's amount in the local database
  Future<void> updateCustomerAmount(int customerId, double newAmount) async {
    final db = await database;
    await db.update(
      'customers',
      {'amount': newAmount},
      where: 'id = ?',
      whereArgs: [customerId],
    );
    print("Updated customer ID $customerId with amount $newAmount");
  }

  // Fetch customer data by ID
  Future<Map<String, dynamic>?> getCustomerById(int customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [customerId],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  // Fetch all customers
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await database;
    return await db.query('customers');
  }

  // Insert a new customer into the database
  Future<void> insertCustomer(Map<String, dynamic> customer) async {
    final db = await database;
    await db.insert('customers', customer);
  }

  // Clear all customer data
  Future<void> clearCustomers() async {
    final db = await database;
    await db.delete('customers');
  }

  // Add a payment to the queue
  Future<void> queuePayment(String paymentData) async {
    final db = await database;
    await db.insert('payment_queue', {'data': paymentData});
    print("Payment queued: $paymentData");
  }

  // Fetch all queued payments
  Future<List<Map<String, dynamic>>> getQueuedPayments() async {
    final db = await database;
    return await db.query('payment_queue');
  }

  // Remove a payment from the queue
  Future<void> removePaymentFromQueue(Map<String, dynamic> paymentData) async {
    final db = await database;
    await db.delete(
      'payment_queue',
      where: 'data = ?',
      whereArgs: [jsonEncode(paymentData)],
    );
    print("Payment removed from queue: $paymentData");
  }
}
