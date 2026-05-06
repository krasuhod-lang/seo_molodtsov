import 'package:flutter/material.dart';

import '../models/content.dart';
import '../widgets/offer_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.content});
  final AppContent content;

  @override
  Widget build(BuildContext context) {
    return OfferList(
      title: content.homeTitle,
      subtitle: content.homeSubtitle,
    );
  }
}
