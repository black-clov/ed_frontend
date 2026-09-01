import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Lightweight i18n: a global locale notifier + a `tr()` lookup.
/// French is the default language. Arabic is RTL, French is LTR.
///
/// Screens call `tr('key')` in build(); the whole app is wrapped in a
/// ValueListenableBuilder on [localeNotifier], so changing the language
/// rebuilds every screen with the new strings + direction.

const _storageKey = 'app_lang';
const _fallback = 'fr';

final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale(_fallback));

const List<Locale> kSupportedLocales = [Locale('fr'), Locale('ar')];

bool get isRtl => localeNotifier.value.languageCode == 'ar';

/// Loads the saved language (returns false if none was ever chosen).
Future<bool> loadSavedLocale() async {
  try {
    final saved = await const FlutterSecureStorage().read(key: _storageKey);
    if (saved == 'fr' || saved == 'ar') {
      localeNotifier.value = Locale(saved!);
      return true;
    }
  } catch (_) {}
  return false;
}

Future<void> setLocale(String code) async {
  if (code != 'fr' && code != 'ar') return;
  localeNotifier.value = Locale(code);
  try {
    await const FlutterSecureStorage().write(key: _storageKey, value: code);
  } catch (_) {}
}

/// Translate a key for the current language. Falls back to French, then the key.
String tr(String key) {
  final code = localeNotifier.value.languageCode;
  return _t[code]?[key] ?? _t[_fallback]?[key] ?? key;
}

// ─────────────────────────────────────────────────────────────────────────
// Translations. Add keys here as screens are internationalized (phased).
// ─────────────────────────────────────────────────────────────────────────
const Map<String, Map<String, String>> _t = {
  'fr': {
    // language screen
    'choose_language': 'Choisissez votre langue',
    'language_subtitle': 'Vous pourrez la changer plus tard',
    'french': 'Français',
    'arabic': 'العربية',
    'continue': 'Continuer',
    // common
    'ok': 'OK',
    'cancel': 'Annuler',
    'retry': 'Réessayer',
    'error': 'Erreur',
    'success': 'Succès',
    // welcome / login
    'welcome_title': 'Bienvenue',
    'login': 'Connexion',
    'email': 'E-mail',
    'password': 'Mot de passe',
    'login_btn': 'Se connecter',
    'forgot_password_q': 'Mot de passe oublié ?',
    'new_account': 'Nouveau compte',
    'choose_gender': 'Choisis ton profil',
    'boy': 'Garçon',
    'girl': 'Fille',
    'enter_info_start': 'Entre tes informations pour commencer',
    'google_signin': "S'inscrire avec Google",
    'fill_email_password': "Veuillez saisir l'e-mail et le mot de passe",
    'invalid_credentials': 'E-mail ou mot de passe incorrect',
    'login_error': 'Erreur de connexion. Réessayez.',
    'google_failed': 'Échec de la connexion avec Google',
    'google_error': 'Erreur lors de la connexion avec Google',
  },
  'ar': {
    // language screen
    'choose_language': 'اختر لغتك',
    'language_subtitle': 'يمكنك تغييرها لاحقاً',
    'french': 'Français',
    'arabic': 'العربية',
    'continue': 'متابعة',
    // common
    'ok': 'حسناً',
    'cancel': 'إلغاء',
    'retry': 'إعادة المحاولة',
    'error': 'خطأ',
    'success': 'تم بنجاح',
    // welcome / login
    'welcome_title': 'مرحبا بكم',
    'login': 'تسجيل الدخول',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'login_btn': 'دخول',
    'forgot_password_q': 'نسيت كلمة المرور؟',
    'new_account': 'حساب جديد',
    'choose_gender': 'اختر نوعك',
    'boy': 'ولد',
    'girl': 'بنت',
    'enter_info_start': 'أدخل معلوماتك لتبدأ',
    'google_signin': 'التسجيل عبر جوجل',
    'fill_email_password': 'يرجى إدخال البريد الإلكتروني وكلمة المرور',
    'invalid_credentials': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
    'login_error': 'خطأ في تسجيل الدخول. حاول مرة أخرى.',
    'google_failed': 'فشل التسجيل عبر جوجل',
    'google_error': 'خطأ في التسجيل عبر جوجل',
  },
};
