import 'package:flutter/material.dart';

import '../models/content.dart';
import '../services/content_service.dart';
import 'calculator_screen.dart';
import 'contacts_screen.dart';
import 'home_screen.dart';
import 'rating_screen.dart';

/// Главная оболочка с нижней навигацией и общим AppBar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<_TabSpec> _tabs = [
    _TabSpec(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Главная'),
    _TabSpec(icon: Icons.star_border, activeIcon: Icons.star, label: 'Рейтинг'),
    _TabSpec(icon: Icons.calculate_outlined, activeIcon: Icons.calculate, label: 'Калькулятор'),
    _TabSpec(icon: Icons.mail_outline, activeIcon: Icons.mail, label: 'Контакты'),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppContent>(
      stream: ContentService().watchContent(),
      builder: (context, snapshot) {
        final content = snapshot.data ?? AppContent.fallback;

        // На главной — название приложения, на остальных — название раздела с кнопкой "домой".
        final List<Widget> pages = [
          HomeScreen(content: content),
          RatingScreen(content: content),
          const CalculatorScreen(),
          ContactsScreen(content: content),
        ];

        final List<String> titles = [
          content.homeTitle,
          'Рейтинг МФО',
          'Калькулятор',
          'Контакты',
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(titles[_index]),
            leading: _index == 0
                ? null
                : IconButton(
                    icon: const Icon(Icons.home),
                    tooltip: 'На главную',
                    onPressed: () => setState(() => _index = 0),
                  ),
            automaticallyImplyLeading: false,
          ),
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
            items: [
              for (final t in _tabs)
                BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                  label: t.label,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TabSpec {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabSpec({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
