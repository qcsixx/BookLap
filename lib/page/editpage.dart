import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/employee.dart';
import '../services/firebase_crud.dart';

class EditPage extends StatefulWidget {
  final BookingLapBasket? bookingLapBasket;
  const EditPage({super.key, this.bookingLapBasket});

  @override
  State<StatefulWidget> createState() {
    return _EditPage();
  }
}

class _EditPage extends State<EditPage> {
  final _nama = TextEditingController();
  final _notelp = TextEditingController();
  final _nolap = TextEditingController();

  // Simpan docId sebagai String biasa — tidak perlu Controller
  String _docId = '';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _docId = widget.bookingLapBasket?.uid ?? '';
    _nama.text = widget.bookingLapBasket?.nama ?? '';
    _notelp.text = widget.bookingLapBasket?.notelp ?? '';
    _nolap.text = widget.bookingLapBasket?.nolap ?? '';
  }

  @override
  void dispose() {
    _nama.dispose();
    _notelp.dispose();
    _nolap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Booking'),
        backgroundColor: cs.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Header
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_note_rounded, size: 50, color: cs.onTertiaryContainer),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Edit Data Booking',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Perbarui informasi booking di bawah ini',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 32),

              // Nama Field
              TextFormField(
                controller: _nama,
                autofocus: false,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama pemesan wajib diisi';
                  }
                  if (value.trim().length < 3) {
                    return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Nama Pemesan',
                  hintText: 'Contoh: Budi Santoso',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              // No Telp Field
              TextFormField(
                controller: _notelp,
                autofocus: false,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor telepon wajib diisi';
                  }
                  if (value.trim().length < 10) {
                    return 'Nomor telepon minimal 10 digit';
                  }
                  if (value.trim().length > 13) {
                    return 'Nomor telepon maksimal 13 digit';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  hintText: 'Contoh: 0812xxxxxxxx',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // No Lapangan Field
              TextFormField(
                controller: _nolap,
                autofocus: false,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor lapangan wajib diisi';
                  }
                  final num = int.tryParse(value.trim());
                  if (num == null || num <= 0) {
                    return 'Masukkan nomor lapangan yang valid (angka positif)';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Nomor Lapangan',
                  hintText: 'Contoh: 1',
                  prefixIcon: Icon(Icons.grid_3x3_outlined),
                ),
              ),
              const SizedBox(height: 40),

              // Update Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save_outlined),
                      label: const Text(
                        'Perbarui Booking',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.tertiary,
                        foregroundColor: cs.onTertiary,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          var response = await FirebaseCrud.updateBookingLapBasket(
                            nama: _nama.text.trim(),
                            notelp: _notelp.text.trim(),
                            nolap: _nolap.text.trim(),
                            docId: _docId,
                          );
                          if (!mounted) return;
                          setState(() => _isLoading = false);
                          if (response.code != 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response.message.toString()),
                                backgroundColor: Colors.red.shade700,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(response.message.toString()),
                                ]),
                                backgroundColor: Colors.green.shade700,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}