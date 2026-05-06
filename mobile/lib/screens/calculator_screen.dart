import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const double _maxAmount = 100000;
  static const double _maxTerm = 365;
  static const double _dailyRate = 0.008; // 0,8%

  double _amount = 15000;
  double _term = 30;
  bool _firstFree = false;

  double get _toReturn {
    if (_firstFree) return _amount;
    return _amount + _amount * _dailyRate * _term;
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.decimalPattern('ru');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SliderBlock(
            label: 'Сумма займа',
            value: '${money.format(_amount.round())} ₽',
            slider: Slider(
              value: _amount,
              min: 0,
              max: _maxAmount,
              divisions: 100,
              label: '${_amount.round()} ₽',
              onChanged: (v) => setState(() => _amount = v),
            ),
          ),
          const SizedBox(height: 16),
          _SliderBlock(
            label: 'Срок займа',
            value: '${_term.round()} дн.',
            slider: Slider(
              value: _term,
              min: 0,
              max: _maxTerm,
              divisions: 365,
              label: '${_term.round()} дн.',
              onChanged: (v) => setState(() => _term = v),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: CheckboxListTile(
              value: _firstFree,
              onChanged: (v) => setState(() => _firstFree = v ?? false),
              title: const Text('Первый займ бесплатно'),
              subtitle: const Text('Ставка 0% в день'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Результат расчёта',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: 'Сумма займа',
                    value: '${money.format(_amount.round())} ₽',
                  ),
                  _ResultRow(
                    label: 'Срок займа',
                    value: '${_term.round()} дн.',
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  _ResultRow(
                    label: 'К возврату',
                    value: '${money.format(_toReturn.round())} ₽',
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderBlock extends StatelessWidget {
  const _SliderBlock({
    required this.label,
    required this.value,
    required this.slider,
  });
  final String label;
  final String value;
  final Widget slider;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary)),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            slider,
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: bold ? 18 : 15,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(color: Colors.white70, fontWeight: FontWeight.w400)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
