import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class PhotoRecord {
  const PhotoRecord({
    required this.id,
    required this.path,
    required this.takenAt,
    required this.measuredAt,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.officer,
  });

  final int id;
  final String path;
  final DateTime takenAt;
  final DateTime measuredAt;
  final double latitude;
  final double longitude;
  final double accuracy;
  final String officer;

  factory PhotoRecord.fromMap(Map<String, Object?> row) => PhotoRecord(
        id: row['id'] as int,
        path: row['path'] as String,
        takenAt: DateTime.parse(row['taken_at'] as String),
        measuredAt: DateTime.parse(row['measured_at'] as String),
        latitude: row['latitude'] as double,
        longitude: row['longitude'] as double,
        accuracy: row['accuracy'] as double,
        officer: row['officer'] as String,
      );
}

class PhotoStore {
  PhotoStore._();
  static final PhotoStore instance = PhotoStore._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final directory = await getApplicationDocumentsDirectory();
    _database = await openDatabase(
      p.join(directory.path, 'xiumark.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE photos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT NOT NULL UNIQUE,
            taken_at TEXT NOT NULL,
            measured_at TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            accuracy REAL NOT NULL,
            officer TEXT NOT NULL
          )
        ''');
        await db
            .execute('CREATE INDEX photos_taken_at_idx ON photos(taken_at)');
        await db.execute(
            'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
      },
    );
    return _database!;
  }

  Future<void> add(PhotoRecord photo) async {
    final db = await database;
    await db.insert('photos', {
      'path': photo.path,
      'taken_at': photo.takenAt.toIso8601String(),
      'measured_at': photo.measuredAt.toIso8601String(),
      'latitude': photo.latitude,
      'longitude': photo.longitude,
      'accuracy': photo.accuracy,
      'officer': photo.officer,
    });
  }

  Future<List<PhotoRecord>> all() async {
    final db = await database;
    final rows = await db.query('photos', orderBy: 'taken_at DESC');
    return rows.map(PhotoRecord.fromMap).toList();
  }

  Future<String> privatePhotoDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'photos'));
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory.path;
  }

  Future<String> officerName() async {
    final db = await database;
    final rows = await db.query('settings',
        where: 'key = ?', whereArgs: ['officer_name'], limit: 1);
    return rows.isEmpty ? '' : rows.first['value'] as String;
  }

  Future<void> setOfficerName(String name) async {
    final db = await database;
    await db.insert('settings', {'key': 'officer_name', 'value': name},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<double> accuracyThreshold() async {
    final db = await database;
    final rows = await db.query('settings',
        where: 'key = ?', whereArgs: ['gps_accuracy_m'], limit: 1);
    if (rows.isEmpty) return 5;
    return double.tryParse(rows.first['value'] as String) ?? 5;
  }

  Future<void> setAccuracyThreshold(double meters) async {
    final db = await database;
    await db.insert(
        'settings', {'key': 'gps_accuracy_m', 'value': meters.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
