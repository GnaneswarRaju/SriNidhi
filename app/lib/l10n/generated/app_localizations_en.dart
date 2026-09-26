// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sri Nidhi';

  @override
  String get productLabel => 'HARDWARE STORE MANAGEMENT';

  @override
  String get brandHeadline => 'A clearer view of\nyour store.';

  @override
  String get brandBody =>
      'Your stock. Your accounts.\nEverything in its place.';

  @override
  String get welcome => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to your store workspace.';

  @override
  String get email => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get needAccess => 'Need access? Contact your store administrator.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get passwordRequired => 'Enter your password.';

  @override
  String get authError =>
      'Sign-in failed. Check your details and connection, then try again.';

  @override
  String get signOutError => 'Could not sign out. Please try again.';

  @override
  String get loading => 'Opening your workspace…';

  @override
  String get setupTitle => 'Connect your store';

  @override
  String get setupBody =>
      'This installation needs its Supabase project configuration before you can sign in.';

  @override
  String get setupInstructions =>
      'Administrator setup\n\n1. Apply the repository migrations to a development project.\n2. Provision a user and branch role.\n3. Copy config.example.json to config.local.json and add the project URL and public key.\n4. Restart with --dart-define-from-file=config.local.json.';

  @override
  String get setupPrivacy =>
      'Use a public publishable or anon key. Never put a service-role key in the app.';

  @override
  String get startupError =>
      'The configured connection could not be initialized. Check the project configuration and restart.';

  @override
  String get overview => 'Overview';

  @override
  String get workspace => 'Workspace';

  @override
  String get settings => 'Settings';

  @override
  String get foundationLabel => 'FOUNDATION · V0.1';

  @override
  String get overviewTitle => 'Your store workspace';

  @override
  String get overviewSubtitle =>
      'A secure starting point for your everyday work.';

  @override
  String get workspaceReady => 'Your workspace is ready';

  @override
  String get workspaceReadyBody =>
      'Your account is connected to the branch below. Stock, sales and accounting will appear as their modules are released.';

  @override
  String get branch => 'Branch';

  @override
  String get business => 'Business';

  @override
  String get role => 'Your access';

  @override
  String get chooseBranch => 'Choose a branch';

  @override
  String get changeBranch => 'Change branch';

  @override
  String get accessTitle => 'No branch access yet';

  @override
  String get accessBody =>
      'Your account is signed in, but no active branch role is assigned. Ask your store administrator to grant access.';

  @override
  String get workspaceError =>
      'We could not verify your branch access. Check your connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get localStorage => 'Local preferences';

  @override
  String get localStorageReady => 'Available on this device';

  @override
  String get localStorageError =>
      'Local preferences could not be saved. Your branch selection was not changed. Please try again.';

  @override
  String get offlineTitle => 'Offline transactions';

  @override
  String get offlineBody =>
      'Not enabled in this version. An internet connection is required to verify branch access.';

  @override
  String get nextTitle => 'Next: products & inventory';

  @override
  String get nextBody =>
      'The next milestone adds your catalogue, opening stock, a stock movement ledger and low-stock alerts.';

  @override
  String get workspaceSubtitle =>
      'Select the branch you want to work in. Access is verified by the server.';

  @override
  String get selected => 'Selected';

  @override
  String get selectBranch => 'Select branch';

  @override
  String get settingsSubtitle => 'Account, device and application information.';

  @override
  String get account => 'Account';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get translationNote => 'Telugu and Hindi translations are planned.';

  @override
  String get version => 'Application version';

  @override
  String get commit => 'Build commit';

  @override
  String get privacyTitle => 'Your business data stays yours';

  @override
  String get privacyBody =>
      'Analytics are not enabled in this version. Financial records and customer information are never written to application logs.';

  @override
  String get ownerRole => 'Owner';

  @override
  String get adminRole => 'Administrator';

  @override
  String get managerRole => 'Manager';

  @override
  String get cashierRole => 'Cashier';

  @override
  String get stockManagerRole => 'Stock manager';

  @override
  String get accountantRole => 'Accountant';

  @override
  String get pageNotFound => 'This page could not be found.';

  @override
  String get returnHome => 'Return to overview';
}
