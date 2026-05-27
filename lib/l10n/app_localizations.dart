import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FarmSheep'**
  String get appTitle;

  /// No description provided for @smartFarmManagement.
  ///
  /// In en, this message translates to:
  /// **'Smart Farm Management'**
  String get smartFarmManagement;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// No description provided for @editMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editMenuItem;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @noFarmSelected.
  ///
  /// In en, this message translates to:
  /// **'No farm selected.'**
  String get noFarmSelected;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @requiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredValidation;

  /// No description provided for @makeAdminMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get makeAdminMenuItem;

  /// No description provided for @makePartnerMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Make Partner'**
  String get makePartnerMenuItem;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToFarmAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your farm account'**
  String get signInToFarmAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @enterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email above first'**
  String get enterEmailFirst;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent!'**
  String get passwordResetSent;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failed(String error);

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinFarmSheepToday.
  ///
  /// In en, this message translates to:
  /// **'Join FarmSheep today'**
  String get joinFarmSheepToday;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created! Check your email to verify.'**
  String get accountCreated;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @passwordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordWeak;

  /// No description provided for @passwordMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get passwordMedium;

  /// No description provided for @passwordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrong;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @profileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTooltip;

  /// No description provided for @welcomeNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeNotificationTitle;

  /// No description provided for @welcomeNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Check your animals and logs for today!'**
  String get welcomeNotificationBody;

  /// No description provided for @tileAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get tileAnimals;

  /// No description provided for @tileFarmDashboard.
  ///
  /// In en, this message translates to:
  /// **'Farm Dashboard'**
  String get tileFarmDashboard;

  /// No description provided for @tileLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get tileLogs;

  /// No description provided for @tileBreedManagement.
  ///
  /// In en, this message translates to:
  /// **'Breed Management'**
  String get tileBreedManagement;

  /// No description provided for @tileAddPartner.
  ///
  /// In en, this message translates to:
  /// **'Add Partner'**
  String get tileAddPartner;

  /// No description provided for @tileAdminLogs.
  ///
  /// In en, this message translates to:
  /// **'Admin Logs'**
  String get tileAdminLogs;

  /// No description provided for @tileUserManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get tileUserManagement;

  /// No description provided for @tileAdminOverride.
  ///
  /// In en, this message translates to:
  /// **'Admin Override'**
  String get tileAdminOverride;

  /// No description provided for @tileAnimalSearchExport.
  ///
  /// In en, this message translates to:
  /// **'Animal Search & Export'**
  String get tileAnimalSearchExport;

  /// No description provided for @tileLogSearchExport.
  ///
  /// In en, this message translates to:
  /// **'Log Search & Export'**
  String get tileLogSearchExport;

  /// No description provided for @tileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get tileLogout;

  /// No description provided for @alertsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Notifications'**
  String get alertsNotificationsTitle;

  /// No description provided for @alertsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage farm notifications'**
  String get alertsNotificationsSubtitle;

  /// No description provided for @statAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get statAnimals;

  /// No description provided for @statPartners.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get statPartners;

  /// No description provided for @statLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get statLogs;

  /// No description provided for @animalsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animalsScreenTitle;

  /// No description provided for @exportCsvTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsvTooltip;

  /// No description provided for @addAnimalTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Animal'**
  String get addAnimalTooltip;

  /// No description provided for @searchByTagIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by Tag ID'**
  String get searchByTagIdLabel;

  /// No description provided for @searchByTagIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter tag number...'**
  String get searchByTagIdHint;

  /// No description provided for @allTypesHint.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypesHint;

  /// No description provided for @allStatusesHint.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatusesHint;

  /// No description provided for @noAnimalsFound.
  ///
  /// In en, this message translates to:
  /// **'No animals found'**
  String get noAnimalsFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search filters'**
  String get tryAdjustingFilters;

  /// No description provided for @addFirstAnimal.
  ///
  /// In en, this message translates to:
  /// **'Add your first animal to get started!'**
  String get addFirstAnimal;

  /// No description provided for @askAiTooltip.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAiTooltip;

  /// No description provided for @exportPdfTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdfTooltip;

  /// No description provided for @deleteAnimalDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Animal'**
  String get deleteAnimalDialogTitle;

  /// No description provided for @deleteAnimalDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this animal?'**
  String get deleteAnimalDialogContent;

  /// No description provided for @pdfFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF failed: {error}'**
  String pdfFailed(String error);

  /// No description provided for @tagNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag Number'**
  String get tagNumberLabel;

  /// No description provided for @bornLabel.
  ///
  /// In en, this message translates to:
  /// **'Born'**
  String get bornLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @tagColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag Color'**
  String get tagColorLabel;

  /// No description provided for @physicalSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physicalSectionHeader;

  /// No description provided for @sexLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sexLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @bcsLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Condition Score'**
  String get bcsLabel;

  /// No description provided for @microchipLabel.
  ///
  /// In en, this message translates to:
  /// **'Microchip'**
  String get microchipLabel;

  /// No description provided for @originSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get originSectionHeader;

  /// No description provided for @acquiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Acquired'**
  String get acquiredLabel;

  /// No description provided for @purchaseDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDateLabel;

  /// No description provided for @lineageSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Lineage'**
  String get lineageSectionHeader;

  /// No description provided for @sireFatherLabel.
  ///
  /// In en, this message translates to:
  /// **'Sire (Father)'**
  String get sireFatherLabel;

  /// No description provided for @sireIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Sire ID'**
  String get sireIdLabel;

  /// No description provided for @damMotherLabel.
  ///
  /// In en, this message translates to:
  /// **'Dam (Mother)'**
  String get damMotherLabel;

  /// No description provided for @damIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Dam ID'**
  String get damIdLabel;

  /// No description provided for @notesSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesSectionHeader;

  /// No description provided for @pregnancyHistoryHeader.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy History'**
  String get pregnancyHistoryHeader;

  /// No description provided for @birthLogHeader.
  ///
  /// In en, this message translates to:
  /// **'Birth Log'**
  String get birthLogHeader;

  /// No description provided for @healthLogsHeader.
  ///
  /// In en, this message translates to:
  /// **'Health Logs'**
  String get healthLogsHeader;

  /// No description provided for @saleInfoHeader.
  ///
  /// In en, this message translates to:
  /// **'Sale Info'**
  String get saleInfoHeader;

  /// No description provided for @buyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyerLabel;

  /// No description provided for @aiHealthRiskAssessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Health Risk Assessment'**
  String get aiHealthRiskAssessmentTitle;

  /// No description provided for @aiRiskAssessmentButton.
  ///
  /// In en, this message translates to:
  /// **'AI Risk Assessment'**
  String get aiRiskAssessmentButton;

  /// No description provided for @analyzingLabel.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzingLabel;

  /// No description provided for @stillWorkingLabel.
  ///
  /// In en, this message translates to:
  /// **'Still working...'**
  String get stillWorkingLabel;

  /// No description provided for @addAnimalScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Animal'**
  String get addAnimalScreenTitle;

  /// No description provided for @editAnimalScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Animal'**
  String get editAnimalScreenTitle;

  /// No description provided for @identificationSection.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get identificationSection;

  /// No description provided for @tagNumberFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag Number *'**
  String get tagNumberFieldLabel;

  /// No description provided for @tagNumberFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Enter unique ear tag number'**
  String get tagNumberFieldHint;

  /// No description provided for @tagColorTileTitle.
  ///
  /// In en, this message translates to:
  /// **'Tag Color'**
  String get tagColorTileTitle;

  /// No description provided for @pickTagColorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick Tag Color'**
  String get pickTagColorDialogTitle;

  /// No description provided for @microchipRfidLabel.
  ///
  /// In en, this message translates to:
  /// **'Microchip / RFID'**
  String get microchipRfidLabel;

  /// No description provided for @microchipRfidHint.
  ///
  /// In en, this message translates to:
  /// **'Optional electronic ID'**
  String get microchipRfidHint;

  /// No description provided for @animalDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Animal Details'**
  String get animalDetailsSection;

  /// No description provided for @breedLabel.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breedLabel;

  /// No description provided for @breedHint.
  ///
  /// In en, this message translates to:
  /// **'Select breed'**
  String get breedHint;

  /// No description provided for @pickBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Pick birth date *'**
  String get pickBirthDate;

  /// No description provided for @birthDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Birth Date: '**
  String get birthDatePrefix;

  /// No description provided for @originSection.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get originSection;

  /// No description provided for @acquisitionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Acquisition Type'**
  String get acquisitionTypeLabel;

  /// No description provided for @howWasAnimalAcquired.
  ///
  /// In en, this message translates to:
  /// **'How was this animal acquired?'**
  String get howWasAnimalAcquired;

  /// No description provided for @typeSheep.
  ///
  /// In en, this message translates to:
  /// **'Sheep'**
  String get typeSheep;

  /// No description provided for @typeGoat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get typeGoat;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @sexWether.
  ///
  /// In en, this message translates to:
  /// **'Wether'**
  String get sexWether;

  /// No description provided for @sexUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sexUnknown;

  /// No description provided for @acquisitionBornOnFarm.
  ///
  /// In en, this message translates to:
  /// **'Born on Farm'**
  String get acquisitionBornOnFarm;

  /// No description provided for @acquisitionPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get acquisitionPurchased;

  /// No description provided for @acquisitionGifted.
  ///
  /// In en, this message translates to:
  /// **'Gifted'**
  String get acquisitionGifted;

  /// No description provided for @purchaseSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Source'**
  String get purchaseSourceLabel;

  /// No description provided for @purchaseSourceHint.
  ///
  /// In en, this message translates to:
  /// **'Seller / Market name'**
  String get purchaseSourceHint;

  /// No description provided for @purchasePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get purchasePriceLabel;

  /// No description provided for @purchasePriceHint.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get purchasePriceHint;

  /// No description provided for @purchaseDateTile.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDateTile;

  /// No description provided for @purchasedDatePrefix.
  ///
  /// In en, this message translates to:
  /// **'Purchased: '**
  String get purchasedDatePrefix;

  /// No description provided for @lineageSection.
  ///
  /// In en, this message translates to:
  /// **'Lineage'**
  String get lineageSection;

  /// No description provided for @sireTagNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Sire Tag / Name'**
  String get sireTagNameLabel;

  /// No description provided for @sireTagNameHint.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get sireTagNameHint;

  /// No description provided for @sireIdHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get sireIdHint;

  /// No description provided for @damTagNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Dam Tag / Name'**
  String get damTagNameLabel;

  /// No description provided for @damTagNameHint.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get damTagNameHint;

  /// No description provided for @damIdHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get damIdHint;

  /// No description provided for @physicalSection.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physicalSection;

  /// No description provided for @currentWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Weight (kg)'**
  String get currentWeightLabel;

  /// No description provided for @currentWeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 45.5'**
  String get currentWeightHint;

  /// No description provided for @bodyConditionScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Body Condition Score (BCS)'**
  String get bodyConditionScoreLabel;

  /// No description provided for @notesSection.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesSection;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Any additional observations'**
  String get notesHint;

  /// No description provided for @photosSection.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosSection;

  /// No description provided for @cameraButton.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraButton;

  /// No description provided for @galleryButton.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryButton;

  /// No description provided for @saveAnimalButton.
  ///
  /// In en, this message translates to:
  /// **'Save Animal'**
  String get saveAnimalButton;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @cropImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get cropImageTitle;

  /// No description provided for @birthDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Birth date is required.'**
  String get birthDateRequired;

  /// No description provided for @tagNumberMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Tag number must be a positive integer.'**
  String get tagNumberMustBePositive;

  /// No description provided for @couldNotPickImage.
  ///
  /// In en, this message translates to:
  /// **'Could not pick image: {error}'**
  String couldNotPickImage(String error);

  /// No description provided for @errorSavingAnimal.
  ///
  /// In en, this message translates to:
  /// **'Error saving animal: {error}'**
  String errorSavingAnimal(String error);

  /// No description provided for @errorUpdatingAnimal.
  ///
  /// In en, this message translates to:
  /// **'Error updating animal: {error}'**
  String errorUpdatingAnimal(String error);

  /// No description provided for @animalSearchExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Animal Search & Export'**
  String get animalSearchExportTitle;

  /// No description provided for @searchByTagOrBreed.
  ///
  /// In en, this message translates to:
  /// **'Search by tag or breed'**
  String get searchByTagOrBreed;

  /// No description provided for @yourFarmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Farms'**
  String get yourFarmsTitle;

  /// No description provided for @viewArchivedFarms.
  ///
  /// In en, this message translates to:
  /// **'View Archived Farms'**
  String get viewArchivedFarms;

  /// No description provided for @noFarmsFound.
  ///
  /// In en, this message translates to:
  /// **'No farms found'**
  String get noFarmsFound;

  /// No description provided for @addFirstFarm.
  ///
  /// In en, this message translates to:
  /// **'Add your first farm to get started!'**
  String get addFirstFarm;

  /// No description provided for @archiveFarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive Farm'**
  String get archiveFarmTitle;

  /// No description provided for @archiveFarmConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to archive this farm? You can restore it later.'**
  String get archiveFarmConfirm;

  /// No description provided for @archiveButton.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveButton;

  /// No description provided for @deleteFarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Farm'**
  String get deleteFarmTitle;

  /// No description provided for @deleteFarmConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this farm? All animals and logs will be permanently deleted.'**
  String get deleteFarmConfirm;

  /// No description provided for @farmArchived.
  ///
  /// In en, this message translates to:
  /// **'Farm archived.'**
  String get farmArchived;

  /// No description provided for @farmDeleted.
  ///
  /// In en, this message translates to:
  /// **'Farm deleted.'**
  String get farmDeleted;

  /// No description provided for @addFarmFab.
  ///
  /// In en, this message translates to:
  /// **'Add Farm'**
  String get addFarmFab;

  /// No description provided for @addNewFarmDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Farm'**
  String get addNewFarmDialogTitle;

  /// No description provided for @farmNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm Name'**
  String get farmNameLabel;

  /// No description provided for @farmNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter farm name'**
  String get farmNameHint;

  /// No description provided for @farmNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a farm name'**
  String get farmNameRequired;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter farm address'**
  String get addressHint;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a farm address'**
  String get addressRequired;

  /// No description provided for @notesOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptionalLabel;

  /// No description provided for @additionalFarmInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional farm information'**
  String get additionalFarmInfo;

  /// No description provided for @farmAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Farm added successfully!'**
  String get farmAddedSuccessfully;

  /// No description provided for @errorAddingFarm.
  ///
  /// In en, this message translates to:
  /// **'Error adding farm: {error}'**
  String errorAddingFarm(String error);

  /// No description provided for @farmDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm Dashboard'**
  String get farmDashboardTitle;

  /// No description provided for @farmSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Farm Settings'**
  String get farmSettingsTooltip;

  /// No description provided for @aiHerdSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Herd Summary'**
  String get aiHerdSummaryTitle;

  /// No description provided for @aiHerdSummaryGenerateTap.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Generate\" to get an AI overview of your herd.'**
  String get aiHerdSummaryGenerateTap;

  /// No description provided for @generatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generatingLabel;

  /// No description provided for @refreshSummaryButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh Summary'**
  String get refreshSummaryButton;

  /// No description provided for @generateAiSummaryButton.
  ///
  /// In en, this message translates to:
  /// **'Generate AI Summary'**
  String get generateAiSummaryButton;

  /// No description provided for @tileFarmActivity.
  ///
  /// In en, this message translates to:
  /// **'Farm Activity'**
  String get tileFarmActivity;

  /// No description provided for @tileProfileUsers.
  ///
  /// In en, this message translates to:
  /// **'Profile / Users'**
  String get tileProfileUsers;

  /// No description provided for @farmSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm Settings'**
  String get farmSettingsTitle;

  /// No description provided for @notesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesSectionTitle;

  /// No description provided for @preferredBreedsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferred Breeds'**
  String get preferredBreedsSectionTitle;

  /// No description provided for @preferredBreedsHint.
  ///
  /// In en, this message translates to:
  /// **'Damani, Dimashqi, Mixed...'**
  String get preferredBreedsHint;

  /// No description provided for @preferredBreedsHelper.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated breed names'**
  String get preferredBreedsHelper;

  /// No description provided for @farmColorSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm Color'**
  String get farmColorSectionTitle;

  /// No description provided for @currentColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Current color:'**
  String get currentColorLabel;

  /// No description provided for @pickFarmColorDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick Farm Color'**
  String get pickFarmColorDialogTitle;

  /// No description provided for @tapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get tapToChange;

  /// No description provided for @partnerPermissionsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner Permissions'**
  String get partnerPermissionsSectionTitle;

  /// No description provided for @allowPartnersAddAnimalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow partners to add animals'**
  String get allowPartnersAddAnimalsTitle;

  /// No description provided for @allowPartnersAddAnimalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Partners can add new animals to the farm'**
  String get allowPartnersAddAnimalsSubtitle;

  /// No description provided for @allowPartnersEditLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow partners to edit logs'**
  String get allowPartnersEditLogsTitle;

  /// No description provided for @allowPartnersEditLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Partners can create and edit manual logs'**
  String get allowPartnersEditLogsSubtitle;

  /// No description provided for @saveSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettingsButton;

  /// No description provided for @farmSettingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Farm settings updated.'**
  String get farmSettingsUpdated;

  /// No description provided for @addManualLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Manual Log'**
  String get addManualLogTitle;

  /// No description provided for @logDetailsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Details'**
  String get logDetailsSectionTitle;

  /// No description provided for @actionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Action Type'**
  String get actionTypeLabel;

  /// No description provided for @animalIdsLabel.
  ///
  /// In en, this message translates to:
  /// **'Animal IDs (comma-separated)'**
  String get animalIdsLabel;

  /// No description provided for @getAiSuggestionButton.
  ///
  /// In en, this message translates to:
  /// **'Get AI Suggestion'**
  String get getAiSuggestionButton;

  /// No description provided for @gettingSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Getting suggestion...'**
  String get gettingSuggestion;

  /// No description provided for @saveManualLogTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save manual log'**
  String get saveManualLogTooltip;

  /// No description provided for @addAnimalsFirst.
  ///
  /// In en, this message translates to:
  /// **'Add animals to the farm first.'**
  String get addAnimalsFirst;

  /// No description provided for @aiSuggestionApplied.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion applied!'**
  String get aiSuggestionApplied;

  /// No description provided for @aiSuggestionFailed.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion failed: {error}'**
  String aiSuggestionFailed(String error);

  /// No description provided for @userNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'User not signed in'**
  String get userNotSignedIn;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorSaving(String error);

  /// No description provided for @actionFeeding.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get actionFeeding;

  /// No description provided for @actionDeworming.
  ///
  /// In en, this message translates to:
  /// **'Deworming'**
  String get actionDeworming;

  /// No description provided for @actionCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get actionCleaning;

  /// No description provided for @actionVaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get actionVaccination;

  /// No description provided for @actionMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get actionMedication;

  /// No description provided for @actionTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get actionTreatment;

  /// No description provided for @actionHealthCheck.
  ///
  /// In en, this message translates to:
  /// **'Health Check'**
  String get actionHealthCheck;

  /// No description provided for @actionObservation.
  ///
  /// In en, this message translates to:
  /// **'Observation'**
  String get actionObservation;

  /// No description provided for @actionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get actionOther;

  /// No description provided for @manualLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Logs'**
  String get manualLogsTitle;

  /// No description provided for @noLogsFound.
  ///
  /// In en, this message translates to:
  /// **'No logs found.'**
  String get noLogsFound;

  /// No description provided for @logSearchExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Search & Export'**
  String get logSearchExportTitle;

  /// No description provided for @searchByTypeOrNotes.
  ///
  /// In en, this message translates to:
  /// **'Search by type or notes'**
  String get searchByTypeOrNotes;

  /// No description provided for @dateRangeButton.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRangeButton;

  /// No description provided for @auditTrailHeader.
  ///
  /// In en, this message translates to:
  /// **'Audit Trail (Admin Only)'**
  String get auditTrailHeader;

  /// No description provided for @farmActivityLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm Activity Log'**
  String get farmActivityLogTitle;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivityYet;

  /// No description provided for @farmActionsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Farm actions will appear here.'**
  String get farmActionsWillAppear;

  /// No description provided for @activityLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Logs'**
  String get activityLogsTitle;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// No description provided for @noActivityLogsFound.
  ///
  /// In en, this message translates to:
  /// **'No activity logs found.'**
  String get noActivityLogsFound;

  /// No description provided for @adminRecordOverrideTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Record Override'**
  String get adminRecordOverrideTitle;

  /// No description provided for @adminAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Admin access required'**
  String get adminAccessRequired;

  /// No description provided for @searchAnimalsByTagOrBreed.
  ///
  /// In en, this message translates to:
  /// **'Search animals by tag or breed'**
  String get searchAnimalsByTagOrBreed;

  /// No description provided for @overrideThisRecord.
  ///
  /// In en, this message translates to:
  /// **'Override this record'**
  String get overrideThisRecord;

  /// No description provided for @recentOverridesHeader.
  ///
  /// In en, this message translates to:
  /// **'Recent Overrides'**
  String get recentOverridesHeader;

  /// No description provided for @noOverridesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No overrides recorded yet.'**
  String get noOverridesRecorded;

  /// No description provided for @overrideAnimalDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Override Animal #{tagNumber}'**
  String overrideAnimalDialogTitle(String tagNumber);

  /// No description provided for @reasonForOverrideLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason for Override *'**
  String get reasonForOverrideLabel;

  /// No description provided for @reasonForOverrideHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why this record is being changed'**
  String get reasonForOverrideHint;

  /// No description provided for @reasonRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'A reason is required for admin overrides'**
  String get reasonRequiredValidation;

  /// No description provided for @saveOverrideButton.
  ///
  /// In en, this message translates to:
  /// **'Save Override'**
  String get saveOverrideButton;

  /// No description provided for @overrideSaved.
  ///
  /// In en, this message translates to:
  /// **'Override saved and logged in audit trail.'**
  String get overrideSaved;

  /// No description provided for @userManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagementTitle;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @resetPasswordMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordMenuItem;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get passwordResetEmailSent;

  /// No description provided for @roleUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Role updated to {role}.'**
  String roleUpdatedTo(String role);

  /// No description provided for @breedManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Breed Management'**
  String get breedManagementTitle;

  /// No description provided for @addBreedSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Breed'**
  String get addBreedSectionTitle;

  /// No description provided for @enterBreedName.
  ///
  /// In en, this message translates to:
  /// **'Enter breed name'**
  String get enterBreedName;

  /// No description provided for @noBreedsAdded.
  ///
  /// In en, this message translates to:
  /// **'No breeds added.'**
  String get noBreedsAdded;

  /// No description provided for @removeBreedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove breed'**
  String get removeBreedTooltip;

  /// No description provided for @aiRecommendFab.
  ///
  /// In en, this message translates to:
  /// **'AI Recommend'**
  String get aiRecommendFab;

  /// No description provided for @aiBreedRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Breed Recommendation'**
  String get aiBreedRecommendationTitle;

  /// No description provided for @climateLabel.
  ///
  /// In en, this message translates to:
  /// **'Climate'**
  String get climateLabel;

  /// No description provided for @purposeLabel.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purposeLabel;

  /// No description provided for @additionalPreferencesLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional Preferences (optional)'**
  String get additionalPreferencesLabel;

  /// No description provided for @additionalPreferencesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. hardy, low maintenance, good mothers'**
  String get additionalPreferencesHint;

  /// No description provided for @consultingAiSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Consulting AI breed specialist...'**
  String get consultingAiSpecialist;

  /// No description provided for @getRecommendationsButton.
  ///
  /// In en, this message translates to:
  /// **'Get Recommendations'**
  String get getRecommendationsButton;

  /// No description provided for @askAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Ask Again'**
  String get askAgainButton;

  /// No description provided for @climateArid.
  ///
  /// In en, this message translates to:
  /// **'Arid'**
  String get climateArid;

  /// No description provided for @climateTemperate.
  ///
  /// In en, this message translates to:
  /// **'Temperate'**
  String get climateTemperate;

  /// No description provided for @climateTropical.
  ///
  /// In en, this message translates to:
  /// **'Tropical'**
  String get climateTropical;

  /// No description provided for @climateCold.
  ///
  /// In en, this message translates to:
  /// **'Cold'**
  String get climateCold;

  /// No description provided for @climateSemiArid.
  ///
  /// In en, this message translates to:
  /// **'Semi-arid'**
  String get climateSemiArid;

  /// No description provided for @purposeMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get purposeMeat;

  /// No description provided for @purposeMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get purposeMilk;

  /// No description provided for @purposeWool.
  ///
  /// In en, this message translates to:
  /// **'Wool'**
  String get purposeWool;

  /// No description provided for @purposeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get purposeMixed;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @settingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSectionTitle;

  /// No description provided for @enableNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotificationsTitle;

  /// No description provided for @enableNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive reminders and alerts'**
  String get enableNotificationsSubtitle;

  /// No description provided for @dailySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummaryTitle;

  /// No description provided for @dailySummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a daily herd overview'**
  String get dailySummarySubtitle;

  /// No description provided for @scheduleReminderSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule a Reminder'**
  String get scheduleReminderSectionTitle;

  /// No description provided for @notificationTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notificationTitleLabel;

  /// No description provided for @notificationTitleValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get notificationTitleValidation;

  /// No description provided for @notificationMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get notificationMessageLabel;

  /// No description provided for @notificationMessageValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a message'**
  String get notificationMessageValidation;

  /// No description provided for @pickTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get pickTimeLabel;

  /// No description provided for @scheduleNotificationButton.
  ///
  /// In en, this message translates to:
  /// **'Schedule Notification'**
  String get scheduleNotificationButton;

  /// No description provided for @scheduledSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduledSectionTitle;

  /// No description provided for @noScheduledNotifications.
  ///
  /// In en, this message translates to:
  /// **'No scheduled notifications.'**
  String get noScheduledNotifications;

  /// No description provided for @cancelNotificationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelNotificationTooltip;

  /// No description provided for @pleasePickTime.
  ///
  /// In en, this message translates to:
  /// **'Please pick a time.'**
  String get pleasePickTime;

  /// No description provided for @notificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'Notification scheduled.'**
  String get notificationScheduled;

  /// No description provided for @archivedFarmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived Farms'**
  String get archivedFarmsTitle;

  /// No description provided for @noArchivedFarms.
  ///
  /// In en, this message translates to:
  /// **'No archived farms'**
  String get noArchivedFarms;

  /// No description provided for @farmsYouArchiveWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Farms you archive will appear here.'**
  String get farmsYouArchiveWillAppear;

  /// No description provided for @restoreFarmTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore farm'**
  String get restoreFarmTooltip;

  /// No description provided for @deletePermanentlyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanentlyTooltip;

  /// No description provided for @deleteFarmPermanentlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Farm Permanently'**
  String get deleteFarmPermanentlyTitle;

  /// No description provided for @deleteFarmPermanentlyContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{farmName}\" and all its animals and logs? This cannot be undone.'**
  String deleteFarmPermanentlyContent(String farmName);

  /// No description provided for @farmRestored.
  ///
  /// In en, this message translates to:
  /// **'{farmName} restored.'**
  String farmRestored(String farmName);

  /// No description provided for @farmPermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'{farmName} permanently deleted.'**
  String farmPermanentlyDeleted(String farmName);

  /// No description provided for @errorDeletingFarm.
  ///
  /// In en, this message translates to:
  /// **'Error deleting farm: {error}'**
  String errorDeletingFarm(String error);

  /// No description provided for @partnersTitle.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get partnersTitle;

  /// No description provided for @noPartnersYet.
  ///
  /// In en, this message translates to:
  /// **'No partners yet'**
  String get noPartnersYet;

  /// No description provided for @addPartnerToShare.
  ///
  /// In en, this message translates to:
  /// **'Add a partner to share access to this farm.'**
  String get addPartnerToShare;

  /// No description provided for @editPartnerDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Partner'**
  String get editPartnerDialogTitle;

  /// No description provided for @partnerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Partner updated.'**
  String get partnerUpdated;

  /// No description provided for @removePartnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Partner'**
  String get removePartnerTitle;

  /// No description provided for @removePartnerContent.
  ///
  /// In en, this message translates to:
  /// **'Remove {partnerName} from this farm?'**
  String removePartnerContent(String partnerName);

  /// No description provided for @partnerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Partner removed.'**
  String get partnerRemoved;

  /// No description provided for @roleChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Role changed to {role}.'**
  String roleChangedTo(String role);

  /// No description provided for @addPartnerFabLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Partner'**
  String get addPartnerFabLabel;

  /// No description provided for @addPartnerHeader.
  ///
  /// In en, this message translates to:
  /// **'Add Partner'**
  String get addPartnerHeader;

  /// No description provided for @createNewPartnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new partner account'**
  String get createNewPartnerSubtitle;

  /// No description provided for @createPartnerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Partner'**
  String get createPartnerButton;

  /// No description provided for @partnerCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Partner created successfully'**
  String get partnerCreatedSuccessfully;

  /// No description provided for @aiHealthAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Health Assistant'**
  String get aiHealthAssistantTitle;

  /// No description provided for @askAboutHealthHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about this animal\'s health...'**
  String get askAboutHealthHint;

  /// No description provided for @askMeAnythingEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about this animal\'s health'**
  String get askMeAnythingEmptyState;

  /// No description provided for @suggestedQuestionIllness.
  ///
  /// In en, this message translates to:
  /// **'Signs of illness?'**
  String get suggestedQuestionIllness;

  /// No description provided for @suggestedQuestionVaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination schedule?'**
  String get suggestedQuestionVaccination;

  /// No description provided for @suggestedQuestionPregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy care tips?'**
  String get suggestedQuestionPregnancy;

  /// No description provided for @thinkingLabel.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinkingLabel;

  /// No description provided for @aiErrorResponse.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I could not get a response. Please try again.'**
  String get aiErrorResponse;

  /// No description provided for @syncingChanges.
  ///
  /// In en, this message translates to:
  /// **'Syncing changes to cloud'**
  String get syncingChanges;

  /// No description provided for @allChangesSynced.
  ///
  /// In en, this message translates to:
  /// **'All changes synced'**
  String get allChangesSynced;

  /// No description provided for @offlineBannerText.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Changes will sync when online.'**
  String get offlineBannerText;

  /// No description provided for @offlineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Offline. Changes will sync when online.'**
  String get offlineTooltip;

  /// No description provided for @verifyYourEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyYourEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email address. Please check your inbox and verify before continuing.'**
  String get verifyEmailBody;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent.'**
  String get verificationEmailSent;

  /// No description provided for @failedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {error}'**
  String failedToSend(String error);

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @signOutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get yourProfile;

  /// No description provided for @changePasswordSection.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordSection;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password (leave blank to keep)'**
  String get newPasswordLabel;

  /// No description provided for @minSixChars.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get minSixChars;

  /// No description provided for @updateProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfileButton;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated! Check your email to confirm any email change.'**
  String get profileUpdated;

  /// No description provided for @avatarUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Avatar upload failed: {error}'**
  String avatarUploadFailed(String error);

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language / Langue / لغة'**
  String get languageLabel;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
