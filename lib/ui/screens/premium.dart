import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/data_provider.dart';
import '../helpers/ui_functions.dart';
import 'Profile.dart';
import 'home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final premiumItems = Other.premiumItems(context);
    return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 50) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          }
        },
      child: Scaffold(
        appBar: UIFunctions().buildAppBarPremium(AppLocalizations.of(context)!.premium),
        extendBody: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3A7BD5),
                Color(0xFF00d2ff),
                Color(0xFF3A7BD5),
                Color(0xFF9B59B6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Cards
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: premiumItems.length,
                    itemBuilder: (context, index) {
                      final item = premiumItems[index];
                      return PremiumCard(
                        imageAsset: item["image"]!,
                        title: item["title"]!,
                      );
                    },
                  ),
                ),
                // Subscribe Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.subscribe,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        // Bottom Navigation
        bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 3),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final String imageAsset;
  final String title;

  const PremiumCard({
    super.key,
    required this.imageAsset,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(imageAsset, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.premium_sub,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SubscriptionFeature(icon: Icons.hotel, text: AppLocalizations.of(context)!.hotel_text),
                    SubscriptionFeature(icon: Icons.restaurant, text: AppLocalizations.of(context)!.restaurant_text),
                    SubscriptionFeature(icon: Icons.store, text: AppLocalizations.of(context)!.shops_text),
                    SubscriptionFeature(icon: Icons.star, text: AppLocalizations.of(context)!.support_text),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentInputPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.start_payement,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentInputPage extends StatefulWidget {
  const PaymentInputPage({super.key});

  @override
  State<PaymentInputPage> createState() => _PaymentInputPageState();
}

class _PaymentInputPageState extends State<PaymentInputPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedMethod = 'Edahabia';
  String? selectedCountry = 'Algeria';

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelStyle: const TextStyle(color: Colors.deepPurple),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.payement_info),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3DADF3), Color(0xFF8058E3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                        validator: (value) {
                          if (value == null || value.length != 16) {
                            return AppLocalizations.of(context)!.card_nbr_title;
                          }
                          return null;
                        },
                        decoration: _buildInputDecoration(AppLocalizations.of(context)!.card_nbr, AppLocalizations.of(context)!.card_hint),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.datetime,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                                LengthLimitingTextInputFormatter(5),
                              ],
                              validator: (value) {
                                if (value == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                                  return AppLocalizations.of(context)!.exiting_title;
                                }
                                return null;
                              },
                              decoration: _buildInputDecoration(AppLocalizations.of(context)!.expery, AppLocalizations.of(context)!.expity_hint),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              validator: (value) {
                                if (value == null || value.length < 3 || value.length > 4) {
                                  return AppLocalizations.of(context)!.enter_ccv;
                                }
                                return null;
                              },
                              decoration: _buildInputDecoration(AppLocalizations.of(context)!.ccv, AppLocalizations.of(context)!.ccv_hint),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedCountry,
                        decoration: _buildInputDecoration(AppLocalizations.of(context)!.country, ""),
                        items: [
                          DropdownMenuItem(value: AppLocalizations.of(context)!.country_algeria, child: Text(AppLocalizations.of(context)!.country_algeria)),
                          DropdownMenuItem(value: AppLocalizations.of(context)!.country_saudi_arabia, child: Text(AppLocalizations.of(context)!.country_saudi_arabia)),
                          DropdownMenuItem(value: AppLocalizations.of(context)!.country_malaysia, child: Text(AppLocalizations.of(context)!.country_malaysia)),
                        ],
                        onChanged: (val) => setState(() => selectedCountry = val),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedMethod,
                        decoration: _buildInputDecoration(AppLocalizations.of(context)!.payement_method, ""),
                        items: [
                          DropdownMenuItem(
                            value: AppLocalizations.of(context)!.edhahabia,
                            child: Row(
                              children: [
                                Icon(Icons.credit_card, color: Colors.blueGrey),
                                SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.edhahabia),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: AppLocalizations.of(context)!.mastercard,
                            child: Row(
                              children: [
                                Icon(Icons.credit_card, color: Colors.red),
                                SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.mastercard),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: AppLocalizations.of(context)!.visa,
                            child: Row(
                              children: [
                                Icon(Icons.credit_card, color: Colors.blue),
                                SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.visa),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (val) => setState(() => selectedMethod = val),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PaymentSuccessPage()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: const Color(0xFF6A4BC4),
                            elevation: 10,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.pay,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const SubscriptionFeature({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade700,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 100),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.payement_successful,
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst); // Go back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              child: Text(AppLocalizations.of(context)!.continue_btn),
            )
          ],
        ),
      ),
    );
  }
}
