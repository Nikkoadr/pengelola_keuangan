import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart';
import 'form_pemasukan_screen.dart';
import 'form_pengeluaran_screen.dart';
import 'transaksi_screen.dart';
import 'rekap_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DatabaseHelper _databaseHelper;
  late Future<List<Transaksi>> transaksiList;
  late Future<double> totalPemasukan;
  late Future<double> totalPengeluaran;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      transaksiList = _databaseHelper.ambilSemuaTransaksi();
      totalPemasukan = _hitungTotal('pemasukan');
      totalPengeluaran = _hitungTotal('pengeluaran');
    });
  }

  Future<double> _hitungTotal(String jenis) async {
    final result = await _databaseHelper.rawQuery(
      'SELECT SUM(jumlah) as total FROM transaksi WHERE jenis = ?',
      [jenis],
    );
    if (result.isNotEmpty) {
      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }
  
  String formatTanggal(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      return rawDate;
    }
  }
  
  String formatMataUang(double amount) {
    final formatter = NumberFormat.simpleCurrency(locale: 'id_ID');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue[500],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catat Aktivitas Keuangan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<double>(
                    future: totalPemasukan,
                    builder: (context, snapshot) {
                      final pemasukan = snapshot.data ?? 0.0;
                      return _buildBalanceCard(
                          'Total Pemasukan', formatMataUang(pemasukan), Colors.green);
                    },
                  ),
                  FutureBuilder<double>(
                    future: totalPengeluaran,
                    builder: (context, snapshot) {
                      final pengeluaran = snapshot.data ?? 0.0;
                      return _buildBalanceCard(
                          'Total Pengeluaran', formatMataUang(pengeluaran), Colors.red);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    Icons.add_circle_outline,
                    'Pemasukan',
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormPemasukanScreen(),
                        ),
                      ).then((_) => _loadData());
                    },
                  ),
                  _buildActionButton(
                    Icons.remove_circle_outline,
                    'Pengeluaran',
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormPengeluaranScreen(),
                        ),
                      ).then((_) => _loadData());
                    },
                  ),
                  _buildActionButton(
                    Icons.swap_horiz,
                    'Transaksi',
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransaksiScreen(),
                        ),
                      ).then((_) => _loadData());
                    },
                  ),
                  _buildActionButton(Icons.receipt_long, 'Rekap', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RekapScreen(),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Transaksi Terakhir',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Transaksi>>(
                  future: transaksiList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Gagal memuat data.'));
                    } else if (snapshot.data!.isEmpty) {
                      return const Center(child: Text('Tidak ada transaksi.'));
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final transaksi = snapshot.data![index];
                          return _buildTransactionItem(
                            transaksi.judul,
                            formatTanggal(transaksi.tanggal),
                            transaksi.jumlah.toInt(),
                            transaksi.jenis == 'pengeluaran',
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 14)),
            const SizedBox(height: 8),
            Text(amount,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      String title, String date, int amount, bool isExpense) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          isExpense ? Icons.remove_circle : Icons.add_circle,
          color: isExpense ? Colors.red : Colors.green,
        ),
        title: Text(title),
        subtitle: Text(date),
        trailing: Text(
          formatMataUang(amount.toDouble()),
          style: TextStyle(
            color: isExpense ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.blue, size: 32),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
