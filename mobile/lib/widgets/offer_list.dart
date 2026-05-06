import 'package:flutter/material.dart';

import '../models/offer.dart';
import '../services/offers_service.dart';
import '../theme.dart';
import 'offer_card.dart';

/// Универсальный список офферов с заголовком/подзаголовком и пагинацией по 6.
class OfferList extends StatefulWidget {
  const OfferList({
    super.key,
    required this.title,
    required this.subtitle,
    this.service,
  });

  final String title;
  final String subtitle;
  final OffersService? service;

  @override
  State<OfferList> createState() => _OfferListState();
}

class _OfferListState extends State<OfferList> {
  static const int _pageSize = 6;
  int _visible = _pageSize;
  late final OffersService _service = widget.service ?? OffersService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Offer>>(
      stream: _service.watchOffers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasError) {
          return _Empty(
            icon: Icons.cloud_off,
            text: 'Не удалось загрузить офферы.\nПроверьте подключение к интернету.',
          );
        }
        final offers = snapshot.data ?? const <Offer>[];
        if (offers.isEmpty) {
          return _withHeader(
            context,
            const _Empty(
              icon: Icons.inbox_outlined,
              text: 'Пока нет доступных офферов.\nЗагляните чуть позже.',
            ),
          );
        }
        final shown = offers.take(_visible).toList();
        final hasMore = offers.length > shown.length;
        return _withHeader(
          context,
          Column(
            children: [
              ...shown.map((o) => OfferCard(offer: o)),
              if (hasMore)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _visible += _pageSize),
                    child: const Text('Показать ещё'),
                  ),
                )
              else
                const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _withHeader(BuildContext context, Widget body) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          body,
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
