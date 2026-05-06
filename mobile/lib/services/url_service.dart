import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Безопасно открывает внешнюю ссылку оффера.
/// Принимает только http(s)-схему — защита от подсунутых javascript:/file:/intent:.
Future<bool> openExternalUrl(BuildContext context, String rawUrl) async {
  final uri = Uri.tryParse(rawUrl.trim());
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https') || uri.host.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Некорректная ссылка оффера')),
      );
    }
    return false;
  }
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось открыть ссылку')),
    );
  }
  return ok;
}
