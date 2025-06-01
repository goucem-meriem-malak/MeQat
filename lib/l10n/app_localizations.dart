import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username, email, mobile number'**
  String get usernameHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'MeQat'**
  String get app_name;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to our app'**
  String get welcome;

  /// No description provided for @delegation_page_title.
  ///
  /// In en, this message translates to:
  /// **'Delegation Page'**
  String get delegation_page_title;

  /// No description provided for @location_services_disabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable them.'**
  String get location_services_disabled;

  /// No description provided for @location_permissions_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied.'**
  String get location_permissions_denied;

  /// No description provided for @location_permissions_permanently_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied.'**
  String get location_permissions_permanently_denied;

  /// No description provided for @you_are_straying.
  ///
  /// In en, this message translates to:
  /// **'⚠️ You\'re Straying'**
  String get you_are_straying;

  /// No description provided for @straying_message.
  ///
  /// In en, this message translates to:
  /// **'Hey {firstName} {lastName}, you’re too far from your group. Please go back.'**
  String straying_message(Object firstName, Object lastName);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get ok;

  /// No description provided for @straying_member_title.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Member Straying'**
  String get straying_member_title;

  /// No description provided for @straying_member_message.
  ///
  /// In en, this message translates to:
  /// **'{fullName} is straying from the group. Please locate them.'**
  String straying_member_message(Object fullName);

  /// No description provided for @straying_detection_activated.
  ///
  /// In en, this message translates to:
  /// **'Straying detection activated. We\'ll now start monitoring your delegation\'s location.'**
  String get straying_detection_activated;

  /// No description provided for @straying_detection_deactivated.
  ///
  /// In en, this message translates to:
  /// **'Straying detection deactivated. Monitoring stopped.'**
  String get straying_detection_deactivated;

  /// No description provided for @detection_started.
  ///
  /// In en, this message translates to:
  /// **'Detection Started'**
  String get detection_started;

  /// No description provided for @detection_stopped.
  ///
  /// In en, this message translates to:
  /// **'Detection Stopped'**
  String get detection_stopped;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Warning when a user is too far from the group
  ///
  /// In en, this message translates to:
  /// **'Hey {firstName} {lastName}, you’re too far from your group. Please go back.'**
  String too_far_from_group(String firstName, String lastName);

  /// No description provided for @scan_qrcode.
  ///
  /// In en, this message translates to:
  /// **'Scan QRCode'**
  String get scan_qrcode;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @upload_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery'**
  String get upload_from_gallery;

  /// No description provided for @target_location.
  ///
  /// In en, this message translates to:
  /// **'Target Location'**
  String get target_location;

  /// No description provided for @delegation_members.
  ///
  /// In en, this message translates to:
  /// **'Delegation members'**
  String get delegation_members;

  /// No description provided for @leader_name.
  ///
  /// In en, this message translates to:
  /// **'Leader {leaderName}'**
  String leader_name(Object leaderName);

  /// No description provided for @no_members_yet.
  ///
  /// In en, this message translates to:
  /// **'No members yet.'**
  String get no_members_yet;

  /// No description provided for @unnamed_member.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Member'**
  String get unnamed_member;

  /// No description provided for @scan_qr_code.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scan_qr_code;

  /// No description provided for @user_Selected.
  ///
  /// In en, this message translates to:
  /// **'user Selected'**
  String get user_Selected;

  /// No description provided for @makkah.
  ///
  /// In en, this message translates to:
  /// **'Makkah'**
  String get makkah;

  /// No description provided for @your_location.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get your_location;

  /// No description provided for @learn_more.
  ///
  /// In en, this message translates to:
  /// **'Learn more >>'**
  String get learn_more;

  /// No description provided for @approach_notif.
  ///
  /// In en, this message translates to:
  /// **'You are 5 minutes away from the Miqat. Get ready to enter Ihram.'**
  String get approach_notif;

  /// No description provided for @approach_notif_title.
  ///
  /// In en, this message translates to:
  /// **'Approaching Miqat'**
  String get approach_notif_title;

  /// No description provided for @inside_notif_title.
  ///
  /// In en, this message translates to:
  /// **'Inside Miqat'**
  String get inside_notif_title;

  /// No description provided for @inside_notif.
  ///
  /// In en, this message translates to:
  /// **'You are inside the Miqat.'**
  String get inside_notif;

  /// No description provided for @ihram_notif.
  ///
  /// In en, this message translates to:
  /// **'You are inside the Miqat. Do you want to start Ihram?'**
  String get ihram_notif;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Wait Next Miqat'**
  String get wait;

  /// No description provided for @back_inside_title.
  ///
  /// In en, this message translates to:
  /// **'Back inside Miqat'**
  String get back_inside_title;

  /// No description provided for @back_inside.
  ///
  /// In en, this message translates to:
  /// **'You are inside the Miqat again. You can start Ihram now.'**
  String get back_inside;

  /// No description provided for @exiting_title.
  ///
  /// In en, this message translates to:
  /// **'Exiting Miqat'**
  String get exiting_title;

  /// No description provided for @exiting.
  ///
  /// In en, this message translates to:
  /// **'You are Exiting the Miqat.'**
  String get exiting;

  /// No description provided for @warning_title.
  ///
  /// In en, this message translates to:
  /// **'Ihram Warning'**
  String get warning_title;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'You exited Miqat without starting Ihram. This is not permissible. You have to go back in now.'**
  String get warning;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @menuPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuPageTitle;

  /// No description provided for @searchPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchPageTitle;

  /// No description provided for @homePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homePageTitle;

  /// No description provided for @premiumPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPageTitle;

  /// No description provided for @profilePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profilePageTitle;

  /// No description provided for @preference.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preference;

  /// No description provided for @roundedButtonDefault.
  ///
  /// In en, this message translates to:
  /// **'Click'**
  String get roundedButtonDefault;

  /// No description provided for @appBarTitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get appBarTitleDefault;

  /// No description provided for @appBarTitleSub.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get appBarTitleSub;

  /// No description provided for @appBarTitlePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get appBarTitlePremium;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @continue_btn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_btn;

  /// No description provided for @i_agree.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get i_agree;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get terms;

  /// No description provided for @have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get have_account;

  /// No description provided for @fname.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get fname;

  /// No description provided for @lname.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lname;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get pass;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'BirthYear'**
  String get phone;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @must_agree.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the terms and conditions.'**
  String get must_agree;

  /// No description provided for @fill_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get fill_fields;

  /// No description provided for @read_carfully.
  ///
  /// In en, this message translates to:
  /// **'Please read carefully'**
  String get read_carfully;

  /// No description provided for @terms_text.
  ///
  /// In en, this message translates to:
  /// **'Welcome to our app’s Terms and Conditions.\n\nBy using this app, you agree to the following terms:\n\n- You acknowledge that the information provided is for general purposes.\n- We are not liable for any damages arising from the use.\n- Please ensure you use the app responsibly and respect privacy policies.\n\nThank you for taking the time to read this. If you have questions, please contact support.\n\nHappy using!'**
  String get terms_text;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @ihram_def.
  ///
  /// In en, this message translates to:
  /// **'Ihram is a sacred state Muslims enter for Hajj or Umrah.'**
  String get ihram_def;

  /// No description provided for @tawaf_def.
  ///
  /// In en, this message translates to:
  /// **'Tawaf is the act of circumambulating the Kaaba seven times.'**
  String get tawaf_def;

  /// No description provided for @saaee_def.
  ///
  /// In en, this message translates to:
  /// **'Sa\'ee is the act of walking between Safa and Marwah seven times.'**
  String get saaee_def;

  /// No description provided for @detect_nothing.
  ///
  /// In en, this message translates to:
  /// **'We didn\'t detect anything.'**
  String get detect_nothing;

  /// No description provided for @sorry.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I\'m not sure about that.'**
  String get sorry;

  /// No description provided for @ask_something.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon: Ask something like \'What is ihram?\', \'ihram prohibitions\', and we will answer you.. :)'**
  String get ask_something;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scan;

  /// No description provided for @pick_gallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pick_gallery;

  /// No description provided for @members_must_scan.
  ///
  /// In en, this message translates to:
  /// **'All members must scan this!'**
  String get members_must_scan;

  /// No description provided for @new_members.
  ///
  /// In en, this message translates to:
  /// **'New members:'**
  String get new_members;

  /// No description provided for @no_members.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get no_members;

  /// No description provided for @edit_info.
  ///
  /// In en, this message translates to:
  /// **'Click Edit Profile Info'**
  String get edit_info;

  /// No description provided for @enter_name.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enter_name;

  /// No description provided for @hajj.
  ///
  /// In en, this message translates to:
  /// **'Hajj'**
  String get hajj;

  /// No description provided for @umrah.
  ///
  /// In en, this message translates to:
  /// **'Umrah'**
  String get umrah;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @delegation.
  ///
  /// In en, this message translates to:
  /// **'Delegation'**
  String get delegation;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @leader.
  ///
  /// In en, this message translates to:
  /// **'Leader'**
  String get leader;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @madhhab.
  ///
  /// In en, this message translates to:
  /// **'Madhhab'**
  String get madhhab;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @transportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully!'**
  String get saved;

  /// No description provided for @not_set.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get not_set;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @take_pic.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get take_pic;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribe;

  /// No description provided for @premium_sub.
  ///
  /// In en, this message translates to:
  /// **'Premium Subscription'**
  String get premium_sub;

  /// No description provided for @hotel_text.
  ///
  /// In en, this message translates to:
  /// **'Up to 75% off fine hotels'**
  String get hotel_text;

  /// No description provided for @restaurant_text.
  ///
  /// In en, this message translates to:
  /// **'Affordable and delicious meals'**
  String get restaurant_text;

  /// No description provided for @shops_text.
  ///
  /// In en, this message translates to:
  /// **'Cheaper shopping (85% off)'**
  String get shops_text;

  /// No description provided for @support_text.
  ///
  /// In en, this message translates to:
  /// **'Priority support & recommendations'**
  String get support_text;

  /// No description provided for @start_payement.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get start_payement;

  /// No description provided for @payement_info.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get payement_info;

  /// No description provided for @card_nbr_title.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 16-digit card number'**
  String get card_nbr_title;

  /// No description provided for @card_nbr.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get card_nbr;

  /// No description provided for @card_hint.
  ///
  /// In en, this message translates to:
  /// **'1234 5678 9012 3456'**
  String get card_hint;

  /// No description provided for @expery_title.
  ///
  /// In en, this message translates to:
  /// **'Use MM/YY'**
  String get expery_title;

  /// No description provided for @expery.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get expery;

  /// No description provided for @expity_hint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expity_hint;

  /// No description provided for @enter_ccv.
  ///
  /// In en, this message translates to:
  /// **'Enter valid CVV'**
  String get enter_ccv;

  /// No description provided for @ccv.
  ///
  /// In en, this message translates to:
  /// **'CCV'**
  String get ccv;

  /// No description provided for @ccv_hint.
  ///
  /// In en, this message translates to:
  /// **'123'**
  String get ccv_hint;

  /// No description provided for @payement_method.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get payement_method;

  /// No description provided for @edhahabia.
  ///
  /// In en, this message translates to:
  /// **'Edahabia'**
  String get edhahabia;

  /// No description provided for @mastercard.
  ///
  /// In en, this message translates to:
  /// **'MasterCard'**
  String get mastercard;

  /// No description provided for @visa.
  ///
  /// In en, this message translates to:
  /// **'Visa'**
  String get visa;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get pay;

  /// No description provided for @payement_successful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get payement_successful;

  /// No description provided for @select_madhhab.
  ///
  /// In en, this message translates to:
  /// **'Select Madhab'**
  String get select_madhhab;

  /// No description provided for @select_country.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get select_country;

  /// No description provided for @select_transportation.
  ///
  /// In en, this message translates to:
  /// **'Select Transportation'**
  String get select_transportation;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @delete_alarms.
  ///
  /// In en, this message translates to:
  /// **'Delete Alarms'**
  String get delete_alarms;

  /// No description provided for @no_time_set.
  ///
  /// In en, this message translates to:
  /// **'No time set'**
  String get no_time_set;

  /// No description provided for @no_med_name.
  ///
  /// In en, this message translates to:
  /// **'No medicine name'**
  String get no_med_name;

  /// No description provided for @delete_selected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get delete_selected;

  /// No description provided for @medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicine;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @importance.
  ///
  /// In en, this message translates to:
  /// **'Importance'**
  String get importance;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @when.
  ///
  /// In en, this message translates to:
  /// **'When to take'**
  String get when;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Prescribed by'**
  String get doctor;

  /// No description provided for @other_times.
  ///
  /// In en, this message translates to:
  /// **'Other Times'**
  String get other_times;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @once.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get once;

  /// No description provided for @dosage_hint.
  ///
  /// In en, this message translates to:
  /// **'Dosage (e.g. 1 tablet, 5ml)'**
  String get dosage_hint;

  /// No description provided for @when_hint.
  ///
  /// In en, this message translates to:
  /// **'When to take?'**
  String get when_hint;

  /// No description provided for @purpose_hint.
  ///
  /// In en, this message translates to:
  /// **'Purpose (e.g. For blood pressure)'**
  String get purpose_hint;

  /// No description provided for @notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Notes (e.g. Carry in a cold pouch)'**
  String get notes_hint;

  /// No description provided for @doctor_hint.
  ///
  /// In en, this message translates to:
  /// **'Prescriber (Doctor\'s Name or Contact)'**
  String get doctor_hint;

  /// No description provided for @times_per_day.
  ///
  /// In en, this message translates to:
  /// **'Times per Day'**
  String get times_per_day;

  /// No description provided for @btn_advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced >'**
  String get btn_advanced;

  /// No description provided for @med_name.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get med_name;

  /// No description provided for @face_fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Use Face or Fingerprint to Log in'**
  String get face_fingerprint;

  /// No description provided for @authenticated.
  ///
  /// In en, this message translates to:
  /// **'Authenticated successfully!'**
  String get authenticated;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcome_back;

  /// No description provided for @signin_continue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signin_continue;

  /// No description provided for @login_methods.
  ///
  /// In en, this message translates to:
  /// **'Username, email, mobile number'**
  String get login_methods;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get create_account;

  /// No description provided for @group_member.
  ///
  /// In en, this message translates to:
  /// **'Group Member'**
  String get group_member;

  /// No description provided for @group_leader.
  ///
  /// In en, this message translates to:
  /// **'Group Leader'**
  String get group_leader;

  /// No description provided for @user_straying.
  ///
  /// In en, this message translates to:
  /// **'⚠️ You\'re Straying'**
  String get user_straying;

  /// No description provided for @member_straying.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Member Straying'**
  String get member_straying;

  /// No description provided for @straying_service_on.
  ///
  /// In en, this message translates to:
  /// **'Straying detection activated. We\'ll now start monitoring your delegation\'s location.'**
  String get straying_service_on;

  /// No description provided for @straying_service_off.
  ///
  /// In en, this message translates to:
  /// **'Straying detection deactivated. Monitoring stopped.'**
  String get straying_service_off;

  /// No description provided for @detection_on.
  ///
  /// In en, this message translates to:
  /// **'Detection Started'**
  String get detection_on;

  /// No description provided for @detection_off.
  ///
  /// In en, this message translates to:
  /// **'Detection Stopped'**
  String get detection_off;

  /// No description provided for @you_straying.
  ///
  /// In en, this message translates to:
  /// **'You are getting too far from your group. Please come back.'**
  String get you_straying;

  /// No description provided for @premium_hotel_title.
  ///
  /// In en, this message translates to:
  /// **'Fine Hotels That can be 60% to 75% cheaper'**
  String get premium_hotel_title;

  /// No description provided for @premium_food_title.
  ///
  /// In en, this message translates to:
  /// **'Find more affordable meals 50% to 70% cheaper and more delicious'**
  String get premium_food_title;

  /// No description provided for @premium_shop_title.
  ///
  /// In en, this message translates to:
  /// **'Shops 85% cheaper and items that can cost you 10-20 SAR instead'**
  String get premium_shop_title;

  /// No description provided for @menu_delegation.
  ///
  /// In en, this message translates to:
  /// **'Delegation'**
  String get menu_delegation;

  /// No description provided for @menu_ihram.
  ///
  /// In en, this message translates to:
  /// **'Ihram'**
  String get menu_ihram;

  /// No description provided for @menu_hajj.
  ///
  /// In en, this message translates to:
  /// **'Hajj'**
  String get menu_hajj;

  /// No description provided for @menu_umrah.
  ///
  /// In en, this message translates to:
  /// **'Umrah'**
  String get menu_umrah;

  /// No description provided for @menu_lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get menu_lost;

  /// No description provided for @menu_medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get menu_medicine;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get language_arabic;

  /// No description provided for @goal_hajj.
  ///
  /// In en, this message translates to:
  /// **'Hajj'**
  String get goal_hajj;

  /// No description provided for @goal_umrah.
  ///
  /// In en, this message translates to:
  /// **'Umrah'**
  String get goal_umrah;

  /// No description provided for @madhhab_shafii.
  ///
  /// In en, this message translates to:
  /// **'Shafii'**
  String get madhhab_shafii;

  /// No description provided for @madhhab_hanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get madhhab_hanafi;

  /// No description provided for @madhhab_hanbali.
  ///
  /// In en, this message translates to:
  /// **'Hanbali'**
  String get madhhab_hanbali;

  /// No description provided for @madhhab_maliki.
  ///
  /// In en, this message translates to:
  /// **'Maliki'**
  String get madhhab_maliki;

  /// No description provided for @country_saudi_arabia.
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get country_saudi_arabia;

  /// No description provided for @country_egypt.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get country_egypt;

  /// No description provided for @country_pakistan.
  ///
  /// In en, this message translates to:
  /// **'Pakistan'**
  String get country_pakistan;

  /// No description provided for @country_malaysia.
  ///
  /// In en, this message translates to:
  /// **'Malaysia'**
  String get country_malaysia;

  /// No description provided for @country_turkey.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get country_turkey;

  /// No description provided for @transport_air.
  ///
  /// In en, this message translates to:
  /// **'By Air'**
  String get transport_air;

  /// No description provided for @transport_sea.
  ///
  /// In en, this message translates to:
  /// **'By Sea'**
  String get transport_sea;

  /// No description provided for @transport_vehicle.
  ///
  /// In en, this message translates to:
  /// **'By Vehicle'**
  String get transport_vehicle;

  /// No description provided for @transport_foot.
  ///
  /// In en, this message translates to:
  /// **'By foot'**
  String get transport_foot;

  /// No description provided for @saying_1_description.
  ///
  /// In en, this message translates to:
  /// **'❌ Not approved by maddhab Maliki\n❌ Not approved by maddhab Hanbali\n❌ Not approved by maddhab Hanafi\n❌ Not approved by maddhab Sahfii'**
  String get saying_1_description;

  /// No description provided for @saying_2_description.
  ///
  /// In en, this message translates to:
  /// **'❌ Not approved by maddhab Maliki\n❌ Not approved by maddhab Hanbali\n❌ Not approved by maddhab Hanafi\n❌ Not approved by maddhab Sahfii'**
  String get saying_2_description;

  /// No description provided for @saying_3_description.
  ///
  /// In en, this message translates to:
  /// **'✅ Approved by maddhab Maliki\n✅ Approved by maddhab Hanbali\n✅ Approved by maddhab Hanafi\n✅ Approved by maddhab Sahfii'**
  String get saying_3_description;

  /// No description provided for @saying_4_description.
  ///
  /// In en, this message translates to:
  /// **'Description for Saying 4'**
  String get saying_4_description;

  /// No description provided for @saying_5_description.
  ///
  /// In en, this message translates to:
  /// **'❌ Not approved by maddhab Maliki\n✅ Approved by madhhab Hanbali\n❌ Not approved by maddhab Hanafi\n❌ Not approved by maddhab Sahfii'**
  String get saying_5_description;

  /// No description provided for @ihram.
  ///
  /// In en, this message translates to:
  /// **'Ihram'**
  String get ihram;

  /// No description provided for @country_algeria.
  ///
  /// In en, this message translates to:
  /// **'Algeria'**
  String get country_algeria;

  /// No description provided for @miqat_dhul_Hulaifa.
  ///
  /// In en, this message translates to:
  /// **'Dhul Hulaifa'**
  String get miqat_dhul_Hulaifa;

  /// No description provided for @miqat_juhfa.
  ///
  /// In en, this message translates to:
  /// **'Juhfa'**
  String get miqat_juhfa;

  /// No description provided for @miqat_yalmlm.
  ///
  /// In en, this message translates to:
  /// **'Yalamlam'**
  String get miqat_yalmlm;

  /// No description provided for @miqat_dhat_irq.
  ///
  /// In en, this message translates to:
  /// **'Dhat Irq'**
  String get miqat_dhat_irq;

  /// No description provided for @miqat_qarn_manazil.
  ///
  /// In en, this message translates to:
  /// **'Qarn al-Manazil'**
  String get miqat_qarn_manazil;

  /// No description provided for @hajj_step_1_title.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Ihram'**
  String get hajj_step_1_title;

  /// No description provided for @hajj_step_1_description.
  ///
  /// In en, this message translates to:
  /// **'Make intention and enter Ihram from Miqat with Talbiyah.'**
  String get hajj_step_1_description;

  /// No description provided for @hajj_step_2_title.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Tawaf al-Qudum'**
  String get hajj_step_2_title;

  /// No description provided for @hajj_step_2_description.
  ///
  /// In en, this message translates to:
  /// **'Perform the arrival Tawaf (circumambulation of the Kaaba).'**
  String get hajj_step_2_description;

  /// No description provided for @hajj_step_3_title.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Sa’i between Safa and Marwah'**
  String get hajj_step_3_title;

  /// No description provided for @hajj_step_3_description.
  ///
  /// In en, this message translates to:
  /// **'Walk 7 times between the hills of Safa and Marwah.'**
  String get hajj_step_3_description;

  /// No description provided for @hajj_step_4_title.
  ///
  /// In en, this message translates to:
  /// **'Step 4: Stay at Mina'**
  String get hajj_step_4_title;

  /// No description provided for @hajj_step_4_description.
  ///
  /// In en, this message translates to:
  /// **'On 8th Dhul Hijjah, stay in Mina and pray shortened prayers.'**
  String get hajj_step_4_description;

  /// No description provided for @hajj_step_5_title.
  ///
  /// In en, this message translates to:
  /// **'Step 5: Day of Arafah'**
  String get hajj_step_5_title;

  /// No description provided for @hajj_step_5_description.
  ///
  /// In en, this message translates to:
  /// **'On 9th Dhul Hijjah, stand in prayer and supplication at Arafah.'**
  String get hajj_step_5_description;

  /// No description provided for @hajj_step_6_title.
  ///
  /// In en, this message translates to:
  /// **'Step 6: Muzdalifah'**
  String get hajj_step_6_title;

  /// No description provided for @hajj_step_6_description.
  ///
  /// In en, this message translates to:
  /// **'Collect pebbles and spend the night under the sky in Muzdalifah.'**
  String get hajj_step_6_description;

  /// No description provided for @hajj_step_7_title.
  ///
  /// In en, this message translates to:
  /// **'Step 7: Rami at Jamarat'**
  String get hajj_step_7_title;

  /// No description provided for @hajj_step_7_description.
  ///
  /// In en, this message translates to:
  /// **'On 10th Dhul Hijjah, throw 7 pebbles at the Jamrah al-Aqabah.'**
  String get hajj_step_7_description;

  /// No description provided for @hajj_step_8_title.
  ///
  /// In en, this message translates to:
  /// **'Step 8: Qurbani'**
  String get hajj_step_8_title;

  /// No description provided for @hajj_step_8_description.
  ///
  /// In en, this message translates to:
  /// **'Offer animal sacrifice (or arrange it through a service).'**
  String get hajj_step_8_description;

  /// No description provided for @hajj_step_9_title.
  ///
  /// In en, this message translates to:
  /// **'Step 9: Hair Cut/Shave'**
  String get hajj_step_9_title;

  /// No description provided for @hajj_step_9_description.
  ///
  /// In en, this message translates to:
  /// **'Men shave or trim hair; women cut a small portion.'**
  String get hajj_step_9_description;

  /// No description provided for @hajj_step_10_title.
  ///
  /// In en, this message translates to:
  /// **'Step 10: Tawaf al-Ifadah'**
  String get hajj_step_10_title;

  /// No description provided for @hajj_step_10_description.
  ///
  /// In en, this message translates to:
  /// **'Mandatory Tawaf done after sacrifice and hair cutting.'**
  String get hajj_step_10_description;

  /// No description provided for @hajj_step_11_title.
  ///
  /// In en, this message translates to:
  /// **'Step 11: Days of Tashreeq'**
  String get hajj_step_11_title;

  /// No description provided for @hajj_step_11_description.
  ///
  /// In en, this message translates to:
  /// **'Stay in Mina and perform Rami for the next 2–3 days.'**
  String get hajj_step_11_description;

  /// No description provided for @hajj_step_12_title.
  ///
  /// In en, this message translates to:
  /// **'Step 12: Tawaf al-Wida'**
  String get hajj_step_12_title;

  /// No description provided for @hajj_step_12_description.
  ///
  /// In en, this message translates to:
  /// **'Farewell Tawaf before leaving Makkah (mandatory for non-locals).'**
  String get hajj_step_12_description;

  /// No description provided for @ihram_step_1_title.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Intention (Niyyah)'**
  String get ihram_step_1_title;

  /// No description provided for @ihram_step_1_description.
  ///
  /// In en, this message translates to:
  /// **'Make your intention for Hajj or Umrah before entering the Miqat.'**
  String get ihram_step_1_description;

  /// No description provided for @ihram_step_2_title.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Ghusl and Cleanliness'**
  String get ihram_step_2_title;

  /// No description provided for @ihram_step_2_description.
  ///
  /// In en, this message translates to:
  /// **'Perform full-body purification (ghusl), trim nails, and wear Ihram clothes.'**
  String get ihram_step_2_description;

  /// No description provided for @ihram_step_3_title.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Wearing Ihram'**
  String get ihram_step_3_title;

  /// No description provided for @ihram_step_3_description.
  ///
  /// In en, this message translates to:
  /// **'Men wear 2 white sheets. Women wear modest Islamic dress.'**
  String get ihram_step_3_description;

  /// No description provided for @ihram_step_4_title.
  ///
  /// In en, this message translates to:
  /// **'Step 4: Talbiyah'**
  String get ihram_step_4_title;

  /// No description provided for @ihram_step_4_description.
  ///
  /// In en, this message translates to:
  /// **'Recite \"Labbayk Allahumma Labbayk...\" after entering Ihram.'**
  String get ihram_step_4_description;

  /// No description provided for @ihram_step_5_title.
  ///
  /// In en, this message translates to:
  /// **'Step 5: Avoid Prohibited Acts'**
  String get ihram_step_5_title;

  /// No description provided for @ihram_step_5_description.
  ///
  /// In en, this message translates to:
  /// **'Avoid cutting hair, perfume, arguing, or intimate relations while in Ihram.'**
  String get ihram_step_5_description;

  /// No description provided for @umrah_step_1_title.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Ihram'**
  String get umrah_step_1_title;

  /// No description provided for @umrah_step_1_description.
  ///
  /// In en, this message translates to:
  /// **'Enter the state of Ihram from the Miqat with intention and Talbiyah.'**
  String get umrah_step_1_description;

  /// No description provided for @umrah_step_2_title.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Tawaf'**
  String get umrah_step_2_title;

  /// No description provided for @umrah_step_2_description.
  ///
  /// In en, this message translates to:
  /// **'Perform 7 rounds of Tawaf around the Kaaba in a counter-clockwise direction.'**
  String get umrah_step_2_description;

  /// No description provided for @umrah_step_3_title.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Prayer at Maqam Ibrahim'**
  String get umrah_step_3_title;

  /// No description provided for @umrah_step_3_description.
  ///
  /// In en, this message translates to:
  /// **'Pray two Rak’ahs behind Maqam Ibrahim after completing Tawaf.'**
  String get umrah_step_3_description;

  /// No description provided for @umrah_step_4_title.
  ///
  /// In en, this message translates to:
  /// **'Step 4: Sa’i'**
  String get umrah_step_4_title;

  /// No description provided for @umrah_step_4_description.
  ///
  /// In en, this message translates to:
  /// **'Walk 7 times between Safa and Marwah, starting at Safa and ending at Marwah.'**
  String get umrah_step_4_description;

  /// No description provided for @umrah_step_5_title.
  ///
  /// In en, this message translates to:
  /// **'Step 5: Hair Cut or Shave'**
  String get umrah_step_5_title;

  /// No description provided for @umrah_step_5_description.
  ///
  /// In en, this message translates to:
  /// **'Men shave or trim hair; women cut a small portion of their hair.'**
  String get umrah_step_5_description;

  /// No description provided for @umrah_step_6_title.
  ///
  /// In en, this message translates to:
  /// **'Step 6: Exit Ihram'**
  String get umrah_step_6_title;

  /// No description provided for @umrah_step_6_description.
  ///
  /// In en, this message translates to:
  /// **'After the haircut, you are out of Ihram and the Umrah is complete.'**
  String get umrah_step_6_description;

  /// No description provided for @allow_allocation_access.
  ///
  /// In en, this message translates to:
  /// **'Allow Location Access?'**
  String get allow_allocation_access;

  /// No description provided for @allow_allocation_access_text.
  ///
  /// In en, this message translates to:
  /// **'To provide better guidance, would you like to select your location manually by tapping on the map? Or use GPS'**
  String get allow_allocation_access_text;

  /// No description provided for @auto_detect.
  ///
  /// In en, this message translates to:
  /// **'Auto Detect'**
  String get auto_detect;

  /// No description provided for @select_manually.
  ///
  /// In en, this message translates to:
  /// **'Select Manually'**
  String get select_manually;

  /// Label for the saying with its number
  ///
  /// In en, this message translates to:
  /// **'Saying {number}'**
  String saying_number(int number);

  /// Warning for member by name
  ///
  /// In en, this message translates to:
  /// **'Hey {firstName} {lastName}, you’re too far from your group. Please go back.'**
  String member_full_name_warning(String firstName, String lastName);

  /// Warning for leader
  ///
  /// In en, this message translates to:
  /// **'Leader {leaderName}'**
  String leader_warning(String leaderName);

  /// Polygon ID for the annulus with the miqat name
  ///
  /// In en, this message translates to:
  /// **'polygon_{name}_annulus'**
  String polygon_annulus_id(String name);

  /// No description provided for @lost_1.
  ///
  /// In en, this message translates to:
  /// **'This will help us identify lost people if they\'re registered in our system. Please take a clear picture of their face'**
  String get lost_1;

  /// No description provided for @lost_2.
  ///
  /// In en, this message translates to:
  /// **'This process will take a moment. Please wait..'**
  String get lost_2;

  /// No description provided for @lost_3.
  ///
  /// In en, this message translates to:
  /// **'No image picked. Please try again'**
  String get lost_3;

  /// No description provided for @lost_4.
  ///
  /// In en, this message translates to:
  /// **'No face detected in the photo. Please try again'**
  String get lost_4;

  /// Message when the user in the picture belongs to the current user
  ///
  /// In en, this message translates to:
  /// **'The user in the picture you took belongs to you. {lastName} {firstName}'**
  String lost_5(String lastName, String firstName);

  /// Message when the user is the leader of his delegation
  ///
  /// In en, this message translates to:
  /// **'This user is the leader of his delegation. He is {lastName} {firstName}'**
  String lost_6(String lastName, String firstName);

  /// Message when user is found and help to get to delegation is offered
  ///
  /// In en, this message translates to:
  /// **'User found! {lastName} {firstName}. We\'ll help you get to his delegation, thank you for your help.'**
  String lost_7(String lastName, String firstName);

  /// Message when user is not found in any delegation
  ///
  /// In en, this message translates to:
  /// **'User does not belong to any delegation. Please try again in better lighting or reach out to local authorities.'**
  String get lost_8;

  /// No description provided for @lost_9.
  ///
  /// In en, this message translates to:
  /// **'User not registered in our system. Please try again in better lighting or reach out to local authorities.'**
  String get lost_9;

  /// No description provided for @face_verification.
  ///
  /// In en, this message translates to:
  /// **'Face Verification'**
  String get face_verification;

  /// No description provided for @take_pic_verify.
  ///
  /// In en, this message translates to:
  /// **'Take Photo and Verify'**
  String get take_pic_verify;

  /// No description provided for @find_delegation.
  ///
  /// In en, this message translates to:
  /// **'Find his delegation'**
  String get find_delegation;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
