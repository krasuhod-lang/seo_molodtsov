import 'package:flutter/material.dart';

import '../models/content.dart';
import '../widgets/offer_list.dart';

class RatingScreen extends StatelessWidget {
  const RatingScreen({super.key, required this.content});
  final AppContent content;

  @override
  Widget build(BuildContext context) {
    return OfferList(
      title: content.ratingTitle,
      subtitle: content.ratingSubtitle,
    );
  }
}
