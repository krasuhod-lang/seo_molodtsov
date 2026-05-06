import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/content.dart';

class ContentService {
  ContentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Поток содержимого редактируемых страниц.
  /// Если документ ещё не создан в Firestore, отдаёт fallback.
  Stream<AppContent> watchContent() {
    return _firestore
        .collection('content')
        .doc('app')
        .snapshots()
        .map((doc) => doc.exists ? AppContent.fromFirestore(doc) : AppContent.fallback);
  }
}
