import 'package:flutter/material.dart';
import '../db_helper.dart';

class FormPemasukanScreen extends StatefulWidget {
  const FormPemasukanScreen({super.key});

  @override
  State<FormPemasukanScreen> createState() => _FormPemasukanScreenState();
}

class _FormPemasukanScreenState extends State<FormPemasukanScreen> {
  final _judulController = TextEditingController();
  final _jumlahController = TextEditingController();
  String _tanggal = DateTime.now().toIso8601String();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _simpanPemasukan() async {
    final judul = _judulController.text;
    final jumlah = double.tryParse(_jumlahController.text) ?? 0.0;

    if (judul.isNotEmpty && jumlah > 0) {
      final transaksiBaru = Transaksi(
        judul: judul,
        jumlah: jumlah,
        jenis: 'pemasukan',
        tanggal: _tanggal,
      );
      await _dbHelper.tambahTransaksi(transaksiBaru);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap isi semua data dengan benar.'),
      ));
    }
  }

  Future<void> _pilihTanggal() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _tanggal = selectedDate.toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pemasukan'),
        backgroundColor: Colors.blue[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tanggal: ${_tanggal.substring(0, 10)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.blue),
                    onPressed: _pilihTanggal,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _judulController,
                decoration: InputDecoration(
                  labelText: 'Judul Pemasukan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _simpanPemasukan,
                  child: const Text(
                    'Simpan Pemasukan',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
