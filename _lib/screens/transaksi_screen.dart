import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db_helper.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  late DatabaseHelper _databaseHelper;
  List<Transaksi> _transaksiList = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadTransaksi();
  }

  Future<void> _loadTransaksi() async {
    final data = await _databaseHelper.ambilTransaksiBulanIni();
    setState(() {
      _transaksiList = data;
    });
  }

  Widget _buildTransactionList() {
    if (_transaksiList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada transaksi bulan ini.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _transaksiList.length,
      itemBuilder: (context, index) {
        final transaksi = _transaksiList[index];
        final isExpense = transaksi.jenis == 'pengeluaran';
        final containerColor = isExpense ? Colors.red[100] : Colors.green[100];
        final textColor = isExpense ? Colors.red[700] : Colors.green[700];

        DateTime tanggalTransaksi = DateTime.parse(transaksi.tanggal);
        String formattedDate = DateFormat('d MMM yyyy HH:mm').format(tanggalTransaksi);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaksi.judul,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${NumberFormat("#,##0", "id_ID").format(transaksi.jumlah)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(context, transaksi),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, transaksi),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, Transaksi transaksi) {
    final TextEditingController judulController =
    TextEditingController(text: transaksi.judul);
    final TextEditingController jumlahController =
    TextEditingController(text: transaksi.jumlah.toString());
    final TextEditingController tanggalController =
    TextEditingController(text: transaksi.tanggal);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Transaksi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              TextField(
                controller: jumlahController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: tanggalController,
                decoration: const InputDecoration(labelText: 'Tanggal'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                final updatedTransaksi = Transaksi(
                  id: transaksi.id,
                  judul: judulController.text,
                  jumlah: double.parse(jumlahController.text),
                  jenis: transaksi.jenis,
                  tanggal: tanggalController.text,
                );
                _databaseHelper.updateTransaksi(updatedTransaksi);
                Navigator.of(context).pop();
                _loadTransaksi();
              },
              child: const Text('Simpan'),
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

  void _showDeleteDialog(BuildContext context, Transaksi transaksi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Transaksi'),
          content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _databaseHelper.hapusTransaksi(transaksi.id!);
                Navigator.of(context).pop();
                _loadTransaksi();
              },
              child: const Text('Ya'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: Colors.blue[500],
      ),
      body: _buildTransactionList(),
    );
  }
}
