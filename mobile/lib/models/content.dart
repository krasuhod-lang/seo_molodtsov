import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingSlide {
  final String title;
  final String text;
  const OnboardingSlide({required this.title, required this.text});

  factory OnboardingSlide.fromMap(Map<String, dynamic> m) => OnboardingSlide(
        title: (m['title'] ?? '') as String,
        text: (m['text'] ?? '') as String,
      );
}

/// Редактируемые тексты страниц приложения.
class AppContent {
  final String homeTitle;
  final String homeSubtitle;
  final String ratingTitle;
  final String ratingSubtitle;
  final String contactsText;
  final List<OnboardingSlide> onboarding;

  const AppContent({
    required this.homeTitle,
    required this.homeSubtitle,
    required this.ratingTitle,
    required this.ratingSubtitle,
    required this.contactsText,
    required this.onboarding,
  });

  static const AppContent fallback = AppContent(
    homeTitle: 'Займы 24/7',
    homeSubtitle: 'На вашу банковскую карту, с любой кредитной историей',
    ratingTitle: 'Рейтинг МФО',
    ratingSubtitle: 'Рейтинг составлен на основе отзывов из открытых источников',
    contactsText:
        'По всем вопросам, связанным с работой приложения, можно связаться с нами по e-mail:\n'
        'avada-gorup@yandex.ru\n\n'
        'Сервис не предоставляет займы и не является кредитной организацией. '
        'Приложение выполняет функцию каталога микрофинансовых организаций, '
        'предоставляющих информацию об услугах. Вся информация о займах и организациях '
        'взята из открытых источников и предоставляется исключительно в ознакомительных целях.',
    onboarding: [
      OnboardingSlide(
        title: 'Деньги онлайн на карту',
        text:
            'Оформите заявку на займ 3-5 компаниях и получите максимальный шанс одобрения',
      ),
      OnboardingSlide(
        title: 'Первый займ бесплатно',
        text: 'Для новых клиентов компаний-партнеров',
      ),
      OnboardingSlide(
        title: 'На связи 24/7',
        text: 'Заявки рассматриваются круглосуточно, без выходных',
      ),
    ],
  );

  factory AppContent.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final List<dynamic> rawSlides =
        (data['onboarding'] as List<dynamic>?) ?? const <dynamic>[];
    final slides = rawSlides
        .whereType<Map<String, dynamic>>()
        .map(OnboardingSlide.fromMap)
        .toList();
    return AppContent(
      homeTitle: (data['homeTitle'] ?? fallback.homeTitle) as String,
      homeSubtitle: (data['homeSubtitle'] ?? fallback.homeSubtitle) as String,
      ratingTitle: (data['ratingTitle'] ?? fallback.ratingTitle) as String,
      ratingSubtitle:
          (data['ratingSubtitle'] ?? fallback.ratingSubtitle) as String,
      contactsText: (data['contactsText'] ?? fallback.contactsText) as String,
      onboarding: slides.isEmpty ? fallback.onboarding : slides,
    );
  }
}
