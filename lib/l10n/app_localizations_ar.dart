import 'app_localizations.dart';

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get welcomeBack => 'مرحبًا بعودتك!';

  @override
  String get signInToContinue => 'سجّل الدخول للمتابعة';

  @override
  String get usernameHint => 'اسم المستخدم، البريد الإلكتروني، رقم الهاتف';

  @override
  String get passwordHint => 'كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get createAccount => 'إنشاء حساب جديد';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get app_name => 'مِقَات';

  @override
  String get hello => 'مرحبًا';

  @override
  String get welcome => 'مرحبًا بك في تطبيقنا';

  @override
  String get delegation_page_title => 'صفحة الوفد';

  @override
  String get location_services_disabled => 'خدمات الموقع معطلة. يرجى تفعيلها.';

  @override
  String get location_permissions_denied => 'تم رفض أذونات الموقع.';

  @override
  String get location_permissions_permanently_denied => 'تم رفض أذونات الموقع بشكل دائم.';

  @override
  String get you_are_straying => '⚠️ أنت تبتعد';

  @override
  String straying_message(Object firstName, Object lastName) {
    return 'مرحبًا $firstName $lastName، أنت بعيد جدًا عن مجموعتك. يرجى العودة.';
  }

  @override
  String get ok => 'حسنًا';

  @override
  String get straying_member_title => '⚠️ عضو يبتعد';

  @override
  String straying_member_message(Object fullName) {
    return '$fullName يبتعد عن المجموعة. يرجى تحديد موقعه.';
  }

  @override
  String get straying_detection_activated => 'تم تفعيل اكتشاف الابتعاد. سنبدأ الآن في مراقبة موقع وفدك.';

  @override
  String get straying_detection_deactivated => 'تم إيقاف اكتشاف الابتعاد. تم إيقاف المراقبة.';

  @override
  String get detection_started => 'تم بدء الاكتشاف';

  @override
  String get detection_stopped => 'تم إيقاف الاكتشاف';

  @override
  String get done => 'تم';

  @override
  String too_far_from_group(String firstName, String lastName) {
    return 'مرحبًا $firstName $lastName، أنت بعيد جدًا عن مجموعتك. يرجى العودة.';
  }

  @override
  String get scan_qrcode => 'مسح رمز الاستجابة السريعة';

  @override
  String get or => 'أو';

  @override
  String get upload_from_gallery => 'تحميل من المعرض';

  @override
  String get target_location => 'الموقع المستهدف';

  @override
  String get delegation_members => 'أعضاء الوفد';

  @override
  String leader_name(Object leaderName) {
    return 'القائد $leaderName';
  }

  @override
  String get no_members_yet => 'لا يوجد أعضاء بعد.';

  @override
  String get unnamed_member => 'عضو بدون اسم';

  @override
  String get scan_qr_code => 'مسح رمز الاستجابة السريعة';

  @override
  String get user_Selected => 'المستخدم المحدد';

  @override
  String get makkah => 'مكة';

  @override
  String get your_location => 'موقعك';

  @override
  String get learn_more => 'اعرف المزيد >>';

  @override
  String get approach_notif => 'أنت على بعد 5 دقائق من الميقات. استعد للدخول في الإحرام.';

  @override
  String get approach_notif_title => 'الاقتراب من الميقات';

  @override
  String get inside_notif_title => 'داخل الميقات';

  @override
  String get inside_notif => 'أنت داخل الميقات.';

  @override
  String get ihram_notif => 'أنت داخل الميقات. هل ترغب في بدء الإحرام؟';

  @override
  String get yes => 'نعم';

  @override
  String get later => 'لاحقًا';

  @override
  String get wait => 'انتظر الميقات التالي';

  @override
  String get back_inside_title => 'العودة داخل الميقات';

  @override
  String get back_inside => 'أنت داخل الميقات مرة أخرى. يمكنك بدء الإحرام الآن.';

  @override
  String get exiting_title => 'الخروج من الميقات';

  @override
  String get exiting => 'أنت تخرج من الميقات.';

  @override
  String get warning_title => 'تحذير الإحرام';

  @override
  String get warning => 'لقد خرجت من الميقات دون بدء الإحرام. هذا غير مسموح. يجب عليك العودة الآن.';

  @override
  String get menu => 'القائمة';

  @override
  String get search => 'بحث';

  @override
  String get home => 'الرئيسية';

  @override
  String get premium => 'مميز';

  @override
  String get profile => 'الحساب';

  @override
  String get menuPageTitle => 'القائمة';

  @override
  String get searchPageTitle => 'بحث';

  @override
  String get homePageTitle => 'الرئيسية';

  @override
  String get premiumPageTitle => 'مميز';

  @override
  String get profilePageTitle => 'الحساب';

  @override
  String get preference => 'التفضيلات';

  @override
  String get roundedButtonDefault => 'انقر';

  @override
  String get appBarTitleDefault => 'العنوان';

  @override
  String get appBarTitleSub => 'العنوان الفرعي';

  @override
  String get appBarTitlePremium => 'مميز';

  @override
  String get sign_up => 'إنشاء حساب';

  @override
  String get english => 'الإنجليزية';

  @override
  String get continue_btn => 'متابعة';

  @override
  String get i_agree => 'أوافق على  ';

  @override
  String get terms => 'الشروط والأحكام';

  @override
  String get have_account => 'هل لديك حساب بالفعل؟';

  @override
  String get fname => 'الاسم الأول';

  @override
  String get lname => 'اسم العائلة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get pass => 'كلمة المرور';

  @override
  String get phone => 'سنة الميلاد';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get must_agree => 'يجب أن توافق على الشروط والأحكام.';

  @override
  String get fill_fields => 'يرجى ملء جميع الحقول.';

  @override
  String get read_carfully => 'يرجى القراءة بعناية';

  @override
  String get terms_text => 'مرحبًا بك في شروط وأحكام تطبيقنا.\n\nباستخدام هذا التطبيق، فإنك توافق على الشروط التالية:\n\n- أنت تقر بأن المعلومات المقدمة هي لأغراض عامة.\n- نحن غير مسؤولين عن أي أضرار ناتجة عن الاستخدام.\n- يرجى التأكد من استخدام التطبيق بمسؤولية واحترام سياسات الخصوصية.\n\nشكرًا لك على تخصيص الوقت لقراءة هذا. إذا كانت لديك أسئلة، يرجى الاتصال بالدعم.\n\nاستخدام سعيد!';

  @override
  String get agree => 'أوافق';

  @override
  String get ihram_def => 'الإحرام هو حالة مقدسة يدخلها المسلمون لأداء الحج أو العمرة.';

  @override
  String get tawaf_def => 'الطواف هو الدوران حول الكعبة سبع مرات.';

  @override
  String get saaee_def => 'السعي هو المشي بين الصفا والمروة سبع مرات.';

  @override
  String get detect_nothing => 'لم نكتشف أي شيء.';

  @override
  String get sorry => 'عذرًا، لست متأكدًا من ذلك.';

  @override
  String get ask_something => 'قريبًا: اسأل شيئًا مثل \'ما هو الإحرام؟\'، \'محظورات الإحرام\'، وسنجيب عليك.. :)';

  @override
  String get scan => 'مسح رمز الاستجابة السريعة';

  @override
  String get pick_gallery => 'اختيار من المعرض';

  @override
  String get members_must_scan => 'يجب على جميع الأعضاء مسح هذا!';

  @override
  String get new_members => 'أعضاء جدد:';

  @override
  String get no_members => 'لا يوجد أعضاء بعد';

  @override
  String get edit_info => 'انقر لتعديل معلومات الملف الشخصي';

  @override
  String get enter_name => 'أدخل اسمك الكامل';

  @override
  String get hajj => 'الحج';

  @override
  String get umrah => 'العمرة';

  @override
  String get individual => 'فردي';

  @override
  String get delegation => 'البعثة';

  @override
  String get member => 'عضو';

  @override
  String get leader => 'قائد';

  @override
  String get language => 'اللغة';

  @override
  String get madhhab => 'المذهب';

  @override
  String get country => 'البلد';

  @override
  String get transportation => 'وسيلة النقل';

  @override
  String get saved => 'تم حفظ الإعدادات بنجاح!';

  @override
  String get not_set => 'غير محدد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get take_pic => 'التقاط صورة';

  @override
  String get subscribe => 'اشترك الآن';

  @override
  String get premium_sub => 'اشتراك مميز';

  @override
  String get hotel_text => 'خصومات تصل إلى 75% على الفنادق الفاخرة';

  @override
  String get restaurant_text => 'وجبات لذيذة وبأسعار معقولة';

  @override
  String get shops_text => 'تسوق أرخص (خصم 85%)';

  @override
  String get support_text => 'دعم أولوية وتوصيات';

  @override
  String get start_payement => 'المتابعة إلى الدفع';

  @override
  String get payement_info => 'معلومات الدفع';

  @override
  String get card_nbr_title => 'أدخل رقم بطاقة صالح مكون من 16 رقمًا';

  @override
  String get card_nbr => 'رقم البطاقة';

  @override
  String get card_hint => '1234 5678 9012 3456';

  @override
  String get expery_title => 'استخدم MM/YY';

  @override
  String get expery => 'تاريخ الانتهاء';

  @override
  String get expity_hint => 'MM/YY';

  @override
  String get enter_ccv => 'أدخل رمز CVV صالح';

  @override
  String get ccv => 'رمز CVV';

  @override
  String get ccv_hint => '123';

  @override
  String get payement_method => 'طريقة الدفع';

  @override
  String get edhahabia => 'الذهبية';

  @override
  String get mastercard => 'ماستركارد';

  @override
  String get visa => 'فيزا';

  @override
  String get pay => 'ادفع الآن';

  @override
  String get payement_successful => 'تم الدفع بنجاح!';

  @override
  String get select_madhhab => 'اختر المذهب';

  @override
  String get select_country => 'اختر البلد';

  @override
  String get select_transportation => 'اختر وسيلة النقل';

  @override
  String get next => 'التالي';

  @override
  String get delete_alarms => 'حذف التنبيهات';

  @override
  String get no_time_set => 'لم يتم تعيين وقت';

  @override
  String get no_med_name => 'لا يوجد اسم للدواء';

  @override
  String get delete_selected => 'حذف المحدد';

  @override
  String get medicine => 'الدواء';

  @override
  String get repeat => 'تكرار';

  @override
  String get importance => 'الأهمية';

  @override
  String get dosage => 'الجرعة';

  @override
  String get when => 'متى تأخذ';

  @override
  String get purpose => 'الغرض';

  @override
  String get notes => 'ملاحظات';

  @override
  String get doctor => 'وصفه الطبيب';

  @override
  String get other_times => 'أوقات أخرى';

  @override
  String get custom => 'مخصص';

  @override
  String get once => 'مرة واحدة';

  @override
  String get dosage_hint => 'الجرعة (مثال: 1 قرص، 5 مل)';

  @override
  String get when_hint => 'متى تأخذ؟';

  @override
  String get purpose_hint => 'الغرض (مثال: لضغط الدم)';

  @override
  String get notes_hint => 'ملاحظات (مثال: احملها في حقيبة باردة)';

  @override
  String get doctor_hint => 'الواصف (اسم الطبيب أو الاتصال)';

  @override
  String get times_per_day => 'مرات في اليوم';

  @override
  String get btn_advanced => 'متقدم >';

  @override
  String get med_name => 'اسم الدواء';

  @override
  String get face_fingerprint => 'استخدم الوجه أو البصمة لتسجيل الدخول';

  @override
  String get authenticated => 'تم التحقق بنجاح!';

  @override
  String get welcome_back => 'مرحبًا بعودتك!';

  @override
  String get signin_continue => 'سجل الدخول للمتابعة';

  @override
  String get login_methods => 'اسم المستخدم، البريد الإلكتروني، رقم الجوال';

  @override
  String get forgot_password => 'هل نسيت كلمة المرور؟';

  @override
  String get create_account => 'إنشاء حساب جديد';

  @override
  String get group_member => 'عضو في المجموعة';

  @override
  String get group_leader => 'قائد المجموعة';

  @override
  String get user_straying => '⚠️ أنت تبتعد';

  @override
  String get member_straying => '⚠️ عضو يبتعد';

  @override
  String get straying_service_on => 'تم تفعيل خدمة اكتشاف الابتعاد. سنبدأ الآن في مراقبة موقع وفدك.';

  @override
  String get straying_service_off => 'تم إيقاف خدمة اكتشاف الابتعاد. تم إيقاف المراقبة.';

  @override
  String get detection_on => 'تم بدء الاكتشاف';

  @override
  String get detection_off => 'تم إيقاف الاكتشاف';

  @override
  String get you_straying => 'أنت تبتعد كثيرًا عن مجموعتك. يرجى العودة.';

  @override
  String get premium_hotel_title => 'فنادق فاخرة أرخص بنسبة 60٪ إلى 75٪';

  @override
  String get premium_food_title => 'وجبات شهية أرخص بنسبة 50٪ إلى 70٪';

  @override
  String get premium_shop_title => 'متاجر أرخص بنسبة 85٪ وأسعار بين 10-20 ريال';

  @override
  String get menu_delegation => 'البعثة';

  @override
  String get menu_ihram => 'الإحرام';

  @override
  String get menu_hajj => 'الحج';

  @override
  String get menu_umrah => 'العمرة';

  @override
  String get menu_lost => 'ضائع';

  @override
  String get menu_medicine => 'دواء';

  @override
  String get language_english => 'الإنجليزية';

  @override
  String get language_arabic => 'العربية';

  @override
  String get goal_hajj => 'الحج';

  @override
  String get goal_umrah => 'العمرة';

  @override
  String get madhhab_shafii => 'شافعي';

  @override
  String get madhhab_hanafi => 'حنفي';

  @override
  String get madhhab_hanbali => 'حنبلي';

  @override
  String get madhhab_maliki => 'مالكي';

  @override
  String get country_saudi_arabia => 'المملكة العربية السعودية';

  @override
  String get country_egypt => 'مصر';

  @override
  String get country_pakistan => 'باكستان';

  @override
  String get country_malaysia => 'ماليزيا';

  @override
  String get country_turkey => 'تركيا';

  @override
  String get transport_air => 'جواً';

  @override
  String get transport_sea => 'بحراً';

  @override
  String get transport_vehicle => 'بالمركبة';

  @override
  String get transport_foot => 'مشياً على الأقدام';

  @override
  String get saying_1_description => '❌ غير معتمد من المذهب المالكي\n❌ غير معتمد من المذهب الحنبلي\n❌ غير معتمد من المذهب الحنفي\n❌ غير معتمد من المذهب الشافعي';

  @override
  String get saying_2_description => '❌ غير معتمد من المذهب المالكي\n❌ غير معتمد من المذهب الحنبلي\n❌ غير معتمد من المذهب الحنفي\n❌ غير معتمد من المذهب الشافعي';

  @override
  String get saying_3_description => '✅ معتمد من المذهب المالكي\n✅ معتمد من المذهب الحنبلي\n✅ معتمد من المذهب الحنفي\n✅ معتمد من المذهب الشافعي';

  @override
  String get saying_4_description => 'الوصف للقولة الرابعة';

  @override
  String get saying_5_description => '❌ غير معتمد من المذهب المالكي\n✅ معتمد من المذهب الحنبلي\n❌ غير معتمد من المذهب الحنفي\n❌ غير معتمد من المذهب الشافعي';

  @override
  String get ihram => 'إحرام';

  @override
  String get country_algeria => 'الجزائر';

  @override
  String get miqat_dhul_Hulaifa => 'ذو الحليفة';

  @override
  String get miqat_juhfa => 'الجحفة';

  @override
  String get miqat_yalmlm => 'يلملم';

  @override
  String get miqat_dhat_irq => 'ذات عرق';

  @override
  String get miqat_qarn_manazil => 'قرن المنازل';

  @override
  String get hajj_step_1_title => 'الخطوة 1: الإحرام';

  @override
  String get hajj_step_1_description => 'انوي وادخل في الإحرام من الميقات مع التلبية.';

  @override
  String get hajj_step_2_title => 'الخطوة 2: طواف القدوم';

  @override
  String get hajj_step_2_description => 'أدِّ طواف القدوم (الطواف حول الكعبة).';

  @override
  String get hajj_step_3_title => 'الخطوة 3: السعي بين الصفا والمروة';

  @override
  String get hajj_step_3_description => 'امشِ سبع مرات بين الصفا والمروة.';

  @override
  String get hajj_step_4_title => 'الخطوة 4: المبيت بمنى';

  @override
  String get hajj_step_4_description => 'في 8 ذو الحجة، امكث في منى وصلِّ الصلوات قصراً.';

  @override
  String get hajj_step_5_title => 'الخطوة 5: يوم عرفة';

  @override
  String get hajj_step_5_description => 'في 9 ذو الحجة، قف للدعاء والابتهال في عرفة.';

  @override
  String get hajj_step_6_title => 'الخطوة 6: مزدلفة';

  @override
  String get hajj_step_6_description => 'اجمع الحصى وبت في مزدلفة تحت السماء.';

  @override
  String get hajj_step_7_title => 'الخطوة 7: رمي الجمرات';

  @override
  String get hajj_step_7_description => 'في 10 ذو الحجة، ارجم جمرة العقبة بسبع حصيات.';

  @override
  String get hajj_step_8_title => 'الخطوة 8: الهدي';

  @override
  String get hajj_step_8_description => 'قدِّم الأضحية (أو نسِّقها عن طريق خدمة).';

  @override
  String get hajj_step_9_title => 'الخطوة 9: الحلق أو التقصير';

  @override
  String get hajj_step_9_description => 'الرجال يحلقون أو يقصرون الشعر؛ النساء يقصصن جزءًا بسيطًا.';

  @override
  String get hajj_step_10_title => 'الخطوة 10: طواف الإفاضة';

  @override
  String get hajj_step_10_description => 'الطواف الواجب بعد الأضحية والحلق.';

  @override
  String get hajj_step_11_title => 'الخطوة 11: أيام التشريق';

  @override
  String get hajj_step_11_description => 'المبيت في منى ورمي الجمرات لمدة يومين أو ثلاثة.';

  @override
  String get hajj_step_12_title => 'الخطوة 12: طواف الوداع';

  @override
  String get hajj_step_12_description => 'طواف الوداع قبل مغادرة مكة (واجب لغير المقيمين).';

  @override
  String get ihram_step_1_title => 'الخطوة 1: النية';

  @override
  String get ihram_step_1_description => 'انوي للحج أو العمرة قبل دخول الميقات.';

  @override
  String get ihram_step_2_title => 'الخطوة 2: الغُسل والنظافة';

  @override
  String get ihram_step_2_description => 'اغتسل غُسلًا كاملاً، وقص أظافرك، وارتدِ لباس الإحرام.';

  @override
  String get ihram_step_3_title => 'الخطوة 3: ارتداء الإحرام';

  @override
  String get ihram_step_3_description => 'يرتدي الرجال إزارًا ورداءً أبيضين. ترتدي النساء لباسًا إسلاميًا محتشمًا.';

  @override
  String get ihram_step_4_title => 'الخطوة 4: التلبية';

  @override
  String get ihram_step_4_description => 'ردد \"لبيك اللهم لبيك...\" بعد الدخول في الإحرام.';

  @override
  String get ihram_step_5_title => 'الخطوة 5: تجنب المحظورات';

  @override
  String get ihram_step_5_description => 'تجنب قص الشعر، والعطور، والجدال، والعلاقات الزوجية أثناء الإحرام.';

  @override
  String get umrah_step_1_title => 'الخطوة 1: الإحرام';

  @override
  String get umrah_step_1_description => 'ادخل في حالة الإحرام من الميقات مع النية والتلبية.';

  @override
  String get umrah_step_2_title => 'الخطوة 2: الطواف';

  @override
  String get umrah_step_2_description => 'قم بأداء سبعة أشواط حول الكعبة بعكس اتجاه عقارب الساعة.';

  @override
  String get umrah_step_3_title => 'الخطوة 3: الصلاة عند مقام إبراهيم';

  @override
  String get umrah_step_3_description => 'صلِّ ركعتين خلف مقام إبراهيم بعد إتمام الطواف.';

  @override
  String get umrah_step_4_title => 'الخطوة 4: السعي';

  @override
  String get umrah_step_4_description => 'امشِ سبع مرات بين الصفا والمروة، بدءًا من الصفا وانتهاءً بالمروة.';

  @override
  String get umrah_step_5_title => 'الخطوة 5: الحلق أو التقصير';

  @override
  String get umrah_step_5_description => 'الرجال يحلقون أو يقصرون الشعر؛ النساء يقصصن جزءًا بسيطًا من شعرهن.';

  @override
  String get umrah_step_6_title => 'الخطوة 6: التحلل من الإحرام';

  @override
  String get umrah_step_6_description => 'بعد قص الشعر، تتحلل من الإحرام وتنتهي العمرة.';

  @override
  String get allow_allocation_access => 'السماح بالوصول إلى الموقع؟';

  @override
  String get allow_allocation_access_text => 'لتوفير إرشادات أفضل، هل ترغب في تحديد موقعك يدويًا بالنقر على الخريطة؟ أم استخدام نظام تحديد المواقع GPS؟';

  @override
  String get auto_detect => 'الكشف التلقائي';

  @override
  String get select_manually => 'التحديد يدويًا';

  @override
  String saying_number(int number) {
    return 'القول رقم $number';
  }

  @override
  String member_full_name_warning(String firstName, String lastName) {
    return 'مرحبًا $firstName $lastName، أنت بعيد جدًا عن مجموعتك. يرجى العودة.';
  }

  @override
  String leader_warning(String leaderName) {
    return 'القائد $leaderName';
  }

  @override
  String polygon_annulus_id(String name) {
    return 'polygon_${name}_annulus';
  }

  @override
  String get lost_1 => 'This will help us identify lost people if they\'re registered in our system. Please take a clear picture of their face';

  @override
  String get lost_2 => 'This process will take a moment. Please wait..';

  @override
  String get lost_3 => 'No image picked. Please try again';

  @override
  String get lost_4 => 'No face detected in the photo. Please try again';

  @override
  String lost_5(String lastName, String firstName) {
    return 'The user in the picture you took belongs to you. $lastName $firstName';
  }

  @override
  String lost_6(String lastName, String firstName) {
    return 'This user is the leader of his delegation. He is $lastName $firstName';
  }

  @override
  String lost_7(String lastName, String firstName) {
    return 'User found! $lastName $firstName. We\'ll help you get to his delegation, thank you for your help.';
  }

  @override
  String get lost_8 => 'User does not belong to any delegation. Please try again in better lighting or reach out to local authorities.';

  @override
  String get lost_9 => 'User not registered in our system. Please try again in better lighting or reach out to local authorities.';

  @override
  String get face_verification => 'Face Verification';

  @override
  String get take_pic_verify => 'Take Photo and Verify';

  @override
  String get find_delegation => 'Find his delegation';
}
