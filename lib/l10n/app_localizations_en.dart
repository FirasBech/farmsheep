// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FarmSheep';

  @override
  String get smartFarmManagement => 'Smart Farm Management';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get deleteButton => 'Delete';

  @override
  String get doneButton => 'Done';

  @override
  String get addButton => 'Add';

  @override
  String get closeButton => 'Close';

  @override
  String get removeButton => 'Remove';

  @override
  String get editMenuItem => 'Edit';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get noFarmSelected => 'No farm selected.';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get notesLabel => 'Notes';

  @override
  String get typeLabel => 'Type';

  @override
  String get dateLabel => 'Date';

  @override
  String get priceLabel => 'Price';

  @override
  String get roleLabel => 'Role';

  @override
  String get sourceLabel => 'Source';

  @override
  String get requiredValidation => 'Required';

  @override
  String get makeAdminMenuItem => 'Make Admin';

  @override
  String get makePartnerMenuItem => 'Make Partner';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToFarmAccount => 'Sign in to your farm account';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signInButton => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get registerButton => 'Register';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get enterEmailFirst => 'Enter your email above first';

  @override
  String get passwordResetSent => 'Password reset email sent!';

  @override
  String failed(String error) {
    return 'Failed: $error';
  }

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinFarmSheepToday => 'Join FarmSheep today';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get accountCreated => 'Account created! Check your email to verify.';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get passwordWeak => 'Weak';

  @override
  String get passwordMedium => 'Medium';

  @override
  String get passwordStrong => 'Strong';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get profileTooltip => 'Profile';

  @override
  String get welcomeNotificationTitle => 'Welcome';

  @override
  String get welcomeNotificationBody =>
      'Check your animals and logs for today!';

  @override
  String get tileAnimals => 'Animals';

  @override
  String get tileFarmDashboard => 'Farm Dashboard';

  @override
  String get tileLogs => 'Logs';

  @override
  String get tileBreedManagement => 'Breed Management';

  @override
  String get tileAddPartner => 'Add Partner';

  @override
  String get tileAdminLogs => 'Admin Logs';

  @override
  String get tileUserManagement => 'User Management';

  @override
  String get tileAdminOverride => 'Admin Override';

  @override
  String get tileAnimalSearchExport => 'Animal Search & Export';

  @override
  String get tileLogSearchExport => 'Log Search & Export';

  @override
  String get tileLogout => 'Logout';

  @override
  String get alertsNotificationsTitle => 'Alerts & Notifications';

  @override
  String get alertsNotificationsSubtitle =>
      'View and manage farm notifications';

  @override
  String get statAnimals => 'Animals';

  @override
  String get statPartners => 'Partners';

  @override
  String get statLogs => 'Logs';

  @override
  String get animalsScreenTitle => 'Animals';

  @override
  String get exportCsvTooltip => 'Export CSV';

  @override
  String get addAnimalTooltip => 'Add Animal';

  @override
  String get searchByTagIdLabel => 'Search by Tag ID';

  @override
  String get searchByTagIdHint => 'Enter tag number...';

  @override
  String get allTypesHint => 'All Types';

  @override
  String get allStatusesHint => 'All Statuses';

  @override
  String get noAnimalsFound => 'No animals found';

  @override
  String get tryAdjustingFilters => 'Try adjusting your search filters';

  @override
  String get addFirstAnimal => 'Add your first animal to get started!';

  @override
  String get askAiTooltip => 'Ask AI';

  @override
  String get exportPdfTooltip => 'Export PDF';

  @override
  String get deleteAnimalDialogTitle => 'Delete Animal';

  @override
  String get deleteAnimalDialogContent =>
      'Are you sure you want to delete this animal?';

  @override
  String pdfFailed(String error) {
    return 'PDF failed: $error';
  }

  @override
  String get tagNumberLabel => 'Tag Number';

  @override
  String get bornLabel => 'Born';

  @override
  String get ageLabel => 'Age';

  @override
  String get tagColorLabel => 'Tag Color';

  @override
  String get physicalSectionHeader => 'Physical';

  @override
  String get sexLabel => 'Sex';

  @override
  String get weightLabel => 'Weight';

  @override
  String get bcsLabel => 'Body Condition Score';

  @override
  String get microchipLabel => 'Microchip';

  @override
  String get originSectionHeader => 'Origin';

  @override
  String get acquiredLabel => 'Acquired';

  @override
  String get purchaseDateLabel => 'Purchase Date';

  @override
  String get lineageSectionHeader => 'Lineage';

  @override
  String get sireFatherLabel => 'Sire (Father)';

  @override
  String get sireIdLabel => 'Sire ID';

  @override
  String get damMotherLabel => 'Dam (Mother)';

  @override
  String get damIdLabel => 'Dam ID';

  @override
  String get notesSectionHeader => 'Notes';

  @override
  String get pregnancyHistoryHeader => 'Pregnancy History';

  @override
  String get birthLogHeader => 'Birth Log';

  @override
  String get healthLogsHeader => 'Health Logs';

  @override
  String get saleInfoHeader => 'Sale Info';

  @override
  String get buyerLabel => 'Buyer';

  @override
  String get aiHealthRiskAssessmentTitle => 'AI Health Risk Assessment';

  @override
  String get aiRiskAssessmentButton => 'AI Risk Assessment';

  @override
  String get analyzingLabel => 'Analyzing...';

  @override
  String get stillWorkingLabel => 'Still working...';

  @override
  String get addAnimalScreenTitle => 'Add Animal';

  @override
  String get editAnimalScreenTitle => 'Edit Animal';

  @override
  String get identificationSection => 'Identification';

  @override
  String get tagNumberFieldLabel => 'Tag Number *';

  @override
  String get tagNumberFieldHint => 'Enter unique ear tag number';

  @override
  String get tagColorTileTitle => 'Tag Color';

  @override
  String get pickTagColorDialogTitle => 'Pick Tag Color';

  @override
  String get microchipRfidLabel => 'Microchip / RFID';

  @override
  String get microchipRfidHint => 'Optional electronic ID';

  @override
  String get animalDetailsSection => 'Animal Details';

  @override
  String get breedLabel => 'Breed';

  @override
  String get breedHint => 'Select breed';

  @override
  String get pickBirthDate => 'Pick birth date *';

  @override
  String get birthDatePrefix => 'Birth Date: ';

  @override
  String get originSection => 'Origin';

  @override
  String get acquisitionTypeLabel => 'Acquisition Type';

  @override
  String get howWasAnimalAcquired => 'How was this animal acquired?';

  @override
  String get typeSheep => 'Sheep';

  @override
  String get typeGoat => 'Goat';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexMale => 'Male';

  @override
  String get sexWether => 'Wether';

  @override
  String get sexUnknown => 'Unknown';

  @override
  String get acquisitionBornOnFarm => 'Born on Farm';

  @override
  String get acquisitionPurchased => 'Purchased';

  @override
  String get acquisitionGifted => 'Gifted';

  @override
  String get purchaseSourceLabel => 'Purchase Source';

  @override
  String get purchaseSourceHint => 'Seller / Market name';

  @override
  String get purchasePriceLabel => 'Purchase Price';

  @override
  String get purchasePriceHint => 'Amount paid';

  @override
  String get purchaseDateTile => 'Purchase Date';

  @override
  String get purchasedDatePrefix => 'Purchased: ';

  @override
  String get lineageSection => 'Lineage';

  @override
  String get sireTagNameLabel => 'Sire Tag / Name';

  @override
  String get sireTagNameHint => 'Father';

  @override
  String get sireIdHint => 'Optional';

  @override
  String get damTagNameLabel => 'Dam Tag / Name';

  @override
  String get damTagNameHint => 'Mother';

  @override
  String get damIdHint => 'Optional';

  @override
  String get physicalSection => 'Physical';

  @override
  String get currentWeightLabel => 'Current Weight (kg)';

  @override
  String get currentWeightHint => 'e.g. 45.5';

  @override
  String get bodyConditionScoreLabel => 'Body Condition Score (BCS)';

  @override
  String get notesSection => 'Notes';

  @override
  String get notesHint => 'Any additional observations';

  @override
  String get photosSection => 'Photos';

  @override
  String get cameraButton => 'Camera';

  @override
  String get galleryButton => 'Gallery';

  @override
  String get saveAnimalButton => 'Save Animal';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get cropImageTitle => 'Crop Image';

  @override
  String get birthDateRequired => 'Birth date is required.';

  @override
  String get tagNumberMustBePositive =>
      'Tag number must be a positive integer.';

  @override
  String couldNotPickImage(String error) {
    return 'Could not pick image: $error';
  }

  @override
  String errorSavingAnimal(String error) {
    return 'Error saving animal: $error';
  }

  @override
  String errorUpdatingAnimal(String error) {
    return 'Error updating animal: $error';
  }

  @override
  String get animalSearchExportTitle => 'Animal Search & Export';

  @override
  String get searchByTagOrBreed => 'Search by tag or breed';

  @override
  String get yourFarmsTitle => 'Your Farms';

  @override
  String get viewArchivedFarms => 'View Archived Farms';

  @override
  String get noFarmsFound => 'No farms found';

  @override
  String get addFirstFarm => 'Add your first farm to get started!';

  @override
  String get archiveFarmTitle => 'Archive Farm';

  @override
  String get archiveFarmConfirm =>
      'Are you sure you want to archive this farm? You can restore it later.';

  @override
  String get archiveButton => 'Archive';

  @override
  String get deleteFarmTitle => 'Delete Farm';

  @override
  String get deleteFarmConfirm =>
      'Are you sure you want to delete this farm? All animals and logs will be permanently deleted.';

  @override
  String get farmArchived => 'Farm archived.';

  @override
  String get farmDeleted => 'Farm deleted.';

  @override
  String get addFarmFab => 'Add Farm';

  @override
  String get addNewFarmDialogTitle => 'Add New Farm';

  @override
  String get farmNameLabel => 'Farm Name';

  @override
  String get farmNameHint => 'Enter farm name';

  @override
  String get farmNameRequired => 'Please enter a farm name';

  @override
  String get addressLabel => 'Address';

  @override
  String get addressHint => 'Enter farm address';

  @override
  String get addressRequired => 'Please enter a farm address';

  @override
  String get notesOptionalLabel => 'Notes (Optional)';

  @override
  String get additionalFarmInfo => 'Additional farm information';

  @override
  String get farmAddedSuccessfully => 'Farm added successfully!';

  @override
  String errorAddingFarm(String error) {
    return 'Error adding farm: $error';
  }

  @override
  String get farmDashboardTitle => 'Farm Dashboard';

  @override
  String get farmSettingsTooltip => 'Farm Settings';

  @override
  String get aiHerdSummaryTitle => 'AI Herd Summary';

  @override
  String get aiHerdSummaryGenerateTap =>
      'Tap \"Generate\" to get an AI overview of your herd.';

  @override
  String get generatingLabel => 'Generating...';

  @override
  String get refreshSummaryButton => 'Refresh Summary';

  @override
  String get generateAiSummaryButton => 'Generate AI Summary';

  @override
  String get tileFarmActivity => 'Farm Activity';

  @override
  String get tileProfileUsers => 'Profile / Users';

  @override
  String get farmSettingsTitle => 'Farm Settings';

  @override
  String get notesSectionTitle => 'Notes';

  @override
  String get preferredBreedsSectionTitle => 'Preferred Breeds';

  @override
  String get preferredBreedsHint => 'Damani, Dimashqi, Mixed...';

  @override
  String get preferredBreedsHelper => 'Comma-separated breed names';

  @override
  String get farmColorSectionTitle => 'Farm Color';

  @override
  String get currentColorLabel => 'Current color:';

  @override
  String get pickFarmColorDialogTitle => 'Pick Farm Color';

  @override
  String get tapToChange => 'Tap to change';

  @override
  String get partnerPermissionsSectionTitle => 'Partner Permissions';

  @override
  String get allowPartnersAddAnimalsTitle => 'Allow partners to add animals';

  @override
  String get allowPartnersAddAnimalsSubtitle =>
      'Partners can add new animals to the farm';

  @override
  String get allowPartnersEditLogsTitle => 'Allow partners to edit logs';

  @override
  String get allowPartnersEditLogsSubtitle =>
      'Partners can create and edit manual logs';

  @override
  String get saveSettingsButton => 'Save Settings';

  @override
  String get farmSettingsUpdated => 'Farm settings updated.';

  @override
  String get addManualLogTitle => 'Add Manual Log';

  @override
  String get logDetailsSectionTitle => 'Log Details';

  @override
  String get actionTypeLabel => 'Action Type';

  @override
  String get animalIdsLabel => 'Animal IDs (comma-separated)';

  @override
  String get getAiSuggestionButton => 'Get AI Suggestion';

  @override
  String get gettingSuggestion => 'Getting suggestion...';

  @override
  String get saveManualLogTooltip => 'Save manual log';

  @override
  String get addAnimalsFirst => 'Add animals to the farm first.';

  @override
  String get aiSuggestionApplied => 'AI suggestion applied!';

  @override
  String aiSuggestionFailed(String error) {
    return 'AI suggestion failed: $error';
  }

  @override
  String get userNotSignedIn => 'User not signed in';

  @override
  String errorSaving(String error) {
    return 'Error: $error';
  }

  @override
  String get actionFeeding => 'Feeding';

  @override
  String get actionDeworming => 'Deworming';

  @override
  String get actionCleaning => 'Cleaning';

  @override
  String get actionVaccination => 'Vaccination';

  @override
  String get actionMedication => 'Medication';

  @override
  String get actionTreatment => 'Treatment';

  @override
  String get actionHealthCheck => 'Health Check';

  @override
  String get actionObservation => 'Observation';

  @override
  String get actionOther => 'Other';

  @override
  String get manualLogsTitle => 'Manual Logs';

  @override
  String get noLogsFound => 'No logs found.';

  @override
  String get logSearchExportTitle => 'Log Search & Export';

  @override
  String get searchByTypeOrNotes => 'Search by type or notes';

  @override
  String get dateRangeButton => 'Date Range';

  @override
  String get auditTrailHeader => 'Audit Trail (Admin Only)';

  @override
  String get farmActivityLogTitle => 'Farm Activity Log';

  @override
  String get noActivityYet => 'No activity yet';

  @override
  String get farmActionsWillAppear => 'Farm actions will appear here.';

  @override
  String get activityLogsTitle => 'Activity Logs';

  @override
  String get accessDenied => 'Access Denied';

  @override
  String get noActivityLogsFound => 'No activity logs found.';

  @override
  String get adminRecordOverrideTitle => 'Admin Record Override';

  @override
  String get adminAccessRequired => 'Admin access required';

  @override
  String get searchAnimalsByTagOrBreed => 'Search animals by tag or breed';

  @override
  String get overrideThisRecord => 'Override this record';

  @override
  String get recentOverridesHeader => 'Recent Overrides';

  @override
  String get noOverridesRecorded => 'No overrides recorded yet.';

  @override
  String overrideAnimalDialogTitle(String tagNumber) {
    return 'Override Animal #$tagNumber';
  }

  @override
  String get reasonForOverrideLabel => 'Reason for Override *';

  @override
  String get reasonForOverrideHint =>
      'Explain why this record is being changed';

  @override
  String get reasonRequiredValidation =>
      'A reason is required for admin overrides';

  @override
  String get saveOverrideButton => 'Save Override';

  @override
  String get overrideSaved => 'Override saved and logged in audit trail.';

  @override
  String get userManagementTitle => 'User Management';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get resetPasswordMenuItem => 'Reset Password';

  @override
  String get passwordResetEmailSent => 'Password reset email sent.';

  @override
  String roleUpdatedTo(String role) {
    return 'Role updated to $role.';
  }

  @override
  String get breedManagementTitle => 'Breed Management';

  @override
  String get addBreedSectionTitle => 'Add Breed';

  @override
  String get enterBreedName => 'Enter breed name';

  @override
  String get noBreedsAdded => 'No breeds added.';

  @override
  String get removeBreedTooltip => 'Remove breed';

  @override
  String get aiRecommendFab => 'AI Recommend';

  @override
  String get aiBreedRecommendationTitle => 'AI Breed Recommendation';

  @override
  String get climateLabel => 'Climate';

  @override
  String get purposeLabel => 'Purpose';

  @override
  String get additionalPreferencesLabel => 'Additional Preferences (optional)';

  @override
  String get additionalPreferencesHint =>
      'e.g. hardy, low maintenance, good mothers';

  @override
  String get consultingAiSpecialist => 'Consulting AI breed specialist...';

  @override
  String get getRecommendationsButton => 'Get Recommendations';

  @override
  String get askAgainButton => 'Ask Again';

  @override
  String get climateArid => 'Arid';

  @override
  String get climateTemperate => 'Temperate';

  @override
  String get climateTropical => 'Tropical';

  @override
  String get climateCold => 'Cold';

  @override
  String get climateSemiArid => 'Semi-arid';

  @override
  String get purposeMeat => 'Meat';

  @override
  String get purposeMilk => 'Milk';

  @override
  String get purposeWool => 'Wool';

  @override
  String get purposeMixed => 'Mixed';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get settingsSectionTitle => 'Settings';

  @override
  String get enableNotificationsTitle => 'Enable Notifications';

  @override
  String get enableNotificationsSubtitle => 'Receive reminders and alerts';

  @override
  String get dailySummaryTitle => 'Daily Summary';

  @override
  String get dailySummarySubtitle => 'Get a daily herd overview';

  @override
  String get scheduleReminderSectionTitle => 'Schedule a Reminder';

  @override
  String get notificationTitleLabel => 'Title';

  @override
  String get notificationTitleValidation => 'Enter a title';

  @override
  String get notificationMessageLabel => 'Message';

  @override
  String get notificationMessageValidation => 'Enter a message';

  @override
  String get pickTimeLabel => 'Pick time';

  @override
  String get scheduleNotificationButton => 'Schedule Notification';

  @override
  String get scheduledSectionTitle => 'Scheduled';

  @override
  String get noScheduledNotifications => 'No scheduled notifications.';

  @override
  String get cancelNotificationTooltip => 'Cancel';

  @override
  String get pleasePickTime => 'Please pick a time.';

  @override
  String get notificationScheduled => 'Notification scheduled.';

  @override
  String get archivedFarmsTitle => 'Archived Farms';

  @override
  String get noArchivedFarms => 'No archived farms';

  @override
  String get farmsYouArchiveWillAppear => 'Farms you archive will appear here.';

  @override
  String get restoreFarmTooltip => 'Restore farm';

  @override
  String get deletePermanentlyTooltip => 'Delete permanently';

  @override
  String get deleteFarmPermanentlyTitle => 'Delete Farm Permanently';

  @override
  String deleteFarmPermanentlyContent(String farmName) {
    return 'Delete \"$farmName\" and all its animals and logs? This cannot be undone.';
  }

  @override
  String farmRestored(String farmName) {
    return '$farmName restored.';
  }

  @override
  String farmPermanentlyDeleted(String farmName) {
    return '$farmName permanently deleted.';
  }

  @override
  String errorDeletingFarm(String error) {
    return 'Error deleting farm: $error';
  }

  @override
  String get partnersTitle => 'Partners';

  @override
  String get noPartnersYet => 'No partners yet';

  @override
  String get addPartnerToShare => 'Add a partner to share access to this farm.';

  @override
  String get editPartnerDialogTitle => 'Edit Partner';

  @override
  String get partnerUpdated => 'Partner updated.';

  @override
  String get removePartnerTitle => 'Remove Partner';

  @override
  String removePartnerContent(String partnerName) {
    return 'Remove $partnerName from this farm?';
  }

  @override
  String get partnerRemoved => 'Partner removed.';

  @override
  String roleChangedTo(String role) {
    return 'Role changed to $role.';
  }

  @override
  String get addPartnerFabLabel => 'Add Partner';

  @override
  String get addPartnerHeader => 'Add Partner';

  @override
  String get createNewPartnerSubtitle => 'Create a new partner account';

  @override
  String get createPartnerButton => 'Create Partner';

  @override
  String get partnerCreatedSuccessfully => 'Partner created successfully';

  @override
  String get aiHealthAssistantTitle => 'AI Health Assistant';

  @override
  String get askAboutHealthHint => 'Ask about this animal\'s health...';

  @override
  String get askMeAnythingEmptyState =>
      'Ask me anything about this animal\'s health';

  @override
  String get suggestedQuestionIllness => 'Signs of illness?';

  @override
  String get suggestedQuestionVaccination => 'Vaccination schedule?';

  @override
  String get suggestedQuestionPregnancy => 'Pregnancy care tips?';

  @override
  String get thinkingLabel => 'Thinking...';

  @override
  String get aiErrorResponse =>
      'Sorry, I could not get a response. Please try again.';

  @override
  String get syncingChanges => 'Syncing changes to cloud';

  @override
  String get allChangesSynced => 'All changes synced';

  @override
  String get offlineBannerText =>
      'You are offline. Changes will sync when online.';

  @override
  String get offlineTooltip => 'Offline. Changes will sync when online.';

  @override
  String get verifyYourEmailTitle => 'Verify your email';

  @override
  String get verifyEmailBody =>
      'We sent a verification link to your email address. Please check your inbox and verify before continuing.';

  @override
  String get verificationEmailSent => 'Verification email sent.';

  @override
  String failedToSend(String error) {
    return 'Failed to send: $error';
  }

  @override
  String get resendVerificationEmail => 'Resend verification email';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get yourProfile => 'Your Profile';

  @override
  String get changePasswordSection => 'Change Password';

  @override
  String get newPasswordLabel => 'New Password (leave blank to keep)';

  @override
  String get minSixChars => 'Min 6 characters';

  @override
  String get updateProfileButton => 'Update Profile';

  @override
  String get profileUpdated =>
      'Profile updated! Check your email to confirm any email change.';

  @override
  String avatarUploadFailed(String error) {
    return 'Avatar upload failed: $error';
  }

  @override
  String get languageLabel => 'Language / Langue / لغة';

  @override
  String get selectLanguage => 'Select Language';
}
