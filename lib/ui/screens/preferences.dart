import 'package:flutter/material.dart';
import '../../data/local/shared_pref.dart';
import '../../data/models/preference.dart';
import '../../data/services/data_provider.dart';
import '../../data/services/firebase_service.dart';
import '../../l10n/app_localizations.dart';
import '../helpers/ui_functions.dart';
import 'home.dart';
import 'login.dart';
import 'QRPage.dart';


final other = Other();

class PreferencesPage extends StatefulWidget {
  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}


class _PreferencesPageState extends State<PreferencesPage> {
  String? uid;

  String? selectedLanguage;
  bool selectedGoal = false;
  String? selectedMadhhab;
  String? selectedCountry;
  String? selectedTransportation;
  bool _isWithDelegation = false;
  bool _isLeader = false;
  bool hasMadhabError = false;
  bool hasCountryError = false;
  bool hasTransportError = false;


  @override
  void initState(){
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> languages = Other.languages(context);
    final List<String> goal = Other.goal(context);
    final List<String> madhhabs = Other.madhhabs(context);
    final List<String> countries = Other.countries(context);
    final List<String> transportationMethods = Other.transportationMethods(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
        child: Column(
          children: [
            const Spacer(flex: 2),

            Center(
              child: Text(
                AppLocalizations.of(context)!.preference,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF353535), // Softer than black
                  letterSpacing: 1.4,
                  shadows: [
                    Shadow(
                      offset: Offset(0.5, 1.5),
                      blurRadius: 4.0,
                      color: Colors.black12,
                    ),
                    Shadow(
                      offset: Offset(-0.5, -0.5),
                      blurRadius: 2.0,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 1),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // First Switch: Hajj / Umrah
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(AppLocalizations.of(context)!.hajj),
                        ),
                      ),
                      Switch(
                        value: selectedGoal,
                        activeColor: Colors.deepPurpleAccent,
                        inactiveThumbColor: Colors.deepPurple,
                        onChanged: (bool value) {
                          setState(() {
                            selectedGoal = value;
                          });
                        },
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(AppLocalizations.of(context)!.umrah),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Second Switch: Individual / Delegation
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(AppLocalizations.of(context)!.individual),
                        ),
                      ),
                      Switch(
                        value: _isWithDelegation,
                        activeColor: Colors.deepPurpleAccent,
                        inactiveThumbColor: Colors.deepPurple,
                        onChanged: (value) {
                          setState(() {
                            _isWithDelegation = value;
                          });
                        },
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(AppLocalizations.of(context)!.delegation),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  AnimatedOpacity(
                    opacity: _isWithDelegation ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300), // optional fade animation
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(AppLocalizations.of(context)!.member),
                          ),
                        ),
                        Switch(
                          value: _isLeader,
                          activeColor: Colors.deepPurpleAccent,
                          inactiveThumbColor: Colors.deepPurple,
                          onChanged: _isWithDelegation
                              ? (value) {
                            setState(() {
                              _isLeader = value;
                            });
                          }
                              : null, // disable switch if delegation off
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(AppLocalizations.of(context)!.leader),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            _buildDropdown(
              AppLocalizations.of(context)!.select_madhhab,
              Icons.account_balance,
              madhhabs,
                  (value) => setState(() => selectedMadhhab = value),
              hasMadhabError,
            ),

            _buildDropdown(
              AppLocalizations.of(context)!.select_country,
              Icons.public,
              countries,
                  (value) => setState(() => selectedCountry = value),
              hasCountryError,
            ),

            _buildDropdown(
              AppLocalizations.of(context)!.select_transportation,
              Icons.directions_car,
              transportationMethods,
                  (value) => setState(() => selectedTransportation = value),
              hasTransportError,
            ),


            const SizedBox(height: 16),

            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: UIFunctions().buildRoundedButton(
                title: AppLocalizations.of(context)!.next,
                onPressed: () {
                  setState(() {
                    hasMadhabError = selectedMadhhab == null || selectedMadhhab!.isEmpty;
                    hasCountryError = selectedCountry == null || selectedCountry!.isEmpty;
                    hasTransportError = selectedTransportation == null || selectedTransportation!.isEmpty;
                  });

                  if (!hasMadhabError && !hasCountryError && !hasTransportError) {
                    onPress();
                  }
                },
              ),
            ),

            const Spacer(flex: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.have_account, style: TextStyle(color: Colors.black87)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.login,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "MeQat",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String hint,
      IconData icon,
      List<String> listItems,
      Function(String?) onChanged,
      bool hasError,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0,0),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54, size: 20),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.deepPurple, size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.transparent, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.deepPurpleAccent, width: 1.5),
          ),
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        items: listItems.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(item),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }


  Future<void> onPress() async {
    Preference pref = Preference();
    pref.leader = _isLeader;
    pref.delegation = _isWithDelegation;
    pref.goal = selectedGoal;
    pref.transportation = selectedTransportation;
    pref.maddhab = selectedMadhhab;
    pref.country = selectedCountry;

    SharedPref().savePreferences(pref);

    final userData = {
      'goal': selectedGoal,
      'madhhab': selectedMadhhab,
      'country': selectedCountry,
      'transportation': selectedTransportation,
      'delegation': _isWithDelegation,
      'leader': _isLeader,
    };
    await UpdateFirebase().uploadPreferences(userData);

    if(_isWithDelegation){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRPage(isLeader: _isLeader),
        ),
      );
    } else{
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }
  }


  void _loadData() async {
  uid = await SharedPref().getUID();
  selectedLanguage = await SharedPref().getPreference("language");

  setState(() {});
  }
}