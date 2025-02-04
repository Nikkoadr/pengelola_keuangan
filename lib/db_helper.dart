import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Transaksi {
  final int? id;
  final String judul;
  final double jumlah;
  final String jenis;
  final String tanggal;
  final String keterangan;

  Transaksi({
    this.id,
    required this.judul,
    required this.jumlah,
    required this.jenis,
    required this.tanggal,
    required this.keterangan,
  });

  // Convert Transaksi object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'jumlah': jumlah,
      'jenis': jenis,
      'tanggal': tanggal,
      'keterangan': keterangan,
    };
  }

  // Create Transaksi object from Map
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'],
      judul: map['judul'],
      jumlah: (map['jumlah'] as num).toDouble(),
      jenis: map['jenis'],
      tanggal: map['tanggal'],
      keterangan: map['keterangan'],
    );
  }

  @override
  String toString() {
    return 'Transaksi{id: $id, judul: $judul, jumlah: $jumlah, jenis: $jenis, tanggal: $tanggal, keterangan: $keterangan}';
  }
}

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'keuangan.db';
  static const int _version = 1;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDB();
      return _database!;
    }
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, _dbName),
      version: _version,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE transaksi (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      judul TEXT NOT NULL,
      jumlah REAL NOT NULL,
      jenis TEXT NOT NULL,
      tanggal TEXT NOT NULL,
      keterangan TEXT NOT NULL
    )''');
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
        [tableName]);
    return result.isNotEmpty;
  }

  Future<List<Transaksi>> ambilSemuaTransaksi() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transaksi');
    return maps.map((map) => Transaksi.fromMap(map)).toList();
  }

  Future<int> tambahTransaksi(Transaksi transaksi) async {
    final db = await database;
    return await db.insert(
      'transaksi',
      transaksi.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTransaksi(Transaksi transaksi) async {
    final db = await database;
    return await db.update(
      'transaksi',
      transaksi.toMap(),
      where: 'id = ?',
      whereArgs: [transaksi.id],
    );
  }

  Future<int> hapusTransaksi(int id) async {
    final db = await database;
    return await db.delete(
      'transaksi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
      String query, List<dynamic> arguments) async {
    final db = await database;
    return db.rawQuery(query, arguments);
  }

  Future<List<Transaksi>> ambilTransaksi12Bulan() async {
    final db = await database;
    final String query = '''
      SELECT * FROM transaksi
      WHERE strftime('%Y-%m', tanggal) >= strftime('%Y-%m', 'now', '-12 months')
      ORDER BY strftime('%Y-%m', tanggal) DESC
    ''';
    final List<Map<String, dynamic>> maps = await db.rawQuery(query);
    return maps.map((map) => Transaksi.fromMap(map)).toList();
  }

  Future<List<Transaksi>> ambil10TransaksiTerbaru() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      orderBy: 'tanggal DESC',
      limit: 10,
    );
    return maps.map((map) => Transaksi.fromMap(map)).toList();
  }

  Future<List<Transaksi>> ambilTransaksiBulanIni() async {
    final db = await database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);

    final List<Map<String, dynamic>> result = await db.query(
      'transaksi',
      where: 'tanggal >= ? AND tanggal < ?',
      whereArgs: [firstDayOfMonth.toIso8601String(), firstDayOfNextMonth.toIso8601String()],
      orderBy: 'tanggal DESC',
    );

    return result.map((map) => Transaksi.fromMap(map)).toList();
  }

  Future<void> hapusTransaksiBulan(String bulan) async {
    final db = await database;
    final startOfMonth = '$bulan-01';
    final endOfMonth = DateTime.parse(startOfMonth)
        .add(Duration(days: DateTime.parse(startOfMonth).day + 30))
        .toIso8601String();

    await db.delete(
      'transaksi',
      where: 'tanggal >= ? AND tanggal < ?',
      whereArgs: [startOfMonth, endOfMonth],
    );
  }
}
