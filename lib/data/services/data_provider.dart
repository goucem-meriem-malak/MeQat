import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../l10n/app_localizations.dart';

class Other {

  List<Map<String, dynamic>> menuItems(BuildContext context) => [
    {'title': AppLocalizations.of(context)!.ihram, "image": "assets/img/ihram.webp",},
    {'title': AppLocalizations.of(context)!.hajj, "image": "assets/img/kabah.webp",},
    {'title': AppLocalizations.of(context)!.umrah, "image": "assets/img/umrah.webp",},
    {'title': AppLocalizations.of(context)!.delegation, "image": "assets/img/delegation.webp",},
    {'title': AppLocalizations.of(context)!.menu_lost, "image": "assets/img/lost.webp",},
    {'title': AppLocalizations.of(context)!.medicine, "image": "assets/img/meds.webp",},
  ];
  static List<Map<String, String>> premiumItems(BuildContext context) => [
    {
      "image": "assets/img/hotel.webp",
      "title": AppLocalizations.of(context)!.premium_hotel_title,
    },
    {
      "image": "assets/img/food.webp",
      "title": AppLocalizations.of(context)!.premium_food_title,
    },
    {
      "image": "assets/img/shops.webp",
      "title": AppLocalizations.of(context)!.premium_shop_title,
    },
  ];
  static List<String> languages (context)=> [AppLocalizations.of(context)!.language_english, AppLocalizations.of(context)!.language_arabic];
  static List<String> goal (context) => [AppLocalizations.of(context)!.hajj, AppLocalizations.of(context)!.umrah];
  static List<String> madhhabs (context) => [AppLocalizations.of(context)!.madhhab_shafii, AppLocalizations.of(context)!.madhhab_hanafi, AppLocalizations.of(context)!.madhhab_hanbali, AppLocalizations.of(context)!.madhhab_maliki];
  static List<String> countries(context) => [AppLocalizations.of(context)!.country_saudi_arabia, AppLocalizations.of(context)!.country_egypt, AppLocalizations.of(context)!.country_pakistan, AppLocalizations.of(context)!.country_malaysia, AppLocalizations.of(context)!.country_turkey, AppLocalizations.of(context)!.country_algeria];
  static List<String> transportationMethods (context) => [AppLocalizations.of(context)!.transport_air, AppLocalizations.of(context)!.transport_sea, AppLocalizations.of(context)!.transport_vehicle, AppLocalizations.of(context)!.transport_foot];
  static List<String> sayingDescriptions (context)=> [
    AppLocalizations.of(context)!.saying_1_description,  // Saying 1
    AppLocalizations.of(context)!.saying_2_description,  // Saying 2
    AppLocalizations.of(context)!.saying_3_description,  // Saying 3
    AppLocalizations.of(context)!.saying_4_description,  // Saying 4
    AppLocalizations.of(context)!.saying_5_description,  // Saying 5
  ];
  static List<Map<String, dynamic>> miqatData (context)=> [
    {
      "name": AppLocalizations.of(context)!.miqat_dhul_Hulaifa,
      "center": LatLng(24.413942807343183, 39.54297293708976),
      "closest": LatLng(24.390, 39.535),
      "farthest": LatLng(24.430, 39.550),
    },
    {
      "name": AppLocalizations.of(context)!.miqat_juhfa,
      "center": LatLng(22.71515249938801, 39.14514729649877),
      "closest": LatLng(22.700, 39.140),
      "farthest": LatLng(22.730, 39.160),
    },
    {
      "name": AppLocalizations.of(context)!.miqat_yalmlm,
      "center": LatLng(20.518564356141052, 39.870803989418974),
      "closest": LatLng(20.500, 39.850),
      "farthest": LatLng(20.540, 39.890),
    },
    {
      "name": AppLocalizations.of(context)!.miqat_dhat_irq,
      "center": LatLng(21.930072877611384, 40.42552892351149),
      "closest": LatLng(21.910, 40.400),
      "farthest": LatLng(21.950, 40.450),
    },
    {
      "name": AppLocalizations.of(context)!.miqat_qarn_manazil,
      "center": LatLng(21.63320606975049, 40.42677866397942),
      "closest": LatLng(21.610, 40.410),
      "farthest": LatLng(21.650, 40.440),
    },
  ];
  static List<Map<String, String>> hajjSteps(BuildContext context) => [
    {
      'title': AppLocalizations.of(context)!.hajj_step_1_title,
      'description': AppLocalizations.of(context)!.hajj_step_1_description,
      "image": "assets/img/hajj.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_2_title,
      'description': AppLocalizations.of(context)!.hajj_step_2_description,
      "image": "assets/img/tawaf.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_3_title,
      'description': AppLocalizations.of(context)!.hajj_step_3_description,
      "image": "assets/img/saae.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_4_title,
      'description': AppLocalizations.of(context)!.hajj_step_4_description,
      "image": "assets/img/sleep.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_5_title,
      'description': AppLocalizations.of(context)!.hajj_step_5_description,
      "image": "assets/img/arafah.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_6_title,
      'description': AppLocalizations.of(context)!.hajj_step_6_description,
      "image": "assets/img/rock.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_7_title,
      'description': AppLocalizations.of(context)!.hajj_step_7_description,
      "image": "assets/img/throw.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_8_title,
      'description': AppLocalizations.of(context)!.hajj_step_8_description,
      "image": "assets/img/sheep.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_9_title,
      'description': AppLocalizations.of(context)!.hajj_step_9_description,
      "image": "assets/img/cut_hair.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_10_title,
      'description': AppLocalizations.of(context)!.hajj_step_10_description,
      "image": "assets/img/tawaf.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_11_title,
      'description': AppLocalizations.of(context)!.hajj_step_11_description,
      "image": "assets/img/throw.webp"
    },
    {
      'title': AppLocalizations.of(context)!.hajj_step_12_title,
      'description': AppLocalizations.of(context)!.hajj_step_12_description,
      "image": "assets/img/tawaf.webp"
    },
  ];
  static List<Map<String, String>> ihramSteps(BuildContext context) => [
    {
      'title': AppLocalizations.of(context)!.ihram_step_1_title,
      'description': AppLocalizations.of(context)!.ihram_step_1_description,
      "image": "assets/img/niya.webp"
    },
    {
      'title': AppLocalizations.of(context)!.ihram_step_2_title,
      'description': AppLocalizations.of(context)!.ihram_step_2_description,
      "image": "assets/img/clean.webp"
    },
    {
      'title': AppLocalizations.of(context)!.ihram_step_3_title,
      'description': AppLocalizations.of(context)!.ihram_step_3_description,
      "image": "assets/img/hajj.webp"
    },
    {
      'title': AppLocalizations.of(context)!.ihram_step_4_title,
      'description': AppLocalizations.of(context)!.ihram_step_4_description,
      "image": "assets/img/talbiya.webp"
    },
    {
      'title': AppLocalizations.of(context)!.ihram_step_5_title,
      'description': AppLocalizations.of(context)!.ihram_step_5_description,
      "image": "assets/img/dont.webp"
    },
  ];
  static List<Map<String, String>> umrahSteps(BuildContext context) => [
    {
      'title': AppLocalizations.of(context)!.umrah_step_1_title,
      'description': AppLocalizations.of(context)!.umrah_step_1_description,
      "image": "assets/img/ihram.webp"
    },
    {
      'title': AppLocalizations.of(context)!.umrah_step_2_title,
      'description': AppLocalizations.of(context)!.umrah_step_2_description,
      "image": "assets/img/tawaf.webp"
    },
    {
      'title': AppLocalizations.of(context)!.umrah_step_3_title,
      'description': AppLocalizations.of(context)!.umrah_step_3_description,
      "image": "assets/img/makam_ibrahim.webp"
    },
    {
      'title': AppLocalizations.of(context)!.umrah_step_4_title,
      'description': AppLocalizations.of(context)!.umrah_step_4_description,
      "image": "assets/img/saae.webp"
    },
    {
      'title': AppLocalizations.of(context)!.umrah_step_5_title,
      'description': AppLocalizations.of(context)!.umrah_step_5_description,
      "image": "assets/img/cut_hair.webp"
    },
    {
      'title': AppLocalizations.of(context)!.umrah_step_6_title,
      'description': AppLocalizations.of(context)!.umrah_step_6_description,
      "image": "assets/img/done.webp"
    },
  ];

}