import 'package:flutter/material.dart';
import 'app_i18n.dart';

/// Compact FR / ع language switch to place at the top of screens.
/// Tapping a side changes the app language immediately (rebuilds everything).
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  static const _red = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    // Rebuild on language change so the highlighted (chosen) segment is always
    // correct, even when this widget is used as `const` inside a screen.
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        final code = locale.languageCode;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _red.withAlpha(60)),
          ),
          padding: const EdgeInsets.all(2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _seg('FR', code == 'fr', () => setLocale('fr')),
              _seg('ع', code == 'ar', () => setLocale('ar')),
            ],
          ),
        );
      },
    );
  }

  Widget _seg(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _red : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : _red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
