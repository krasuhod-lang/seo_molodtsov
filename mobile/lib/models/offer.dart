import 'package:cloud_firestore/cloud_firestore.dart';

/// CPA-оффер микрофинансовой организации.
class Offer {
  final String id;
  final String name;
  final String slogan;
  final num amount; // ₽
  final num term; // дн.
  final String age;
  final String logoUrl;
  final String url;
  final int order;

  const Offer({
    required this.id,
    required this.name,
    required this.slogan,
    required this.amount,
    required this.term,
    required this.age,
    required this.logoUrl,
    required this.url,
    required this.order,
  });

  factory Offer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Offer(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      slogan: (data['slogan'] ?? '') as String,
      amount: (data['amount'] ?? 0) as num,
      term: (data['term'] ?? 0) as num,
      age: (data['age'] ?? '') as String,
      logoUrl: (data['logoUrl'] ?? '') as String,
      url: (data['url'] ?? '') as String,
      order: (data['order'] ?? 0) as int,
    );
  }
}
