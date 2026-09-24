import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
///   intl: any # Use the pinned version from flutter_localizations
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sri Nidhi'**
  String get appTitle;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'HARDWARE STORE MANAGEMENT'**
  String get productLabel;

  /// No description provided for @brandHeadline.
  ///
  /// In en, this message translates to:
  /// **'A clearer view of\nyour store.'**
  String get brandHeadline;

  /// No description provided for @brandBody.
  ///
  /// In en, this message translates to:
  /// **'Your stock. Your accounts.\nEverything in its place.'**
  String get brandBody;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcome;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your store workspace.'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @needAccess.
  ///
  /// In en, this message translates to:
  /// **'Need access? Contact your store administrator.'**
  String get needAccess;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get passwordRequired;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Check your details and connection, then try again.'**
  String get authError;

  /// No description provided for @signOutError.
  ///
  /// In en, this message translates to:
  /// **'Could not sign out. Please try again.'**
  String get signOutError;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Opening your workspace…'**
  String get loading;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your store'**
  String get setupTitle;

  /// No description provided for @setupBody.
  ///
  /// In en, this message translates to:
  /// **'This installation needs its Supabase project configuration before you can sign in.'**
  String get setupBody;

  /// No description provided for @setupInstructions.
  ///
  /// In en, this message translates to:
  /// **'Administrator setup\n\n1. Apply the repository migrations to a development project.\n2. Provision a user and branch role.\n3. Copy config.example.json to config.local.json and add the project URL and public key.\n4. Restart with --dart-define-from-file=config.local.json.'**
  String get setupInstructions;

  /// No description provided for @setupPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Use a public publishable or anon key. Never put a service-role key in the app.'**
  String get setupPrivacy;

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'The configured connection could not be initialized. Check the project configuration and restart.'**
  String get startupError;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @foundationLabel.
  ///
  /// In en, this message translates to:
  /// **'FOUNDATION · V0.1'**
  String get foundationLabel;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your store workspace'**
  String get overviewTitle;

  /// No description provided for @overviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A secure starting point for your everyday work.'**
  String get overviewSubtitle;

  /// No description provided for @workspaceReady.
  ///
  /// In en, this message translates to:
  /// **'Your workspace is ready'**
  String get workspaceReady;

  /// No description provided for @workspaceReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is connected to the branch below. Stock, sales and accounting will appear as their modules are released.'**
  String get workspaceReadyBody;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Your access'**
  String get role;

  /// No description provided for @chooseBranch.
  ///
  /// In en, this message translates to:
  /// **'Choose a branch'**
  String get chooseBranch;

  /// No description provided for @changeBranch.
  ///
  /// In en, this message translates to:
  /// **'Change branch'**
  String get changeBranch;

  /// No description provided for @accessTitle.
  ///
  /// In en, this message translates to:
  /// **'No branch access yet'**
  String get accessTitle;

  /// No description provided for @accessBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is signed in, but no active branch role is assigned. Ask your store administrator to grant access.'**
  String get accessBody;

  /// No description provided for @workspaceError.
  ///
  /// In en, this message translates to:
  /// **'We could not verify your branch access. Check your connection and try again.'**
  String get workspaceError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @localStorage.
  ///
  /// In en, this message translates to:
  /// **'Local preferences'**
  String get localStorage;

  /// No description provided for @localStorageReady.
  ///
  /// In en, this message translates to:
  /// **'Available on this device'**
  String get localStorageReady;

  /// No description provided for @localStorageError.
  ///
  /// In en, this message translates to:
  /// **'Local preferences could not be saved. Your branch selection was not changed. Please try again.'**
  String get localStorageError;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline transactions'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In en, this message translates to:
  /// **'Not enabled in this version. An internet connection is required to verify branch access.'**
  String get offlineBody;

  /// No description provided for @nextTitle.
  ///
  /// In en, this message translates to:
  /// **'Next: products & inventory'**
  String get nextTitle;

  /// No description provided for @nextBody.
  ///
  /// In en, this message translates to:
  /// **'The next milestone adds your catalogue, opening stock, a stock movement ledger and low-stock alerts.'**
  String get nextBody;

  /// No description provided for @workspaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the branch you want to work in. Access is verified by the server.'**
  String get workspaceSubtitle;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @selectBranch.
  ///
  /// In en, this message translates to:
  /// **'Select branch'**
  String get selectBranch;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account, device and application information.'**
  String get settingsSubtitle;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @translationNote.
  ///
  /// In en, this message translates to:
  /// **'Telugu and Hindi translations are planned.'**
  String get translationNote;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Application version'**
  String get version;

  /// No description provided for @commit.
  ///
  /// In en, this message translates to:
  /// **'Build commit'**
  String get commit;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your business data stays yours'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Analytics are not enabled in this version. Financial records and customer information are never written to application logs.'**
  String get privacyBody;

  /// No description provided for @ownerRole.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerRole;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get adminRole;

  /// No description provided for @managerRole.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get managerRole;

  /// No description provided for @cashierRole.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get cashierRole;

  /// No description provided for @stockManagerRole.
  ///
  /// In en, this message translates to:
  /// **'Stock manager'**
  String get stockManagerRole;

  /// No description provided for @accountantRole.
  ///
  /// In en, this message translates to:
  /// **'Accountant'**
  String get accountantRole;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'This page could not be found.'**
  String get pageNotFound;

  /// No description provided for @returnHome.
  ///
  /// In en, this message translates to:
  /// **'Return to overview'**
  String get returnHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
