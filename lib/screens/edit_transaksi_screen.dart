import 'package:flutter/material.dart';
import '../db_helper.dart';

class EditTransaksiScreen extends StatefulWidget {
  final Transaksi transaksi;

  const EditTransaksiScreen({super.key, required this.transaksi});

  @override
  State<EditTransaksiScreen> createState() => _EditTransaksiScreenState();
}

class _EditTransaksiScreenState extends State<EditTransaksiScreen> {
  late TextEditingController _judulController;
  late TextEditingController _jumlahController;
  late String _jenis;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.transaksi.judul);
    _jumlahController = TextEditingController(text: widget.transaksi.jumlah.toString());
    _jenis = widget.transaksi.jenis;
  }

  Future<void> _updateTransaksi() async {
    final judul = _judulController.text;
    final jumlah = double.tryParse(_jumlahController.text) ?? 0.0;

    if (judul.isNotEmpty && jumlah > 0) {
      final transaksiUpdated = Transaksi(
        id: widget.transaksi.id,
        judul: judul,
        jumlah: jumlah,
        jenis: _jenis,
        tanggal: widget.transaksi.tanggal,
      );
      await _dbHelper.tambahTransaksi(transaksiUpdated);
      Navigator.pop(context, transaksiUpdated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap isi semua data dengan benar.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _judulController,
              decoration: const InputDecoration(labelText: 'Judul Transaksi'),
            ),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah'),
            ),
            DropdownButton<String>(
              value: _jenis,
              items: [
                DropdownMenuItem(value: 'pemasukan', child: Text('Pemasukan')),
                DropdownMenuItem(value: 'pengeluaran', child: Text('Pengeluaran')),
              ],
              onChanged: (value) {
                setState(() {
                  _jenis = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: _updateTransaksi,
              child: const Text('Update Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}
