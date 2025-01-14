import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart';

class RekapScreen extends StatelessWidget {
  const RekapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Keuangan'),
        backgroundColor: Colors.blue[500],
      ),
      body: FutureBuilder<List<Transaksi>>(
        future: dbHelper.ambilTransaksi12Bulan(),
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

              String pesan = '';
              Color warnaPesan = Colors.black;

              if (totalPengeluaranBulan > totalPemasukanBulan) {
                pesan = 'Pengeluaran lebih besar dari pemasukan! Harap lebih berhati-hati.';
                warnaPesan = Colors.red;
              } else if (totalPemasukanBulan > totalPengeluaranBulan) {
                pesan = 'Pemasukan lebih besar dari pengeluaran. Bagus!';
                warnaPesan = Colors.green;
              } else {
                pesan = 'Pemasukan dan pengeluaran seimbang.';
                warnaPesan = Colors.grey;
              }

              String formattedMonth = DateFormat('MMM yyyy').format(DateTime.parse('$bulan-01'));

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
                      if (pesan.isNotEmpty)
                        Text(pesan, style: TextStyle(color: warnaPesan)),
                    ],
                  ),
                  leading: const Icon(Icons.calendar_today),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
