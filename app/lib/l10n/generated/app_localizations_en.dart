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
  String get foundationLabel => 'YOUR STORE · YOUR WORKSPACE';

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
  String get nextTitle => 'Next: stock movements';

  @override
  String get nextBody =>
      'Your product catalogue is available in Products. Opening stock, a stock movement ledger and low-stock alerts are coming next.';

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

  @override
  String get products => 'Products';

  @override
  String get productsTitle => 'Your product catalogue';

  @override
  String get productsSubtitle =>
      'Maintain product details shared across your business. Stock quantities will be added in a later update.';

  @override
  String get addProduct => 'Add product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get productDetails => 'Product details';

  @override
  String get searchProducts => 'Search by name, SKU or barcode prefix';

  @override
  String get search => 'Search';

  @override
  String get includeInactive => 'Include inactive products';

  @override
  String get emptyProducts => 'Your catalogue starts here';

  @override
  String get emptyProductsBody =>
      'Add your first product with its selling unit and price.';

  @override
  String get emptyReadOnlyBody =>
      'Ask your store administrator to add the first product.';

  @override
  String get noProductsFound => 'No matching products';

  @override
  String get noProductsFoundBody =>
      'Try a different prefix or include inactive products.';

  @override
  String get productsError =>
      'We could not load products. Check your connection and branch access, then try again.';

  @override
  String get previousPage => 'Previous';

  @override
  String get nextPage => 'Next';

  @override
  String get refreshProducts => 'Refresh products';

  @override
  String get edit => 'Edit';

  @override
  String get viewDetails => 'View details';

  @override
  String get activeProduct => 'Active';

  @override
  String get inactiveProduct => 'Inactive';

  @override
  String get productName => 'Product name';

  @override
  String get sku => 'SKU';

  @override
  String get barcode => 'Barcode (optional)';

  @override
  String get category => 'Category (optional)';

  @override
  String get brand => 'Brand (optional)';

  @override
  String get baseUnit => 'Base unit';

  @override
  String get baseUnitNote =>
      'Choose the smallest unit you sell or count. This cannot be changed after saving.';

  @override
  String get hsnCode => 'HSN code (optional)';

  @override
  String get salePrice => 'Selling price (₹)';

  @override
  String get mrp => 'MRP (₹, optional)';

  @override
  String get reorderQuantity => 'Reorder threshold';

  @override
  String get reorderNote =>
      'A default threshold for future low-stock alerts. This does not add stock.';

  @override
  String get description => 'Description (optional)';

  @override
  String get activeProductNote =>
      'Inactive products stay in your records and can be reactivated.';

  @override
  String get saveProduct => 'Save product';

  @override
  String get savingProduct => 'Saving…';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get requiredField => 'Enter a value.';

  @override
  String get invalidSku =>
      'Use letters, numbers, dots, slashes, underscores or hyphens. Start with a letter or number.';

  @override
  String get invalidBarcode =>
      'Use letters, numbers, dots, slashes, underscores or hyphens.';

  @override
  String get invalidHsn => 'Enter 4 to 8 digits.';

  @override
  String get invalidPrice =>
      'Enter a non-negative amount with up to 12 whole digits and 2 decimal places.';

  @override
  String get invalidMrp => 'MRP must be at least the selling price.';

  @override
  String get invalidQuantity =>
      'Enter a non-negative quantity with up to 14 whole digits and 6 decimal places.';

  @override
  String get wholeQuantity => 'This unit requires a whole-number quantity.';

  @override
  String get productSaveError =>
      'Saving could not be confirmed. Keep these details unchanged and try again, or close and refresh the catalogue before editing them.';

  @override
  String get productDuplicate =>
      'That SKU or barcode is already used. Enter a unique value.';

  @override
  String get productConflict =>
      'This product or request has changed. Close this form and refresh the catalogue before trying again.';

  @override
  String get productForbidden =>
      'Your account cannot save products in this branch. Ask your store administrator to check your access.';

  @override
  String get productInvalid =>
      'Some product details were rejected. Check the fields and try again.';

  @override
  String get unitPcs => 'Piece (PCS)';

  @override
  String get unitBox => 'Box (BOX)';

  @override
  String get unitPack => 'Pack (PACK)';

  @override
  String get unitBag => 'Bag (BAG)';

  @override
  String get unitSet => 'Set (SET)';

  @override
  String get unitRoll => 'Roll (ROLL)';

  @override
  String get unitKg => 'Kilogram (KG)';

  @override
  String get unitG => 'Gram (G)';

  @override
  String get unitM => 'Metre (M)';

  @override
  String get unitCm => 'Centimetre (CM)';

  @override
  String get unitFt => 'Foot (FT)';

  @override
  String get unitL => 'Litre (L)';

  @override
  String get unitMl => 'Millilitre (ML)';
}
