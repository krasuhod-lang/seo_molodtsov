import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/offer.dart';

class OffersService {
  OffersService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Поток списка офферов, отсортированный по полю `order`.
  Stream<List<Offer>> watchOffers() {
    return _firestore
        .collection('offers')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map(Offer.fromFirestore).toList());
  }
}
