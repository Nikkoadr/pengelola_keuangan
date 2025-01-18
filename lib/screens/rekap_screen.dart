import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart';

class RekapScreen extends StatefulWidget {
  const RekapScreen({super.key});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  late DatabaseHelper _dbHelper;
  Future<List<Transaksi>>? _rekapData;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadRekapData();
  }

  void _loadRekapData() {
    setState(() {
      _rekapData = _dbHelper.ambilTransaksi12Bulan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Keuangan'),
        backgroundColor: Colors.blue[500],
      ),
      body: FutureBuilder<List<Transaksi>>(
        future: _rekapData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data transaksi.'));
          }

          List<String> bulanList = [];
          for (var transaksi in snapshot.data!) {
            final bulan = transaksi.tanggal.substring(0, 7);
            if (!bulanList.contains(bulan)) {
              bulanList.add(bulan);
            }
          }

          return ListView(
            children: bulanList.map((bulan) {
              double totalPemasukanBulan = 0;
              double totalPengeluaranBulan = 0;

              final bulanTransaksi = snapshot.data!.where((transaksi) {
                return transaksi.tanggal.substring(0, 7) == bulan;
              }).toList();

              for (var transaksi in bulanTransaksi) {
                if (transaksi.jenis == 'pemasukan') {
                  totalPemasukanBulan += transaksi.jumlah;
                } else if (transaksi.jenis == 'pengeluaran') {
                  totalPengeluaranBulan += transaksi.jumlah;
                }
              }

              double selisih = totalPemasukanBulan - totalPengeluaranBulan;

              String pesan = '';
              Color warnaPesan = Colors.black;

              if (selisih < 0) {
                pesan = 'Pengeluaran lebih besar dari pemasukan! Harap lebih berhati-hati.';
                warnaPesan = Colors.red;
              } else if (selisih > 0) {
                pesan = 'Pemasukan lebih besar dari pengeluaran. Bagus!';
                warnaPesan = Colors.green;
              } else {
                pesan = 'Pemasukan dan pengeluaran seimbang.';
                warnaPesan = Colors.grey;
              }

              String formattedMonth =
              DateFormat('MMM yyyy').format(DateTime.parse('$bulan-01'));

              String formatCurrency(double amount) {
                final formatter = NumberFormat.simpleCurrency(locale: 'id_ID');
                return formatter.format(amount);
              }

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Bulan: $formattedMonth'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pemasukan: ${formatCurrency(totalPemasukanBulan)}'),
                      Text('Pengeluaran: ${formatCurrency(totalPengeluaranBulan)}'),
                      Text('Selisih: ${formatCurrency(selisih)}',
                          style: TextStyle(
                              color: selisih < 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold)),
                      if (pesan.isNotEmpty)
                        Text(pesan, style: TextStyle(color: warnaPesan)),
                    ],
                  ),
                  leading: const Icon(Icons.calendar_today),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmation(context, bulan);
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String bulan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Data Bulan Ini'),
          content: Text('Apakah Anda yakin ingin menghapus semua data di bulan $bulan?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _dbHelper.hapusTransaksiBulan(bulan);
                Navigator.of(context).pop(); // Tutup dialog
                _loadRekapData(); // Refresh data
              },
              child: const Text('Ya', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }
}
