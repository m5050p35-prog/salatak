import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];

  bool get isArabic => locale.languageCode == 'ar';

  String get appName => isArabic ? 'صلاتك' : 'Salatak';
  String get appSubtitle =>
      isArabic ? 'تطبيق متابعة قضاء الصلاة' : 'Prayer Qada Tracker';

  // Login / Signup
  String get login => isArabic ? 'دخول' : 'Login';
  String get signup => isArabic ? 'إنشاء حساب' : 'Sign Up';
  String get signupTitle => isArabic ? 'إنشاء حساب جديد' : 'Create Account';
  String get emailLabel => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get emailHint => 'example@gmail.com';
  String get emailGmailOnly =>
      isArabic ? 'يجب أن يكون البريد من Gmail' : 'Email must be Gmail';
  String get emailInvalid =>
      isArabic ? 'صيغة البريد غير صحيحة' : 'Invalid email';
  String get emailRequired =>
      isArabic ? 'الرجاء إدخال البريد' : 'Please enter email';
  String get nameLabel => isArabic ? 'الاسم' : 'Name';
  String get nameHint => isArabic ? 'مثال: أحمد' : 'e.g. Ahmed';
  String get nameRequired =>
      isArabic ? 'الرجاء إدخال الاسم' : 'Please enter your name';
  String get nameShort => isArabic ? 'الاسم قصير جداً' : 'Name too short';
  String get noAccountQuestion =>
      isArabic ? 'ليس لديك حساب؟' : "Don't have an account?";
  String get haveAccountQuestion =>
      isArabic ? 'لديك حساب؟' : 'Have an account?';
  String get accountNotFound => isArabic
      ? 'الحساب غير موجود. هل تريد إنشاء حساب جديد؟'
      : 'Account not found. Create a new one?';
  String get accountExists => isArabic
      ? 'الحساب موجود بالفعل، يمكنك تسجيل الدخول'
      : 'Account already exists. Please login.';
  String get goToSignup =>
      isArabic ? 'إنشاء حساب جديد' : 'Create Account';
  String get goToLogin => isArabic ? 'تسجيل الدخول' : 'Login';
  String get noPasswordNote => isArabic
      ? 'لا حاجة لكلمة مرور، فقط بريد Gmail.'
      : 'No password needed, just Gmail.';
  String get or => isArabic ? 'أو' : 'or';
  String get errorOccurred =>
      isArabic ? 'حدث خطأ، حاول مرة أخرى' : 'Error, please try again';
  String get checkingAccount =>
      isArabic ? 'جارٍ التحقق...' : 'Checking...';

  // Duration
  String get chooseDuration => isArabic ? 'اختيار المدة' : 'Choose Duration';
  String get welcome => isArabic ? 'مرحباً' : 'Welcome';
  String get chooseDurationSubtitle => isArabic
      ? 'اختر المدة التي تريد بها قضاء الصلاة'
      : 'Choose the period to make up prayers';
  String get oneDay => isArabic ? 'يوم واحد' : 'One Day';
  String get oneWeek => isArabic ? 'أسبوع' : 'One Week';
  String get oneMonth => isArabic ? 'شهر' : 'One Month';
  String get oneYear => isArabic ? 'سنة' : 'One Year';
  String get custom => isArabic ? 'مخصص' : 'Custom';
  String get start => isArabic ? 'ابدأ' : 'Start';
  String get daysCount => isArabic ? 'يوم' : 'days';
  String get customDays => isArabic ? 'عدد الأيام المخصص' : 'Custom days count';
  String get example15 => isArabic ? 'مثال: 15' : 'Example: 15';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';

  // Tracker
  String get prayerTable => isArabic ? 'جدول قضاء الصلاة' : 'Prayer Qada Table';
  String get fajr => isArabic ? 'الفجر' : 'Fajr';
  String get dhuhr => isArabic ? 'الظهر' : 'Dhuhr';
  String get asr => isArabic ? 'العصر' : 'Asr';
  String get maghrib => isArabic ? 'المغرب' : 'Maghrib';
  String get isha => isArabic ? 'العشاء' : 'Isha';
  String get addDay => isArabic ? 'إضافة يوم' : 'Add Day';
  String get totalDays => isArabic ? 'الأيام' : 'Days';
  String get completed => isArabic ? 'قضيت' : 'Done';
  String get remaining => isArabic ? 'المتبقي' : 'Remaining';
  String get noDaysYet => isArabic
      ? 'لا توجد أيام بعد.\nاضغط "إضافة يوم" للبدء.'
      : 'No days yet.\nTap "Add Day" to start.';
  String get deleteDay => isArabic ? 'حذف اليوم؟' : 'Delete day?';
  String get deleteDayNote => isArabic
      ? 'سيتم حذف هذا اليوم نهائياً.'
      : 'This day will be permanently deleted.';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get resetTable => isArabic ? 'إعادة تعيين الجدول؟' : 'Reset table?';
  String get resetTableNote => isArabic
      ? 'سيتم حذف جميع الأيام والبدء من جديد.'
      : 'All days will be deleted and you start fresh.';
  String get reset => isArabic ? 'إعادة تعيين' : 'Reset';
  String get completeDay => isArabic ? 'اكتمل اليوم' : 'Complete day';
  String get dayComplete => isArabic ? 'اكتمل' : 'Complete';
  String get progress => isArabic ? 'التقدم' : 'Progress';

  // Settings / Drawer
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get darkMode => isArabic ? 'الوضع الليلي' : 'Dark Mode';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get english => isArabic ? 'الإنجليزية' : 'English';
  String get logout => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get about => isArabic ? 'حول التطبيق' : 'About';
  String get version => isArabic ? 'الإصدار' : 'Version';
  String get aboutText => isArabic
      ? 'تطبيق صلاتك يساعدك على متابعة قضاء الصلوات الفائتة.'
      : 'Salatak helps you track missed prayers.';
  String get profile => isArabic ? 'الملف الشخصي' : 'Profile';
  String get userName => isArabic ? 'الاسم' : 'Name';
  String get userEmail => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get stats => isArabic ? 'الإحصائيات' : 'Statistics';
  String get currentStreak => isArabic ? 'الأيام المكتملة' : 'Complete days';

  // Notifications
  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';
  String get dailyReminder => isArabic ? 'تذكير يومي' : 'Daily reminder';
  String get reminderTime => isArabic ? 'وقت التذكير' : 'Reminder time';
  String get reminderEnabled =>
      isArabic ? 'تفعيل التذكير اليومي' : 'Enable daily reminder';
  String get testNotification =>
      isArabic ? 'إشعار تجريبي' : 'Test notification';
  String get notificationSent =>
      isArabic ? 'تم إرسال إشعار تجريبي' : 'Test notification sent';
  String get notificationPermissionDenied => isArabic
      ? 'الرجاء السماح بالإشعارات من الإعدادات'
      : 'Please allow notifications in settings';
  String get chooseReminderTime =>
      isArabic ? 'اختر وقت التذكير' : 'Choose reminder time';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
