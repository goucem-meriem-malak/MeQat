import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get usernameHint => 'Username, email, mobile number';

  @override
  String get passwordHint => 'Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get createAccount => 'Create new account';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get app_name => 'MeQat';

  @override
  String get hello => 'Hello';

  @override
  String get welcome => 'Welcome to our app';

  @override
  String get delegation_page_title => 'Delegation Page';

  @override
  String get location_services_disabled => 'Location services are disabled. Please enable them.';

  @override
  String get location_permissions_denied => 'Location permissions are denied.';

  @override
  String get location_permissions_permanently_denied => 'Location permissions are permanently denied.';

  @override
  String get you_are_straying => '⚠️ You\'re Straying';

  @override
  String straying_message(Object firstName, Object lastName) {
    return 'Hey $firstName $lastName, you’re too far from your group. Please go back.';
  }

  @override
  String get ok => 'Okay';

  @override
  String get straying_member_title => '⚠️ Member Straying';

  @override
  String straying_member_message(Object fullName) {
    return '$fullName is straying from the group. Please locate them.';
  }

  @override
  String get straying_detection_activated => 'Straying detection activated. We\'ll now start monitoring your delegation\'s location.';

  @override
  String get straying_detection_deactivated => 'Straying detection deactivated. Monitoring stopped.';

  @override
  String get detection_started => 'Detection Started';

  @override
  String get detection_stopped => 'Detection Stopped';

  @override
  String get done => 'Done';

  @override
  String too_far_from_group(String firstName, String lastName) {
    return 'Hey $firstName $lastName, you’re too far from your group. Please go back.';
  }

  @override
  String get scan_qrcode => 'Scan QRCode';

  @override
  String get or => 'OR';

  @override
  String get upload_from_gallery => 'Upload from Gallery';

  @override
  String get target_location => 'Target Location';

  @override
  String get delegation_members => 'Delegation members';

  @override
  String leader_name(Object leaderName) {
    return 'Leader $leaderName';
  }

  @override
  String get no_members_yet => 'No members yet.';

  @override
  String get unnamed_member => 'Unnamed Member';

  @override
  String get scan_qr_code => 'Scan QR Code';

  @override
  String get user_Selected => 'user Selected';

  @override
  String get makkah => 'Makkah';

  @override
  String get your_location => 'Your Location';

  @override
  String get learn_more => 'Learn more >>';

  @override
  String get approach_notif => 'You are 5 minutes away from the Miqat. Get ready to enter Ihram.';

  @override
  String get approach_notif_title => 'Approaching Miqat';

  @override
  String get inside_notif_title => 'Inside Miqat';

  @override
  String get inside_notif => 'You are inside the Miqat.';

  @override
  String get ihram_notif => 'You are inside the Miqat. Do you want to start Ihram?';

  @override
  String get yes => 'Yes';

  @override
  String get later => 'Later';

  @override
  String get wait => 'Wait Next Miqat';

  @override
  String get back_inside_title => 'Back inside Miqat';

  @override
  String get back_inside => 'You are inside the Miqat again. You can start Ihram now.';

  @override
  String get exiting_title => 'Exiting Miqat';

  @override
  String get exiting => 'You are Exiting the Miqat.';

  @override
  String get warning_title => 'Ihram Warning';

  @override
  String get warning => 'You exited Miqat without starting Ihram. This is not permissible. You have to go back in now.';

  @override
  String get menu => 'Menu';

  @override
  String get search => 'Search';

  @override
  String get home => 'Home';

  @override
  String get premium => 'Premium';

  @override
  String get profile => 'Profile';

  @override
  String get menuPageTitle => 'Menu';

  @override
  String get searchPageTitle => 'Search';

  @override
  String get homePageTitle => 'Home';

  @override
  String get premiumPageTitle => 'Premium';

  @override
  String get profilePageTitle => 'Profile';

  @override
  String get preference => 'Preferences';

  @override
  String get roundedButtonDefault => 'Click';

  @override
  String get appBarTitleDefault => 'Title';

  @override
  String get appBarTitleSub => 'Subtitle';

  @override
  String get appBarTitlePremium => 'Premium';

  @override
  String get sign_up => 'Sign Up';

  @override
  String get english => 'English';

  @override
  String get continue_btn => 'Continue';

  @override
  String get i_agree => 'I agree to the ';

  @override
  String get terms => 'Terms and conditions';

  @override
  String get have_account => 'Already have an account?';

  @override
  String get fname => 'First Name';

  @override
  String get lname => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get pass => 'Password';

  @override
  String get phone => 'BirthYear';

  @override
  String get login => 'Log in';

  @override
  String get must_agree => 'You must agree to the terms and conditions.';

  @override
  String get fill_fields => 'Please fill in all fields.';

  @override
  String get read_carfully => 'Please read carefully';

  @override
  String get terms_text => 'Welcome to our app’s Terms and Conditions.\n\nBy using this app, you agree to the following terms:\n\n- You acknowledge that the information provided is for general purposes.\n- We are not liable for any damages arising from the use.\n- Please ensure you use the app responsibly and respect privacy policies.\n\nThank you for taking the time to read this. If you have questions, please contact support.\n\nHappy using!';

  @override
  String get agree => 'Agree';

  @override
  String get ihram_def => 'Ihram is a sacred state Muslims enter for Hajj or Umrah.';

  @override
  String get tawaf_def => 'Tawaf is the act of circumambulating the Kaaba seven times.';

  @override
  String get saaee_def => 'Sa\'ee is the act of walking between Safa and Marwah seven times.';

  @override
  String get detect_nothing => 'We didn\'t detect anything.';

  @override
  String get sorry => 'Sorry, I\'m not sure about that.';

  @override
  String get ask_something => 'Coming Soon: Ask something like \'What is ihram?\', \'ihram prohibitions\', and we will answer you.. :)';

  @override
  String get scan => 'Scan QR code';

  @override
  String get pick_gallery => 'Pick from Gallery';

  @override
  String get members_must_scan => 'All members must scan this!';

  @override
  String get new_members => 'New members:';

  @override
  String get no_members => 'No members yet';

  @override
  String get edit_info => 'Click Edit Profile Info';

  @override
  String get enter_name => 'Enter your full name';

  @override
  String get hajj => 'Hajj';

  @override
  String get umrah => 'Umrah';

  @override
  String get individual => 'Individual';

  @override
  String get delegation => 'Delegation';

  @override
  String get member => 'Member';

  @override
  String get leader => 'Leader';

  @override
  String get language => 'Language';

  @override
  String get madhhab => 'Madhhab';

  @override
  String get country => 'Country';

  @override
  String get transportation => 'Transportation';

  @override
  String get saved => 'Settings saved successfully!';

  @override
  String get not_set => 'Not Set';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get take_pic => 'Take a picture';

  @override
  String get subscribe => 'Subscribe Now';

  @override
  String get premium_sub => 'Premium Subscription';

  @override
  String get hotel_text => 'Up to 75% off fine hotels';

  @override
  String get restaurant_text => 'Affordable and delicious meals';

  @override
  String get shops_text => 'Cheaper shopping (85% off)';

  @override
  String get support_text => 'Priority support & recommendations';

  @override
  String get start_payement => 'Proceed to Payment';

  @override
  String get payement_info => 'Payment Information';

  @override
  String get card_nbr_title => 'Enter a valid 16-digit card number';

  @override
  String get card_nbr => 'Card Number';

  @override
  String get card_hint => '1234 5678 9012 3456';

  @override
  String get expery_title => 'Use MM/YY';

  @override
  String get expery => 'Expiry';

  @override
  String get expity_hint => 'MM/YY';

  @override
  String get enter_ccv => 'Enter valid CVV';

  @override
  String get ccv => 'CCV';

  @override
  String get ccv_hint => '123';

  @override
  String get payement_method => 'Payment Method';

  @override
  String get edhahabia => 'Edahabia';

  @override
  String get mastercard => 'MasterCard';

  @override
  String get visa => 'Visa';

  @override
  String get pay => 'Pay Now';

  @override
  String get payement_successful => 'Payment Successful!';

  @override
  String get select_madhhab => 'Select Madhab';

  @override
  String get select_country => 'Select Country';

  @override
  String get select_transportation => 'Select Transportation';

  @override
  String get next => 'Next';

  @override
  String get delete_alarms => 'Delete Alarms';

  @override
  String get no_time_set => 'No time set';

  @override
  String get no_med_name => 'No medicine name';

  @override
  String get delete_selected => 'Delete Selected';

  @override
  String get medicine => 'Medicine';

  @override
  String get repeat => 'Repeat';

  @override
  String get importance => 'Importance';

  @override
  String get dosage => 'Dosage';

  @override
  String get when => 'When to take';

  @override
  String get purpose => 'Purpose';

  @override
  String get notes => 'Notes';

  @override
  String get doctor => 'Prescribed by';

  @override
  String get other_times => 'Other Times';

  @override
  String get custom => 'Custom';

  @override
  String get once => 'Once';

  @override
  String get dosage_hint => 'Dosage (e.g. 1 tablet, 5ml)';

  @override
  String get when_hint => 'When to take?';

  @override
  String get purpose_hint => 'Purpose (e.g. For blood pressure)';

  @override
  String get notes_hint => 'Notes (e.g. Carry in a cold pouch)';

  @override
  String get doctor_hint => 'Prescriber (Doctor\'s Name or Contact)';

  @override
  String get times_per_day => 'Times per Day';

  @override
  String get btn_advanced => 'Advanced >';

  @override
  String get med_name => 'Medicine Name';

  @override
  String get face_fingerprint => 'Use Face or Fingerprint to Log in';

  @override
  String get authenticated => 'Authenticated successfully!';

  @override
  String get welcome_back => 'Welcome Back!';

  @override
  String get signin_continue => 'Sign in to continue';

  @override
  String get login_methods => 'Username, email, mobile number';

  @override
  String get forgot_password => 'Forgot password?';

  @override
  String get create_account => 'Create new account';

  @override
  String get group_member => 'Group Member';

  @override
  String get group_leader => 'Group Leader';

  @override
  String get user_straying => '⚠️ You\'re Straying';

  @override
  String get member_straying => '⚠️ Member Straying';

  @override
  String get straying_service_on => 'Straying detection activated. We\'ll now start monitoring your delegation\'s location.';

  @override
  String get straying_service_off => 'Straying detection deactivated. Monitoring stopped.';

  @override
  String get detection_on => 'Detection Started';

  @override
  String get detection_off => 'Detection Stopped';

  @override
  String get you_straying => 'You are getting too far from your group. Please come back.';

  @override
  String get premium_hotel_title => 'Fine Hotels That can be 60% to 75% cheaper';

  @override
  String get premium_food_title => 'Find more affordable meals 50% to 70% cheaper and more delicious';

  @override
  String get premium_shop_title => 'Shops 85% cheaper and items that can cost you 10-20 SAR instead';

  @override
  String get menu_delegation => 'Delegation';

  @override
  String get menu_ihram => 'Ihram';

  @override
  String get menu_hajj => 'Hajj';

  @override
  String get menu_umrah => 'Umrah';

  @override
  String get menu_lost => 'Lost';

  @override
  String get menu_medicine => 'Medicine';

  @override
  String get language_english => 'English';

  @override
  String get language_arabic => 'Arabic';

  @override
  String get goal_hajj => 'Hajj';

  @override
  String get goal_umrah => 'Umrah';

  @override
  String get madhhab_shafii => 'Shafii';

  @override
  String get madhhab_hanafi => 'Hanafi';

  @override
  String get madhhab_hanbali => 'Hanbali';

  @override
  String get madhhab_maliki => 'Maliki';

  @override
  String get country_saudi_arabia => 'Saudi Arabia';

  @override
  String get country_egypt => 'Egypt';

  @override
  String get country_pakistan => 'Pakistan';

  @override
  String get country_malaysia => 'Malaysia';

  @override
  String get country_turkey => 'Turkey';

  @override
  String get transport_air => 'By Air';

  @override
  String get transport_sea => 'By Sea';

  @override
  String get transport_vehicle => 'By Vehicle';

  @override
  String get transport_foot => 'By foot';

  @override
  String get saying_1_description => '❌ Not approved by maddhab Maliki\n❌ Not approved by maddhab Hanbali\n❌ Not approved by maddhab Hanafi\n❌ Not approved by maddhab Sahfii';

  @override
  String get saying_2_description => '❌ Not approved by maddhab Maliki\n❌ Not approved by maddhab Hanbali\n❌ Not approved by maddhab Hanafi\n❌ Not approved by maddhab Sahfii';

  @override
  String get saying_3_description => '✅ Approved by maddhab Maliki\n✅ Approved by maddhab Hanbali\n✅ Approved by maddhab Hanafi\n✅ Approved by maddhab Sahfii';

  @override
  String get saying_4_description => 'Description for Saying 4';

  @override
  String get saying_5_description => '❌ Not approved by maddhab Maliki\n✅ Approved by madhhab Hanbali\n❌ Not approved by maddhab Hanafi\n❌ Not approved by maddhab Sahfii';

  @override
  String get ihram => 'Ihram';

  @override
  String get country_algeria => 'Algeria';

  @override
  String get miqat_dhul_Hulaifa => 'Dhul Hulaifa';

  @override
  String get miqat_juhfa => 'Juhfa';

  @override
  String get miqat_yalmlm => 'Yalamlam';

  @override
  String get miqat_dhat_irq => 'Dhat Irq';

  @override
  String get miqat_qarn_manazil => 'Qarn al-Manazil';

  @override
  String get hajj_step_1_title => 'Step 1: Ihram';

  @override
  String get hajj_step_1_description => 'Make intention and enter Ihram from Miqat with Talbiyah.';

  @override
  String get hajj_step_2_title => 'Step 2: Tawaf al-Qudum';

  @override
  String get hajj_step_2_description => 'Perform the arrival Tawaf (circumambulation of the Kaaba).';

  @override
  String get hajj_step_3_title => 'Step 3: Sa’i between Safa and Marwah';

  @override
  String get hajj_step_3_description => 'Walk 7 times between the hills of Safa and Marwah.';

  @override
  String get hajj_step_4_title => 'Step 4: Stay at Mina';

  @override
  String get hajj_step_4_description => 'On 8th Dhul Hijjah, stay in Mina and pray shortened prayers.';

  @override
  String get hajj_step_5_title => 'Step 5: Day of Arafah';

  @override
  String get hajj_step_5_description => 'On 9th Dhul Hijjah, stand in prayer and supplication at Arafah.';

  @override
  String get hajj_step_6_title => 'Step 6: Muzdalifah';

  @override
  String get hajj_step_6_description => 'Collect pebbles and spend the night under the sky in Muzdalifah.';

  @override
  String get hajj_step_7_title => 'Step 7: Rami at Jamarat';

  @override
  String get hajj_step_7_description => 'On 10th Dhul Hijjah, throw 7 pebbles at the Jamrah al-Aqabah.';

  @override
  String get hajj_step_8_title => 'Step 8: Qurbani';

  @override
  String get hajj_step_8_description => 'Offer animal sacrifice (or arrange it through a service).';

  @override
  String get hajj_step_9_title => 'Step 9: Hair Cut/Shave';

  @override
  String get hajj_step_9_description => 'Men shave or trim hair; women cut a small portion.';

  @override
  String get hajj_step_10_title => 'Step 10: Tawaf al-Ifadah';

  @override
  String get hajj_step_10_description => 'Mandatory Tawaf done after sacrifice and hair cutting.';

  @override
  String get hajj_step_11_title => 'Step 11: Days of Tashreeq';

  @override
  String get hajj_step_11_description => 'Stay in Mina and perform Rami for the next 2–3 days.';

  @override
  String get hajj_step_12_title => 'Step 12: Tawaf al-Wida';

  @override
  String get hajj_step_12_description => 'Farewell Tawaf before leaving Makkah (mandatory for non-locals).';

  @override
  String get ihram_step_1_title => 'Step 1: Intention (Niyyah)';

  @override
  String get ihram_step_1_description => 'Make your intention for Hajj or Umrah before entering the Miqat.';

  @override
  String get ihram_step_2_title => 'Step 2: Ghusl and Cleanliness';

  @override
  String get ihram_step_2_description => 'Perform full-body purification (ghusl), trim nails, and wear Ihram clothes.';

  @override
  String get ihram_step_3_title => 'Step 3: Wearing Ihram';

  @override
  String get ihram_step_3_description => 'Men wear 2 white sheets. Women wear modest Islamic dress.';

  @override
  String get ihram_step_4_title => 'Step 4: Talbiyah';

  @override
  String get ihram_step_4_description => 'Recite \"Labbayk Allahumma Labbayk...\" after entering Ihram.';

  @override
  String get ihram_step_5_title => 'Step 5: Avoid Prohibited Acts';

  @override
  String get ihram_step_5_description => 'Avoid cutting hair, perfume, arguing, or intimate relations while in Ihram.';

  @override
  String get umrah_step_1_title => 'Step 1: Ihram';

  @override
  String get umrah_step_1_description => 'Enter the state of Ihram from the Miqat with intention and Talbiyah.';

  @override
  String get umrah_step_2_title => 'Step 2: Tawaf';

  @override
  String get umrah_step_2_description => 'Perform 7 rounds of Tawaf around the Kaaba in a counter-clockwise direction.';

  @override
  String get umrah_step_3_title => 'Step 3: Prayer at Maqam Ibrahim';

  @override
  String get umrah_step_3_description => 'Pray two Rak’ahs behind Maqam Ibrahim after completing Tawaf.';

  @override
  String get umrah_step_4_title => 'Step 4: Sa’i';

  @override
  String get umrah_step_4_description => 'Walk 7 times between Safa and Marwah, starting at Safa and ending at Marwah.';

  @override
  String get umrah_step_5_title => 'Step 5: Hair Cut or Shave';

  @override
  String get umrah_step_5_description => 'Men shave or trim hair; women cut a small portion of their hair.';

  @override
  String get umrah_step_6_title => 'Step 6: Exit Ihram';

  @override
  String get umrah_step_6_description => 'After the haircut, you are out of Ihram and the Umrah is complete.';

  @override
  String get allow_allocation_access => 'Allow Location Access?';

  @override
  String get allow_allocation_access_text => 'To provide better guidance, would you like to select your location manually by tapping on the map? Or use GPS';

  @override
  String get auto_detect => 'Auto Detect';

  @override
  String get select_manually => 'Select Manually';

  @override
  String saying_number(int number) {
    return 'Saying $number';
  }

  @override
  String member_full_name_warning(String firstName, String lastName) {
    return 'Hey $firstName $lastName, you’re too far from your group. Please go back.';
  }

  @override
  String leader_warning(String leaderName) {
    return 'Leader $leaderName';
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
