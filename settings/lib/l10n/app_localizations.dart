import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;


/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # For the intl APIs
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// The current app title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appTitle;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeSetting;

  /// Dark mode setting label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeSetting;

  /// Use system theme setting label
  ///
  /// In en, this message translates to:
  /// **'Use system theme'**
  String get useSystemThemeSetting;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// Language section title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// Vietnamese language option
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnameseLanguage;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSectionTitle;

  /// Notifications setting label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSetting;

  /// Text size section title
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSizeSectionTitle;

  /// Text size setting label with current scale factor
  ///
  /// In en, this message translates to:
  /// **'Text Size ({scaleFactor}x)'**
  String textSizeSetting(String scaleFactor);

  /// Reset to default button label
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// Enabled state label
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Disabled state label
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Choose theme dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get chooseTheme;

  /// Choose language dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// Reset settings confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettingsTitle;

  /// Reset settings confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to default values?'**
  String get resetSettingsConfirmation;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Settings reset success message
  ///
  /// In en, this message translates to:
  /// **'Settings have been reset to default values'**
  String get settingsResetSuccess;
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');

  @override
  String get appTitle => 'Settings App';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSectionTitle => 'Appearance';

  @override
  String get themeSetting => 'Theme';

  @override
  String get darkModeSetting => 'Dark Mode';

  @override
  String get useSystemThemeSetting => 'Use system theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageSetting => 'Language';

  @override
  String get englishLanguage => 'English';

  @override
  String get vietnameseLanguage => 'Tiếng Việt';

  @override
  String get notificationsSectionTitle => 'Notifications';

  @override
  String get notificationsSetting => 'Notifications';

  @override
  String get textSizeSectionTitle => 'Text Size';

  @override
  String textSizeSetting(String scaleFactor) => 'Text Size (${scaleFactor}x)';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get chooseTheme => 'Choose theme';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get resetSettingsTitle => 'Reset Settings';

  @override
  String get resetSettingsConfirmation =>
      'Are you sure you want to reset all settings to default values?';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get settingsResetSuccess => 'Settings have been reset to default values';
}

class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi() : super('vi');

  @override
  String get appTitle => 'Ứng dụng Cài đặt';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get appearanceSectionTitle => 'Giao diện';

  @override
  String get themeSetting => 'Chủ đề';

  @override
  String get darkModeSetting => 'Chế độ tối';

  @override
  String get useSystemThemeSetting => 'Sử dụng chủ đề hệ thống';

  @override
  String get systemTheme => 'Hệ thống';

  @override
  String get lightTheme => 'Sáng';

  @override
  String get darkTheme => 'Tối';

  @override
  String get languageSectionTitle => 'Ngôn ngữ';

  @override
  String get languageSetting => 'Ngôn ngữ';

  @override
  String get englishLanguage => 'English';

  @override
  String get vietnameseLanguage => 'Tiếng Việt';

  @override
  String get notificationsSectionTitle => 'Thông báo';

  @override
  String get notificationsSetting => 'Thông báo';

  @override
  String get textSizeSectionTitle => 'Cỡ chữ';

  @override
  String textSizeSetting(String scaleFactor) => 'Cỡ chữ (${scaleFactor}x)';

  @override
  String get resetToDefault => 'Đặt lại mặc định';

  @override
  String get enabled => 'Bật';

  @override
  String get disabled => 'Tắt';

  @override
  String get chooseTheme => 'Chọn chủ đề';

  @override
  String get chooseLanguage => 'Chọn ngôn ngữ';

  @override
  String get resetSettingsTitle => 'Đặt lại cài đặt';

  @override
  String get resetSettingsConfirmation =>
      'Bạn có chắc chắn muốn đặt lại tất cả cài đặt về giá trị mặc định?';

  @override
  String get cancel => 'Hủy';

  @override
  String get reset => 'Đặt lại';

  @override
  String get settingsResetSuccess => 'Đã đặt lại cài đặt về giá trị mặc định';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      _lookupAppLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations _lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the app_localizations.dart file. Please check that the file exists and '
    'contains the correct localizations.',
  );
}
