import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_cruddemo/models/employee.dart';
import 'package:fl_cruddemo/page/addpage.dart';
import 'package:fl_cruddemo/page/editpage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/firebase_crud.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ListPage();
  }
}

class _ListPage extends State<ListPage> {
  final Stream<QuerySnapshot> collectionReference = FirebaseCrud.readBookingLapBasket();

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return '-';
    try {
      final date = (ts as Timestamp).toDate();
      return DateFormat('dd MMM yyyy, HH:mm', 'id').format(date);
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_basketball, color: cs.primary, size: 26),
            const SizedBox(width: 8),
            const Text("Booking Lapangan", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: cs.surface,
      ),
      body: StreamBuilder(
        stream: collectionReference,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 64, color: cs.error),
                  const SizedBox(height: 16),
                  Text("Terjadi kesalahan koneksi", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text("${snapshot.error}", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_basketball_outlined, size: 80, color: cs.primary.withOpacity(0.4)),
                  const SizedBox(height: 20),
                  Text(
                    "Belum ada booking",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tekan tombol + untuk membuat booking baru",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var e = snapshot.data!.docs[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: cs.primaryContainer,
                          child: Text(
                            e["nolap"]?.toString() ?? '?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ),
                        title: Text(
                          e["nama"] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(Icons.phone_outlined, size: 14, color: cs.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(e['notelp'] ?? '-', style: TextStyle(color: cs.onSurfaceVariant)),
                            ]),
                            const SizedBox(height: 2),
                            Row(children: [
                              Icon(Icons.calendar_today_outlined, size: 14, color: cs.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimestamp(e['createdAt']),
                                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                              ),
                            ]),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Lap. ${e["nolap"]}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: cs.onSecondaryContainer,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const Divider(indent: 16, endIndent: 16, height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Edit'),
                              style: TextButton.styleFrom(foregroundColor: cs.primary),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => EditPage(
                                      bookingLapBasket: BookingLapBasket(
                                        uid: e.id,
                                        nama: e["nama"],
                                        notelp: e["notelp"],
                                        nolap: e["nolap"],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('Hapus'),
                              style: TextButton.styleFrom(foregroundColor: cs.error),
                              onPressed: () async {
                                bool? confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    icon: const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.orange),
                                    title: const Text("Hapus Booking?"),
                                    content: Text("Booking atas nama \"${e["nama"]}\" akan dihapus secara permanen."),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text("Batal"),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                        child: const Text("Hapus"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  var response = await FirebaseCrud.deleteBookingLapBasket(docId: e.id);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(children: [
                                        Icon(
                                          response.code == 200 ? Icons.check_circle : Icons.error_outline,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(response.message.toString()),
                                      ]),
                                      backgroundColor: response.code == 200 ? Colors.green.shade700 : Colors.red.shade700,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Booking Baru'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => const AddPage()),
          );
        },
      ),
    );
  }
}