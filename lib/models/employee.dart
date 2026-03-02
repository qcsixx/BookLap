import 'package:cloud_firestore/cloud_firestore.dart';

class BookingLapBasket {
  String? uid;
  String? nama;
  String? notelp;
  String? nolap;
  Timestamp? createdAt;

  BookingLapBasket({
    this.uid,
    this.nama,
    this.notelp,
    this.nolap,
    this.createdAt,
  });
}
