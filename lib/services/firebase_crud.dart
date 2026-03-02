import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/response.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _collection = _firestore.collection('bookings');

class FirebaseCrud {

  static Future<Response> addBookingLapBasket({
    required String nama,
    required String notelp,
    required String nolap,
  }) async {

    Response response = Response();
    DocumentReference documentReferencer = _collection.doc();

    Map<String, dynamic> data = <String, dynamic>{
      "nama": nama,
      "notelp": notelp,
      "nolap": nolap,
      "createdAt": Timestamp.now(),
    };

    await documentReferencer
        .set(data)
        .then((_) {
      response.code = 200;
      response.message = "Booking berhasil ditambahkan!";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e.toString();
    });

    return response;
  }

  static Future<Response> updateBookingLapBasket({
    required String nama,
    required String notelp,
    required String nolap,
    required String docId,
  }) async {
    Response response = Response();
    DocumentReference documentReferencer = _collection.doc(docId);

    Map<String, dynamic> data = <String, dynamic>{
      "nama": nama,
      "notelp": notelp,
      "nolap": nolap,
    };

    await documentReferencer
        .update(data)
        .then((_) {
      response.code = 200;
      response.message = "Data booking berhasil diperbarui!";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e.toString();
    });

    return response;
  }

  static Stream<QuerySnapshot> readBookingLapBasket() {
    return _collection.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<Response> deleteBookingLapBasket({
    required String docId,
  }) async {
    Response response = Response();
    DocumentReference documentReferencer = _collection.doc(docId);

    await documentReferencer
        .delete()
        .then((_) {
      response.code = 200;
      response.message = "Data booking berhasil dihapus!";
    })
        .catchError((e) {
      response.code = 500;
      response.message = e.toString();
    });

    return response;
  }

}