// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'FarmSheep';

  @override
  String get smartFarmManagement => 'إدارة ذكية للفيرمة';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get saveButton => 'احفظ';

  @override
  String get deleteButton => 'احذف';

  @override
  String get doneButton => 'خلاص';

  @override
  String get addButton => 'زيد';

  @override
  String get closeButton => 'اغلق';

  @override
  String get removeButton => 'شيل';

  @override
  String get editMenuItem => 'عدّل';

  @override
  String get refreshTooltip => 'حدّث';

  @override
  String get noFarmSelected => 'ما كاش فيرمة مختارة.';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get emailLabel => 'إيميل';

  @override
  String get passwordLabel => 'كلمة السر';

  @override
  String get notesLabel => 'ملاحظات';

  @override
  String get typeLabel => 'النوع';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get priceLabel => 'الثمن';

  @override
  String get roleLabel => 'الدور';

  @override
  String get sourceLabel => 'المصدر';

  @override
  String get requiredValidation => 'مطلوب';

  @override
  String get makeAdminMenuItem => 'اعمله أدمين';

  @override
  String get makePartnerMenuItem => 'اعمله شريك';

  @override
  String errorWithMessage(String message) {
    return 'غلط: $message';
  }

  @override
  String get welcomeBack => 'مرحبا بيك';

  @override
  String get signInToFarmAccount => 'دخل لحساب الفيرمة متاعك';

  @override
  String get forgotPassword => 'نسيت كلمة السر؟';

  @override
  String get signInButton => 'دخل';

  @override
  String get dontHaveAccount => 'ما عندكش حساب؟';

  @override
  String get registerButton => 'سجّل';

  @override
  String loginFailed(String error) {
    return 'فشل الدخول: $error';
  }

  @override
  String get enterEmailFirst => 'اكتب الإيميل متاعك فوق أولاً';

  @override
  String get passwordResetSent => 'تم إرسال إيميل تغيير كلمة السر!';

  @override
  String failed(String error) {
    return 'فشل: $error';
  }

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get joinFarmSheepToday => 'انضم لـ FarmSheep اليوم';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get enterYourName => 'اكتب اسمك';

  @override
  String get confirmPasswordLabel => 'أكد كلمة السر';

  @override
  String get confirmNewPasswordLabel => 'أكد كلمة السر الجديدة';

  @override
  String get passwordsDoNotMatch => 'كلمات السر ما تطابقوش';

  @override
  String get accountCreated => 'تم إنشاء الحساب! تحقق من إيميلك.';

  @override
  String get alreadyHaveAccount => 'عندك حساب بالفعل؟';

  @override
  String get passwordWeak => 'ضعيف';

  @override
  String get passwordMedium => 'متوسط';

  @override
  String get passwordStrong => 'قوي';

  @override
  String get notificationsTooltip => 'الإشعارات';

  @override
  String get profileTooltip => 'الملف الشخصي';

  @override
  String get welcomeNotificationTitle => 'أهلاً';

  @override
  String get welcomeNotificationBody => 'شوف الحيوانات و السجلات متاع اليوم!';

  @override
  String get tileAnimals => 'الحيوانات';

  @override
  String get tileFarmDashboard => 'لوحة القيادة';

  @override
  String get tileLogs => 'السجلات';

  @override
  String get tileBreedManagement => 'إدارة السلالات';

  @override
  String get tileAddPartner => 'زيد شريك';

  @override
  String get tileAdminLogs => 'سجلات الأدمين';

  @override
  String get tileUserManagement => 'إدارة المستخدمين';

  @override
  String get tileAdminOverride => 'تصحيح الأدمين';

  @override
  String get tileAnimalSearchExport => 'بحث و تصدير الحيوانات';

  @override
  String get tileLogSearchExport => 'بحث و تصدير السجلات';

  @override
  String get tileLogout => 'اخرج';

  @override
  String get alertsNotificationsTitle => 'تنبيهات و إشعارات';

  @override
  String get alertsNotificationsSubtitle => 'شوف و دير الإشعارات متاع الفيرمة';

  @override
  String get statAnimals => 'حيوانات';

  @override
  String get statPartners => 'شركاء';

  @override
  String get statLogs => 'سجلات';

  @override
  String get animalsScreenTitle => 'الحيوانات';

  @override
  String get exportCsvTooltip => 'صدّر CSV';

  @override
  String get addAnimalTooltip => 'زيد حيوان';

  @override
  String get searchByTagIdLabel => 'ابحث برقم البطاقة';

  @override
  String get searchByTagIdHint => 'اكتب رقم البطاقة...';

  @override
  String get allTypesHint => 'كل الأنواع';

  @override
  String get allStatusesHint => 'كل الحالات';

  @override
  String get noAnimalsFound => 'ما لقينا حيوانات';

  @override
  String get tryAdjustingFilters => 'جرب تبدّل فلاتر البحث';

  @override
  String get addFirstAnimal => 'زيد أول حيوان للبداية!';

  @override
  String get askAiTooltip => 'اسأل الذكاء الاصطناعي';

  @override
  String get exportPdfTooltip => 'صدّر PDF';

  @override
  String get deleteAnimalDialogTitle => 'احذف الحيوان';

  @override
  String get deleteAnimalDialogContent => 'واثق تحب تحذف هذا الحيوان؟';

  @override
  String pdfFailed(String error) {
    return 'فشل PDF: $error';
  }

  @override
  String get tagNumberLabel => 'رقم البطاقة';

  @override
  String get bornLabel => 'تاريخ الميلاد';

  @override
  String get ageLabel => 'العمر';

  @override
  String get tagColorLabel => 'لون البطاقة';

  @override
  String get physicalSectionHeader => 'الجسم';

  @override
  String get sexLabel => 'الجنس';

  @override
  String get weightLabel => 'الوزن';

  @override
  String get bcsLabel => 'نتيجة الحالة الجسدية';

  @override
  String get microchipLabel => 'رقاقة إلكترونية';

  @override
  String get originSectionHeader => 'الأصل';

  @override
  String get acquiredLabel => 'طريقة الاقتناء';

  @override
  String get purchaseDateLabel => 'تاريخ الشراء';

  @override
  String get lineageSectionHeader => 'النسب';

  @override
  String get sireFatherLabel => 'الأب';

  @override
  String get sireIdLabel => 'رقم الأب';

  @override
  String get damMotherLabel => 'الأم';

  @override
  String get damIdLabel => 'رقم الأم';

  @override
  String get notesSectionHeader => 'ملاحظات';

  @override
  String get pregnancyHistoryHeader => 'تاريخ الحمل';

  @override
  String get birthLogHeader => 'سجل الولادات';

  @override
  String get healthLogsHeader => 'سجلات الصحة';

  @override
  String get saleInfoHeader => 'معلومات البيع';

  @override
  String get buyerLabel => 'المشتري';

  @override
  String get aiHealthRiskAssessmentTitle => 'تقييم الذكاء الاصطناعي للصحة';

  @override
  String get aiRiskAssessmentButton => 'تقييم بالذكاء الاصطناعي';

  @override
  String get analyzingLabel => 'جاري التحليل...';

  @override
  String get stillWorkingLabel => 'ما زلنا نعمل...';

  @override
  String get addAnimalScreenTitle => 'زيد حيوان';

  @override
  String get editAnimalScreenTitle => 'عدّل الحيوان';

  @override
  String get identificationSection => 'التعريف';

  @override
  String get tagNumberFieldLabel => 'رقم البطاقة *';

  @override
  String get tagNumberFieldHint => 'اكتب رقم بطاقة الأذن الفريد';

  @override
  String get tagColorTileTitle => 'لون البطاقة';

  @override
  String get pickTagColorDialogTitle => 'اختار لون البطاقة';

  @override
  String get microchipRfidLabel => 'رقاقة / RFID';

  @override
  String get microchipRfidHint => 'رقم إلكتروني (اختياري)';

  @override
  String get animalDetailsSection => 'تفاصيل الحيوان';

  @override
  String get breedLabel => 'السلالة';

  @override
  String get breedHint => 'اختار السلالة';

  @override
  String get pickBirthDate => 'اختار تاريخ الميلاد *';

  @override
  String get birthDatePrefix => 'تاريخ الميلاد: ';

  @override
  String get originSection => 'الأصل';

  @override
  String get acquisitionTypeLabel => 'طريقة الاقتناء';

  @override
  String get howWasAnimalAcquired => 'كيفاش جاء هذا الحيوان؟';

  @override
  String get typeSheep => 'خروف';

  @override
  String get typeGoat => 'معزة';

  @override
  String get sexFemale => 'أنثى';

  @override
  String get sexMale => 'ذكر';

  @override
  String get sexWether => 'خصي';

  @override
  String get sexUnknown => 'غير معروف';

  @override
  String get acquisitionBornOnFarm => 'ولد في الفيرمة';

  @override
  String get acquisitionPurchased => 'مشتري';

  @override
  String get acquisitionGifted => 'هدية';

  @override
  String get purchaseSourceLabel => 'مصدر الشراء';

  @override
  String get purchaseSourceHint => 'اسم البائع / السوق';

  @override
  String get purchasePriceLabel => 'ثمن الشراء';

  @override
  String get purchasePriceHint => 'المبلغ المدفوع';

  @override
  String get purchaseDateTile => 'تاريخ الشراء';

  @override
  String get purchasedDatePrefix => 'اشتري في: ';

  @override
  String get lineageSection => 'النسب';

  @override
  String get sireTagNameLabel => 'رقم / اسم الأب';

  @override
  String get sireTagNameHint => 'الأب';

  @override
  String get sireIdHint => 'اختياري';

  @override
  String get damTagNameLabel => 'رقم / اسم الأم';

  @override
  String get damTagNameHint => 'الأم';

  @override
  String get damIdHint => 'اختياري';

  @override
  String get physicalSection => 'الجسم';

  @override
  String get currentWeightLabel => 'الوزن الحالي (كغ)';

  @override
  String get currentWeightHint => 'مثال: 45.5';

  @override
  String get bodyConditionScoreLabel => 'نتيجة الحالة الجسدية (BCS)';

  @override
  String get notesSection => 'ملاحظات';

  @override
  String get notesHint => 'ملاحظات إضافية';

  @override
  String get photosSection => 'الصور';

  @override
  String get cameraButton => 'الكاميرا';

  @override
  String get galleryButton => 'المعرض';

  @override
  String get saveAnimalButton => 'احفظ الحيوان';

  @override
  String get saveChangesButton => 'احفظ التغييرات';

  @override
  String get cropImageTitle => 'قص الصورة';

  @override
  String get birthDateRequired => 'تاريخ الميلاد مطلوب.';

  @override
  String get tagNumberMustBePositive => 'رقم البطاقة لازم يكون عدد صحيح موجب.';

  @override
  String couldNotPickImage(String error) {
    return 'ما قدرناش نختار الصورة: $error';
  }

  @override
  String errorSavingAnimal(String error) {
    return 'غلط في الحفظ: $error';
  }

  @override
  String errorUpdatingAnimal(String error) {
    return 'غلط في التعديل: $error';
  }

  @override
  String get animalSearchExportTitle => 'بحث و تصدير الحيوانات';

  @override
  String get searchByTagOrBreed => 'ابحث برقم البطاقة أو السلالة';

  @override
  String get yourFarmsTitle => 'فيرماتك';

  @override
  String get viewArchivedFarms => 'شوف الفيرمات المؤرشفة';

  @override
  String get noFarmsFound => 'ما لقيناش فيرمات';

  @override
  String get addFirstFarm => 'زيد أول فيرمة للبداية!';

  @override
  String get archiveFarmTitle => 'أرشف الفيرمة';

  @override
  String get archiveFarmConfirm =>
      'واثق تحب تأرشف هذه الفيرمة؟ تقدر ترجعها لاحقاً.';

  @override
  String get archiveButton => 'أرشف';

  @override
  String get deleteFarmTitle => 'احذف الفيرمة';

  @override
  String get deleteFarmConfirm =>
      'واثق تحب تحذف هذه الفيرمة؟ كل الحيوانات والسجلات راح تتحذف.';

  @override
  String get farmArchived => 'تم أرشفة الفيرمة.';

  @override
  String get farmDeleted => 'تم حذف الفيرمة.';

  @override
  String get addFarmFab => 'زيد فيرمة';

  @override
  String get addNewFarmDialogTitle => 'زيد فيرمة جديدة';

  @override
  String get farmNameLabel => 'اسم الفيرمة';

  @override
  String get farmNameHint => 'اكتب اسم الفيرمة';

  @override
  String get farmNameRequired => 'اكتب اسم الفيرمة من فضلك';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get addressHint => 'اكتب عنوان الفيرمة';

  @override
  String get addressRequired => 'اكتب عنوان الفيرمة من فضلك';

  @override
  String get notesOptionalLabel => 'ملاحظات (اختياري)';

  @override
  String get additionalFarmInfo => 'معلومات إضافية عن الفيرمة';

  @override
  String get farmAddedSuccessfully => 'تمت إضافة الفيرمة بنجاح!';

  @override
  String errorAddingFarm(String error) {
    return 'غلط في الإضافة: $error';
  }

  @override
  String get farmDashboardTitle => 'لوحة القيادة';

  @override
  String get farmSettingsTooltip => 'إعدادات الفيرمة';

  @override
  String get aiHerdSummaryTitle => 'ملخص الذكاء الاصطناعي للقطيع';

  @override
  String get aiHerdSummaryGenerateTap =>
      'اضغط على \"توليد\" للحصول على نظرة عامة بالذكاء الاصطناعي.';

  @override
  String get generatingLabel => 'جاري التوليد...';

  @override
  String get refreshSummaryButton => 'حدّث الملخص';

  @override
  String get generateAiSummaryButton => 'ولّد ملخص بالذكاء الاصطناعي';

  @override
  String get tileFarmActivity => 'نشاط الفيرمة';

  @override
  String get tileProfileUsers => 'الملف الشخصي / المستخدمين';

  @override
  String get farmSettingsTitle => 'إعدادات الفيرمة';

  @override
  String get notesSectionTitle => 'ملاحظات';

  @override
  String get preferredBreedsSectionTitle => 'السلالات المفضلة';

  @override
  String get preferredBreedsHint => 'الدماني، الدمشقي، مختلط...';

  @override
  String get preferredBreedsHelper => 'أسماء السلالات مفصولة بفاصلة';

  @override
  String get farmColorSectionTitle => 'لون الفيرمة';

  @override
  String get currentColorLabel => 'اللون الحالي:';

  @override
  String get pickFarmColorDialogTitle => 'اختار لون الفيرمة';

  @override
  String get tapToChange => 'اضغط للتغيير';

  @override
  String get partnerPermissionsSectionTitle => 'صلاحيات الشركاء';

  @override
  String get allowPartnersAddAnimalsTitle => 'اسمح للشركاء بإضافة حيوانات';

  @override
  String get allowPartnersAddAnimalsSubtitle =>
      'الشركاء يقدرو يزيدو حيوانات للفيرمة';

  @override
  String get allowPartnersEditLogsTitle => 'اسمح للشركاء بتعديل السجلات';

  @override
  String get allowPartnersEditLogsSubtitle =>
      'الشركاء يقدرو يزيدو و يعدلو السجلات';

  @override
  String get saveSettingsButton => 'احفظ الإعدادات';

  @override
  String get farmSettingsUpdated => 'تم تحديث إعدادات الفيرمة.';

  @override
  String get addManualLogTitle => 'زيد سجل';

  @override
  String get logDetailsSectionTitle => 'تفاصيل السجل';

  @override
  String get actionTypeLabel => 'نوع الإجراء';

  @override
  String get animalIdsLabel => 'أرقام الحيوانات (مفصولة بفاصلة)';

  @override
  String get getAiSuggestionButton => 'اقتراح بالذكاء الاصطناعي';

  @override
  String get gettingSuggestion => 'جاري الحصول على الاقتراح...';

  @override
  String get saveManualLogTooltip => 'احفظ السجل';

  @override
  String get addAnimalsFirst => 'زيد حيوانات للفيرمة أولاً.';

  @override
  String get aiSuggestionApplied => 'تم تطبيق اقتراح الذكاء الاصطناعي!';

  @override
  String aiSuggestionFailed(String error) {
    return 'فشل اقتراح الذكاء الاصطناعي: $error';
  }

  @override
  String get userNotSignedIn => 'المستخدم غير مسجل الدخول';

  @override
  String errorSaving(String error) {
    return 'غلط: $error';
  }

  @override
  String get actionFeeding => 'تغذية';

  @override
  String get actionDeworming => 'تطفيل';

  @override
  String get actionCleaning => 'تنظيف';

  @override
  String get actionVaccination => 'تطعيم';

  @override
  String get actionMedication => 'دواء';

  @override
  String get actionTreatment => 'علاج';

  @override
  String get actionHealthCheck => 'فحص صحي';

  @override
  String get actionObservation => 'مراقبة';

  @override
  String get actionOther => 'أخرى';

  @override
  String get manualLogsTitle => 'السجلات اليدوية';

  @override
  String get noLogsFound => 'ما لقيناش سجلات.';

  @override
  String get logSearchExportTitle => 'بحث و تصدير السجلات';

  @override
  String get searchByTypeOrNotes => 'ابحث بالنوع أو الملاحظات';

  @override
  String get dateRangeButton => 'نطاق التواريخ';

  @override
  String get auditTrailHeader => 'سجل التدقيق (الأدمين فقط)';

  @override
  String get farmActivityLogTitle => 'سجل نشاط الفيرمة';

  @override
  String get noActivityYet => 'ما كاش نشاط لحد الآن';

  @override
  String get farmActionsWillAppear => 'إجراءات الفيرمة تبان هنا.';

  @override
  String get activityLogsTitle => 'سجلات النشاط';

  @override
  String get accessDenied => 'الوصول ممنوع';

  @override
  String get noActivityLogsFound => 'ما لقيناش سجلات نشاط.';

  @override
  String get adminRecordOverrideTitle => 'تصحيح سجلات الأدمين';

  @override
  String get adminAccessRequired => 'صلاحية الأدمين مطلوبة';

  @override
  String get searchAnimalsByTagOrBreed =>
      'ابحث عن الحيوانات بالبطاقة أو السلالة';

  @override
  String get overrideThisRecord => 'صحّح هذا السجل';

  @override
  String get recentOverridesHeader => 'التصحيحات الأخيرة';

  @override
  String get noOverridesRecorded => 'ما كاش تصحيحات مسجلة.';

  @override
  String overrideAnimalDialogTitle(String tagNumber) {
    return 'تصحيح الحيوان #$tagNumber';
  }

  @override
  String get reasonForOverrideLabel => 'سبب التصحيح *';

  @override
  String get reasonForOverrideHint => 'اشرح علاش تحب تبدّل هذا السجل';

  @override
  String get reasonRequiredValidation => 'سبب مطلوب لتصحيحات الأدمين';

  @override
  String get saveOverrideButton => 'احفظ التصحيح';

  @override
  String get overrideSaved => 'تم حفظ التصحيح في سجل التدقيق.';

  @override
  String get userManagementTitle => 'إدارة المستخدمين';

  @override
  String get noUsersFound => 'ما لقيناش مستخدمين';

  @override
  String get resetPasswordMenuItem => 'إعادة تعيين كلمة السر';

  @override
  String get passwordResetEmailSent => 'تم إرسال إيميل إعادة تعيين كلمة السر.';

  @override
  String roleUpdatedTo(String role) {
    return 'تم تغيير الدور إلى $role.';
  }

  @override
  String get breedManagementTitle => 'إدارة السلالات';

  @override
  String get addBreedSectionTitle => 'زيد سلالة';

  @override
  String get enterBreedName => 'اكتب اسم السلالة';

  @override
  String get noBreedsAdded => 'ما كاش سلالات مضافة.';

  @override
  String get removeBreedTooltip => 'احذف السلالة';

  @override
  String get aiRecommendFab => 'توصية بالذكاء الاصطناعي';

  @override
  String get aiBreedRecommendationTitle => 'توصية السلالة بالذكاء الاصطناعي';

  @override
  String get climateLabel => 'المناخ';

  @override
  String get purposeLabel => 'الغرض';

  @override
  String get additionalPreferencesLabel => 'تفضيلات إضافية (اختياري)';

  @override
  String get additionalPreferencesHint =>
      'مثال: متحمّل، صيانة قليلة، أمهات جيدات';

  @override
  String get consultingAiSpecialist => 'جاري استشارة متخصص الذكاء الاصطناعي...';

  @override
  String get getRecommendationsButton => 'احصل على التوصيات';

  @override
  String get askAgainButton => 'اسأل مرة أخرى';

  @override
  String get climateArid => 'جاف';

  @override
  String get climateTemperate => 'معتدل';

  @override
  String get climateTropical => 'استوائي';

  @override
  String get climateCold => 'بارد';

  @override
  String get climateSemiArid => 'شبه جاف';

  @override
  String get purposeMeat => 'لحم';

  @override
  String get purposeMilk => 'حليب';

  @override
  String get purposeWool => 'صوف';

  @override
  String get purposeMixed => 'مختلط';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get settingsSectionTitle => 'الإعدادات';

  @override
  String get enableNotificationsTitle => 'تفعيل الإشعارات';

  @override
  String get enableNotificationsSubtitle => 'استقبل تذكيرات وتنبيهات';

  @override
  String get dailySummaryTitle => 'الملخص اليومي';

  @override
  String get dailySummarySubtitle => 'احصل على نظرة يومية للقطيع';

  @override
  String get scheduleReminderSectionTitle => 'جدولة تذكير';

  @override
  String get notificationTitleLabel => 'العنوان';

  @override
  String get notificationTitleValidation => 'اكتب عنوان';

  @override
  String get notificationMessageLabel => 'الرسالة';

  @override
  String get notificationMessageValidation => 'اكتب رسالة';

  @override
  String get pickTimeLabel => 'اختار الوقت';

  @override
  String get scheduleNotificationButton => 'جدول الإشعار';

  @override
  String get scheduledSectionTitle => 'المجدول';

  @override
  String get noScheduledNotifications => 'ما كاش إشعارات مجدولة.';

  @override
  String get cancelNotificationTooltip => 'إلغاء';

  @override
  String get pleasePickTime => 'اختار الوقت من فضلك.';

  @override
  String get notificationScheduled => 'تم جدولة الإشعار.';

  @override
  String get archivedFarmsTitle => 'الفيرمات المؤرشفة';

  @override
  String get noArchivedFarms => 'ما كاش فيرمات مؤرشفة';

  @override
  String get farmsYouArchiveWillAppear => 'الفيرمات اللي تأرشفها تبان هنا.';

  @override
  String get restoreFarmTooltip => 'استرجع الفيرمة';

  @override
  String get deletePermanentlyTooltip => 'احذف نهائياً';

  @override
  String get deleteFarmPermanentlyTitle => 'حذف نهائي للفيرمة';

  @override
  String deleteFarmPermanentlyContent(String farmName) {
    return 'تحذف \"$farmName\" وكل حيواناتها وسجلاتها؟ هذا ما يتراجعش.';
  }

  @override
  String farmRestored(String farmName) {
    return 'تم استرجاع $farmName.';
  }

  @override
  String farmPermanentlyDeleted(String farmName) {
    return 'تم الحذف النهائي لـ $farmName.';
  }

  @override
  String errorDeletingFarm(String error) {
    return 'غلط في الحذف: $error';
  }

  @override
  String get partnersTitle => 'الشركاء';

  @override
  String get noPartnersYet => 'ما كاش شركاء لحد الآن';

  @override
  String get addPartnerToShare => 'زيد شريك لتقاسم الوصول لهذه الفيرمة.';

  @override
  String get editPartnerDialogTitle => 'عدّل الشريك';

  @override
  String get partnerUpdated => 'تم تحديث الشريك.';

  @override
  String get removePartnerTitle => 'شيل الشريك';

  @override
  String removePartnerContent(String partnerName) {
    return 'تشيل $partnerName من هذه الفيرمة؟';
  }

  @override
  String get partnerRemoved => 'تم إزالة الشريك.';

  @override
  String roleChangedTo(String role) {
    return 'تم تغيير الدور إلى $role.';
  }

  @override
  String get addPartnerFabLabel => 'زيد شريك';

  @override
  String get addPartnerHeader => 'زيد شريك';

  @override
  String get createNewPartnerSubtitle => 'إنشاء حساب شريك جديد';

  @override
  String get createPartnerButton => 'إنشاء الشريك';

  @override
  String get partnerCreatedSuccessfully => 'تم إنشاء الشريك بنجاح';

  @override
  String get aiHealthAssistantTitle => 'مساعد الصحة بالذكاء الاصطناعي';

  @override
  String get askAboutHealthHint => 'اسأل عن صحة هذا الحيوان...';

  @override
  String get askMeAnythingEmptyState => 'اسألني أي شيء عن صحة هذا الحيوان';

  @override
  String get suggestedQuestionIllness => 'علامات المرض؟';

  @override
  String get suggestedQuestionVaccination => 'جدول التطعيم؟';

  @override
  String get suggestedQuestionPregnancy => 'نصائح رعاية الحمل؟';

  @override
  String get thinkingLabel => 'جاري التفكير...';

  @override
  String get aiErrorResponse => 'آسف، ما قدرتش نجاوب. حاول مرة أخرى.';

  @override
  String get syncingChanges => 'جاري المزامنة مع السحابة';

  @override
  String get allChangesSynced => 'كل التغييرات متزامنة';

  @override
  String get offlineBannerText =>
      'أنت غير متصل. التغييرات ستتزامن عند الاتصال.';

  @override
  String get offlineTooltip => 'غير متصل. التغييرات ستتزامن عند الاتصال.';

  @override
  String get verifyYourEmailTitle => 'تحقق من إيميلك';

  @override
  String get verifyEmailBody =>
      'بعثنالك رابط تحقق لإيميلك. تحقق من صندوق الوارد قبل المتابعة.';

  @override
  String get verificationEmailSent => 'تم إرسال إيميل التحقق.';

  @override
  String failedToSend(String error) {
    return 'فشل الإرسال: $error';
  }

  @override
  String get resendVerificationEmail => 'أعد إرسال إيميل التحقق';

  @override
  String get signOutButton => 'اخرج';

  @override
  String get yourProfile => 'ملفك الشخصي';

  @override
  String get changePasswordSection => 'تغيير كلمة السر';

  @override
  String get newPasswordLabel => 'كلمة السر الجديدة (اتركها فارغة للإبقاء)';

  @override
  String get minSixChars => '6 أحرف على الأقل';

  @override
  String get updateProfileButton => 'حدّث الملف الشخصي';

  @override
  String get profileUpdated =>
      'تم تحديث الملف الشخصي! تحقق من إيميلك لتأكيد التغيير.';

  @override
  String avatarUploadFailed(String error) {
    return 'فشل رفع الصورة: $error';
  }

  @override
  String get languageLabel => 'Language / Langue / لغة';

  @override
  String get selectLanguage => 'اختار اللغة';
}
