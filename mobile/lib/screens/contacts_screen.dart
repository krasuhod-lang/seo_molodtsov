import 'package:flutter/material.dart';

import '../models/content.dart';
import '../theme.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key, required this.content});
  final AppContent content;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            content.contactsText,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
