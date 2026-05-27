// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FarmSheep';

  @override
  String get smartFarmManagement => 'Gestion intelligente de ferme';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get doneButton => 'Terminé';

  @override
  String get addButton => 'Ajouter';

  @override
  String get closeButton => 'Fermer';

  @override
  String get removeButton => 'Retirer';

  @override
  String get editMenuItem => 'Modifier';

  @override
  String get refreshTooltip => 'Actualiser';

  @override
  String get noFarmSelected => 'Aucune ferme sélectionnée.';

  @override
  String get nameLabel => 'Nom';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get notesLabel => 'Notes';

  @override
  String get typeLabel => 'Type';

  @override
  String get dateLabel => 'Date';

  @override
  String get priceLabel => 'Prix';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get sourceLabel => 'Source';

  @override
  String get requiredValidation => 'Obligatoire';

  @override
  String get makeAdminMenuItem => 'Rendre administrateur';

  @override
  String get makePartnerMenuItem => 'Rendre partenaire';

  @override
  String errorWithMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get signInToFarmAccount => 'Connectez-vous à votre compte agricole';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get dontHaveAccount => 'Pas encore de compte ?';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String loginFailed(String error) {
    return 'Échec de connexion : $error';
  }

  @override
  String get enterEmailFirst => 'Saisissez d\'abord votre e-mail ci-dessus';

  @override
  String get passwordResetSent => 'E-mail de réinitialisation envoyé !';

  @override
  String failed(String error) {
    return 'Échec : $error';
  }

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinFarmSheepToday => 'Rejoignez FarmSheep aujourd\'hui';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get enterYourName => 'Entrez votre nom';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get confirmNewPasswordLabel => 'Confirmer le nouveau mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get accountCreated => 'Compte créé ! Vérifiez votre e-mail.';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get passwordWeak => 'Faible';

  @override
  String get passwordMedium => 'Moyen';

  @override
  String get passwordStrong => 'Fort';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get profileTooltip => 'Profil';

  @override
  String get welcomeNotificationTitle => 'Bienvenue';

  @override
  String get welcomeNotificationBody =>
      'Vérifiez vos animaux et journaux du jour !';

  @override
  String get tileAnimals => 'Animaux';

  @override
  String get tileFarmDashboard => 'Tableau de bord';

  @override
  String get tileLogs => 'Journaux';

  @override
  String get tileBreedManagement => 'Gestion des races';

  @override
  String get tileAddPartner => 'Ajouter un partenaire';

  @override
  String get tileAdminLogs => 'Journaux admin';

  @override
  String get tileUserManagement => 'Gestion des utilisateurs';

  @override
  String get tileAdminOverride => 'Correction admin';

  @override
  String get tileAnimalSearchExport => 'Recherche & export animaux';

  @override
  String get tileLogSearchExport => 'Recherche & export journaux';

  @override
  String get tileLogout => 'Déconnexion';

  @override
  String get alertsNotificationsTitle => 'Alertes & Notifications';

  @override
  String get alertsNotificationsSubtitle =>
      'Voir et gérer les notifications de la ferme';

  @override
  String get statAnimals => 'Animaux';

  @override
  String get statPartners => 'Partenaires';

  @override
  String get statLogs => 'Journaux';

  @override
  String get animalsScreenTitle => 'Animaux';

  @override
  String get exportCsvTooltip => 'Exporter CSV';

  @override
  String get addAnimalTooltip => 'Ajouter un animal';

  @override
  String get searchByTagIdLabel => 'Rechercher par numéro de bague';

  @override
  String get searchByTagIdHint => 'Entrez le numéro...';

  @override
  String get allTypesHint => 'Tous les types';

  @override
  String get allStatusesHint => 'Tous les statuts';

  @override
  String get noAnimalsFound => 'Aucun animal trouvé';

  @override
  String get tryAdjustingFilters =>
      'Essayez d\'ajuster vos filtres de recherche';

  @override
  String get addFirstAnimal => 'Ajoutez votre premier animal pour commencer !';

  @override
  String get askAiTooltip => 'Demander à l\'IA';

  @override
  String get exportPdfTooltip => 'Exporter PDF';

  @override
  String get deleteAnimalDialogTitle => 'Supprimer l\'animal';

  @override
  String get deleteAnimalDialogContent =>
      'Êtes-vous sûr de vouloir supprimer cet animal ?';

  @override
  String pdfFailed(String error) {
    return 'Échec PDF : $error';
  }

  @override
  String get tagNumberLabel => 'Numéro de bague';

  @override
  String get bornLabel => 'Né(e)';

  @override
  String get ageLabel => 'Âge';

  @override
  String get tagColorLabel => 'Couleur de bague';

  @override
  String get physicalSectionHeader => 'Physique';

  @override
  String get sexLabel => 'Sexe';

  @override
  String get weightLabel => 'Poids';

  @override
  String get bcsLabel => 'Score d\'état corporel';

  @override
  String get microchipLabel => 'Micropuce';

  @override
  String get originSectionHeader => 'Origine';

  @override
  String get acquiredLabel => 'Acquis';

  @override
  String get purchaseDateLabel => 'Date d\'achat';

  @override
  String get lineageSectionHeader => 'Lignée';

  @override
  String get sireFatherLabel => 'Père (Bélier)';

  @override
  String get sireIdLabel => 'ID du père';

  @override
  String get damMotherLabel => 'Mère (Brebis)';

  @override
  String get damIdLabel => 'ID de la mère';

  @override
  String get notesSectionHeader => 'Notes';

  @override
  String get pregnancyHistoryHeader => 'Historique de gestation';

  @override
  String get birthLogHeader => 'Journal des naissances';

  @override
  String get healthLogsHeader => 'Journaux de santé';

  @override
  String get saleInfoHeader => 'Info vente';

  @override
  String get buyerLabel => 'Acheteur';

  @override
  String get aiHealthRiskAssessmentTitle =>
      'Évaluation IA des risques sanitaires';

  @override
  String get aiRiskAssessmentButton => 'Évaluation IA';

  @override
  String get analyzingLabel => 'Analyse en cours...';

  @override
  String get stillWorkingLabel => 'Toujours en cours...';

  @override
  String get addAnimalScreenTitle => 'Ajouter un animal';

  @override
  String get editAnimalScreenTitle => 'Modifier l\'animal';

  @override
  String get identificationSection => 'Identification';

  @override
  String get tagNumberFieldLabel => 'Numéro de bague *';

  @override
  String get tagNumberFieldHint => 'Entrez un numéro de bague unique';

  @override
  String get tagColorTileTitle => 'Couleur de bague';

  @override
  String get pickTagColorDialogTitle => 'Choisir la couleur de bague';

  @override
  String get microchipRfidLabel => 'Micropuce / RFID';

  @override
  String get microchipRfidHint => 'ID électronique (optionnel)';

  @override
  String get animalDetailsSection => 'Détails de l\'animal';

  @override
  String get breedLabel => 'Race';

  @override
  String get breedHint => 'Sélectionner la race';

  @override
  String get pickBirthDate => 'Choisir la date de naissance *';

  @override
  String get birthDatePrefix => 'Date de naissance : ';

  @override
  String get originSection => 'Origine';

  @override
  String get acquisitionTypeLabel => 'Type d\'acquisition';

  @override
  String get howWasAnimalAcquired => 'Comment cet animal a-t-il été acquis ?';

  @override
  String get typeSheep => 'Mouton';

  @override
  String get typeGoat => 'Chèvre';

  @override
  String get sexFemale => 'Femelle';

  @override
  String get sexMale => 'Mâle';

  @override
  String get sexWether => 'Castrat';

  @override
  String get sexUnknown => 'Inconnu';

  @override
  String get acquisitionBornOnFarm => 'Né à la ferme';

  @override
  String get acquisitionPurchased => 'Acheté';

  @override
  String get acquisitionGifted => 'Offert';

  @override
  String get purchaseSourceLabel => 'Source d\'achat';

  @override
  String get purchaseSourceHint => 'Nom du vendeur / marché';

  @override
  String get purchasePriceLabel => 'Prix d\'achat';

  @override
  String get purchasePriceHint => 'Montant payé';

  @override
  String get purchaseDateTile => 'Date d\'achat';

  @override
  String get purchasedDatePrefix => 'Acheté le : ';

  @override
  String get lineageSection => 'Lignée';

  @override
  String get sireTagNameLabel => 'Bague / Nom du père';

  @override
  String get sireTagNameHint => 'Père';

  @override
  String get sireIdHint => 'Optionnel';

  @override
  String get damTagNameLabel => 'Bague / Nom de la mère';

  @override
  String get damTagNameHint => 'Mère';

  @override
  String get damIdHint => 'Optionnel';

  @override
  String get physicalSection => 'Physique';

  @override
  String get currentWeightLabel => 'Poids actuel (kg)';

  @override
  String get currentWeightHint => 'ex. 45,5';

  @override
  String get bodyConditionScoreLabel => 'Score d\'état corporel (BCS)';

  @override
  String get notesSection => 'Notes';

  @override
  String get notesHint => 'Observations supplémentaires';

  @override
  String get photosSection => 'Photos';

  @override
  String get cameraButton => 'Caméra';

  @override
  String get galleryButton => 'Galerie';

  @override
  String get saveAnimalButton => 'Enregistrer l\'animal';

  @override
  String get saveChangesButton => 'Sauvegarder';

  @override
  String get cropImageTitle => 'Recadrer l\'image';

  @override
  String get birthDateRequired => 'La date de naissance est requise.';

  @override
  String get tagNumberMustBePositive =>
      'Le numéro de bague doit être un entier positif.';

  @override
  String couldNotPickImage(String error) {
    return 'Impossible de sélectionner l\'image : $error';
  }

  @override
  String errorSavingAnimal(String error) {
    return 'Erreur lors de l\'enregistrement : $error';
  }

  @override
  String errorUpdatingAnimal(String error) {
    return 'Erreur lors de la mise à jour : $error';
  }

  @override
  String get animalSearchExportTitle => 'Recherche & Export animaux';

  @override
  String get searchByTagOrBreed => 'Rechercher par bague ou race';

  @override
  String get yourFarmsTitle => 'Vos fermes';

  @override
  String get viewArchivedFarms => 'Voir les fermes archivées';

  @override
  String get noFarmsFound => 'Aucune ferme trouvée';

  @override
  String get addFirstFarm => 'Ajoutez votre première ferme pour commencer !';

  @override
  String get archiveFarmTitle => 'Archiver la ferme';

  @override
  String get archiveFarmConfirm =>
      'Êtes-vous sûr de vouloir archiver cette ferme ? Vous pourrez la restaurer plus tard.';

  @override
  String get archiveButton => 'Archiver';

  @override
  String get deleteFarmTitle => 'Supprimer la ferme';

  @override
  String get deleteFarmConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette ferme ? Tous les animaux et journaux seront définitivement supprimés.';

  @override
  String get farmArchived => 'Ferme archivée.';

  @override
  String get farmDeleted => 'Ferme supprimée.';

  @override
  String get addFarmFab => 'Ajouter une ferme';

  @override
  String get addNewFarmDialogTitle => 'Ajouter une nouvelle ferme';

  @override
  String get farmNameLabel => 'Nom de la ferme';

  @override
  String get farmNameHint => 'Entrez le nom de la ferme';

  @override
  String get farmNameRequired => 'Veuillez entrer un nom de ferme';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get addressHint => 'Entrez l\'adresse de la ferme';

  @override
  String get addressRequired => 'Veuillez entrer une adresse';

  @override
  String get notesOptionalLabel => 'Notes (Optionnel)';

  @override
  String get additionalFarmInfo => 'Informations supplémentaires sur la ferme';

  @override
  String get farmAddedSuccessfully => 'Ferme ajoutée avec succès !';

  @override
  String errorAddingFarm(String error) {
    return 'Erreur lors de l\'ajout : $error';
  }

  @override
  String get farmDashboardTitle => 'Tableau de bord';

  @override
  String get farmSettingsTooltip => 'Paramètres de la ferme';

  @override
  String get aiHerdSummaryTitle => 'Résumé IA du troupeau';

  @override
  String get aiHerdSummaryGenerateTap =>
      'Appuyez sur \"Générer\" pour obtenir un aperçu IA de votre troupeau.';

  @override
  String get generatingLabel => 'Génération en cours...';

  @override
  String get refreshSummaryButton => 'Actualiser le résumé';

  @override
  String get generateAiSummaryButton => 'Générer un résumé IA';

  @override
  String get tileFarmActivity => 'Activité de la ferme';

  @override
  String get tileProfileUsers => 'Profil / Utilisateurs';

  @override
  String get farmSettingsTitle => 'Paramètres de la ferme';

  @override
  String get notesSectionTitle => 'Notes';

  @override
  String get preferredBreedsSectionTitle => 'Races préférées';

  @override
  String get preferredBreedsHint => 'Damani, Dimashqi, Mixte...';

  @override
  String get preferredBreedsHelper => 'Noms de races séparés par des virgules';

  @override
  String get farmColorSectionTitle => 'Couleur de la ferme';

  @override
  String get currentColorLabel => 'Couleur actuelle :';

  @override
  String get pickFarmColorDialogTitle => 'Choisir la couleur';

  @override
  String get tapToChange => 'Appuyer pour modifier';

  @override
  String get partnerPermissionsSectionTitle => 'Permissions des partenaires';

  @override
  String get allowPartnersAddAnimalsTitle =>
      'Autoriser les partenaires à ajouter des animaux';

  @override
  String get allowPartnersAddAnimalsSubtitle =>
      'Les partenaires peuvent ajouter de nouveaux animaux à la ferme';

  @override
  String get allowPartnersEditLogsTitle =>
      'Autoriser les partenaires à modifier les journaux';

  @override
  String get allowPartnersEditLogsSubtitle =>
      'Les partenaires peuvent créer et modifier des journaux';

  @override
  String get saveSettingsButton => 'Enregistrer les paramètres';

  @override
  String get farmSettingsUpdated => 'Paramètres de la ferme mis à jour.';

  @override
  String get addManualLogTitle => 'Ajouter un journal';

  @override
  String get logDetailsSectionTitle => 'Détails du journal';

  @override
  String get actionTypeLabel => 'Type d\'action';

  @override
  String get animalIdsLabel => 'IDs des animaux (séparés par des virgules)';

  @override
  String get getAiSuggestionButton => 'Suggestion IA';

  @override
  String get gettingSuggestion => 'Obtention de la suggestion...';

  @override
  String get saveManualLogTooltip => 'Enregistrer le journal';

  @override
  String get addAnimalsFirst => 'Ajoutez d\'abord des animaux à la ferme.';

  @override
  String get aiSuggestionApplied => 'Suggestion IA appliquée !';

  @override
  String aiSuggestionFailed(String error) {
    return 'Échec de la suggestion IA : $error';
  }

  @override
  String get userNotSignedIn => 'Utilisateur non connecté';

  @override
  String errorSaving(String error) {
    return 'Erreur : $error';
  }

  @override
  String get actionFeeding => 'Alimentation';

  @override
  String get actionDeworming => 'Vermifugation';

  @override
  String get actionCleaning => 'Nettoyage';

  @override
  String get actionVaccination => 'Vaccination';

  @override
  String get actionMedication => 'Médicament';

  @override
  String get actionTreatment => 'Traitement';

  @override
  String get actionHealthCheck => 'Bilan de santé';

  @override
  String get actionObservation => 'Observation';

  @override
  String get actionOther => 'Autre';

  @override
  String get manualLogsTitle => 'Journaux manuels';

  @override
  String get noLogsFound => 'Aucun journal trouvé.';

  @override
  String get logSearchExportTitle => 'Recherche & Export journaux';

  @override
  String get searchByTypeOrNotes => 'Rechercher par type ou notes';

  @override
  String get dateRangeButton => 'Plage de dates';

  @override
  String get auditTrailHeader => 'Piste d\'audit (Admin uniquement)';

  @override
  String get farmActivityLogTitle => 'Journal d\'activité';

  @override
  String get noActivityYet => 'Aucune activité pour l\'instant';

  @override
  String get farmActionsWillAppear =>
      'Les actions de la ferme apparaîtront ici.';

  @override
  String get activityLogsTitle => 'Journaux d\'activité';

  @override
  String get accessDenied => 'Accès refusé';

  @override
  String get noActivityLogsFound => 'Aucun journal d\'activité trouvé.';

  @override
  String get adminRecordOverrideTitle => 'Correction de dossier admin';

  @override
  String get adminAccessRequired => 'Accès administrateur requis';

  @override
  String get searchAnimalsByTagOrBreed =>
      'Rechercher les animaux par bague ou race';

  @override
  String get overrideThisRecord => 'Corriger ce dossier';

  @override
  String get recentOverridesHeader => 'Corrections récentes';

  @override
  String get noOverridesRecorded => 'Aucune correction enregistrée.';

  @override
  String overrideAnimalDialogTitle(String tagNumber) {
    return 'Corriger l\'animal #$tagNumber';
  }

  @override
  String get reasonForOverrideLabel => 'Raison de la correction *';

  @override
  String get reasonForOverrideHint =>
      'Expliquez pourquoi ce dossier est modifié';

  @override
  String get reasonRequiredValidation =>
      'Une raison est requise pour les corrections admin';

  @override
  String get saveOverrideButton => 'Enregistrer la correction';

  @override
  String get overrideSaved => 'Correction enregistrée dans la piste d\'audit.';

  @override
  String get userManagementTitle => 'Gestion des utilisateurs';

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get resetPasswordMenuItem => 'Réinitialiser le mot de passe';

  @override
  String get passwordResetEmailSent => 'E-mail de réinitialisation envoyé.';

  @override
  String roleUpdatedTo(String role) {
    return 'Rôle mis à jour : $role.';
  }

  @override
  String get breedManagementTitle => 'Gestion des races';

  @override
  String get addBreedSectionTitle => 'Ajouter une race';

  @override
  String get enterBreedName => 'Entrez le nom de la race';

  @override
  String get noBreedsAdded => 'Aucune race ajoutée.';

  @override
  String get removeBreedTooltip => 'Supprimer la race';

  @override
  String get aiRecommendFab => 'Recommandation IA';

  @override
  String get aiBreedRecommendationTitle => 'Recommandation de race IA';

  @override
  String get climateLabel => 'Climat';

  @override
  String get purposeLabel => 'Objectif';

  @override
  String get additionalPreferencesLabel =>
      'Préférences supplémentaires (optionnel)';

  @override
  String get additionalPreferencesHint =>
      'ex. robuste, faible entretien, bonnes mères';

  @override
  String get consultingAiSpecialist => 'Consultation du spécialiste IA...';

  @override
  String get getRecommendationsButton => 'Obtenir des recommandations';

  @override
  String get askAgainButton => 'Redemander';

  @override
  String get climateArid => 'Aride';

  @override
  String get climateTemperate => 'Tempéré';

  @override
  String get climateTropical => 'Tropical';

  @override
  String get climateCold => 'Froid';

  @override
  String get climateSemiArid => 'Semi-aride';

  @override
  String get purposeMeat => 'Viande';

  @override
  String get purposeMilk => 'Lait';

  @override
  String get purposeWool => 'Laine';

  @override
  String get purposeMixed => 'Mixte';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get settingsSectionTitle => 'Paramètres';

  @override
  String get enableNotificationsTitle => 'Activer les notifications';

  @override
  String get enableNotificationsSubtitle => 'Recevoir des rappels et alertes';

  @override
  String get dailySummaryTitle => 'Résumé quotidien';

  @override
  String get dailySummarySubtitle => 'Obtenir un aperçu quotidien du troupeau';

  @override
  String get scheduleReminderSectionTitle => 'Planifier un rappel';

  @override
  String get notificationTitleLabel => 'Titre';

  @override
  String get notificationTitleValidation => 'Entrez un titre';

  @override
  String get notificationMessageLabel => 'Message';

  @override
  String get notificationMessageValidation => 'Entrez un message';

  @override
  String get pickTimeLabel => 'Choisir l\'heure';

  @override
  String get scheduleNotificationButton => 'Planifier la notification';

  @override
  String get scheduledSectionTitle => 'Planifié';

  @override
  String get noScheduledNotifications => 'Aucune notification planifiée.';

  @override
  String get cancelNotificationTooltip => 'Annuler';

  @override
  String get pleasePickTime => 'Veuillez choisir une heure.';

  @override
  String get notificationScheduled => 'Notification planifiée.';

  @override
  String get archivedFarmsTitle => 'Fermes archivées';

  @override
  String get noArchivedFarms => 'Aucune ferme archivée';

  @override
  String get farmsYouArchiveWillAppear =>
      'Les fermes archivées apparaîtront ici.';

  @override
  String get restoreFarmTooltip => 'Restaurer la ferme';

  @override
  String get deletePermanentlyTooltip => 'Supprimer définitivement';

  @override
  String get deleteFarmPermanentlyTitle => 'Suppression définitive';

  @override
  String deleteFarmPermanentlyContent(String farmName) {
    return 'Supprimer \"$farmName\" et tous ses animaux et journaux ? Cette action est irréversible.';
  }

  @override
  String farmRestored(String farmName) {
    return '$farmName restaurée.';
  }

  @override
  String farmPermanentlyDeleted(String farmName) {
    return '$farmName supprimée définitivement.';
  }

  @override
  String errorDeletingFarm(String error) {
    return 'Erreur lors de la suppression : $error';
  }

  @override
  String get partnersTitle => 'Partenaires';

  @override
  String get noPartnersYet => 'Aucun partenaire pour l\'instant';

  @override
  String get addPartnerToShare =>
      'Ajoutez un partenaire pour partager l\'accès à cette ferme.';

  @override
  String get editPartnerDialogTitle => 'Modifier le partenaire';

  @override
  String get partnerUpdated => 'Partenaire mis à jour.';

  @override
  String get removePartnerTitle => 'Retirer le partenaire';

  @override
  String removePartnerContent(String partnerName) {
    return 'Retirer $partnerName de cette ferme ?';
  }

  @override
  String get partnerRemoved => 'Partenaire retiré.';

  @override
  String roleChangedTo(String role) {
    return 'Rôle changé en $role.';
  }

  @override
  String get addPartnerFabLabel => 'Ajouter un partenaire';

  @override
  String get addPartnerHeader => 'Ajouter un partenaire';

  @override
  String get createNewPartnerSubtitle => 'Créer un nouveau compte partenaire';

  @override
  String get createPartnerButton => 'Créer le partenaire';

  @override
  String get partnerCreatedSuccessfully => 'Partenaire créé avec succès';

  @override
  String get aiHealthAssistantTitle => 'Assistant santé IA';

  @override
  String get askAboutHealthHint =>
      'Posez une question sur la santé de cet animal...';

  @override
  String get askMeAnythingEmptyState =>
      'Posez-moi n\'importe quelle question sur la santé de cet animal';

  @override
  String get suggestedQuestionIllness => 'Signes de maladie ?';

  @override
  String get suggestedQuestionVaccination => 'Calendrier de vaccination ?';

  @override
  String get suggestedQuestionPregnancy => 'Conseils pour la gestation ?';

  @override
  String get thinkingLabel => 'Réflexion en cours...';

  @override
  String get aiErrorResponse =>
      'Désolé, je n\'ai pas pu obtenir de réponse. Veuillez réessayer.';

  @override
  String get syncingChanges => 'Synchronisation avec le cloud';

  @override
  String get allChangesSynced => 'Toutes les modifications synchronisées';

  @override
  String get offlineBannerText =>
      'Vous êtes hors ligne. Les modifications seront synchronisées en ligne.';

  @override
  String get offlineTooltip =>
      'Hors ligne. Les modifications seront synchronisées en ligne.';

  @override
  String get verifyYourEmailTitle => 'Vérifiez votre e-mail';

  @override
  String get verifyEmailBody =>
      'Nous avons envoyé un lien de vérification à votre adresse e-mail. Veuillez vérifier votre boîte de réception avant de continuer.';

  @override
  String get verificationEmailSent => 'E-mail de vérification envoyé.';

  @override
  String failedToSend(String error) {
    return 'Échec de l\'envoi : $error';
  }

  @override
  String get resendVerificationEmail => 'Renvoyer l\'e-mail de vérification';

  @override
  String get signOutButton => 'Se déconnecter';

  @override
  String get yourProfile => 'Votre profil';

  @override
  String get changePasswordSection => 'Changer le mot de passe';

  @override
  String get newPasswordLabel =>
      'Nouveau mot de passe (laisser vide pour conserver)';

  @override
  String get minSixChars => '6 caractères minimum';

  @override
  String get updateProfileButton => 'Mettre à jour le profil';

  @override
  String get profileUpdated =>
      'Profil mis à jour ! Vérifiez votre e-mail pour confirmer le changement d\'adresse.';

  @override
  String avatarUploadFailed(String error) {
    return 'Échec du téléchargement de l\'avatar : $error';
  }

  @override
  String get languageLabel => 'Language / Langue / لغة';

  @override
  String get selectLanguage => 'Choisir la langue';
}
