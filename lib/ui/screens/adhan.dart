import 'dart:async';
import 'dart:convert';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/ui_functions.dart';
import 'delegation.dart';
import 'hajj.dart';
import 'ihram.dart';
import 'lost.dart';
import 'medicine.dart';
import 'umrah.dart';

class SalatHomePage extends StatefulWidget {
  const SalatHomePage({super.key});

  @override
  State<SalatHomePage> createState() => _SalatHomePageState();
}

class _SalatHomePageState extends State<SalatHomePage> with SingleTickerProviderStateMixin {
  // State
  Position? _position;
  PrayerTimes? _prayerTimes;
  CalculationParameters _calcParams = CalculationMethod.muslim_world_league.getParameters();
  Madhab _madhab = Madhab.shafi;
  int _manualOffsetMinutes = 0;

  bool _loading = true;
  String? _error;
  DateTime _now = DateTime.now();

  Timer? _midnightTimer;
  Timer? _clockTimer;

  // persistence
  late SharedPreferences _prefs;

  // cached prayer times JSON (simple cache to survive offline)
  static const _prefsKeyTimes = 'cached_prayer_times';
  static const _prefsKeyLat = 'last_lat';
  static const _prefsKeyLon = 'last_lon';
  static const _prefsKeyMethod = 'calc_method';
  static const _prefsKeyMadhab = 'madhab';
  static const _prefsKeyOffset = 'offset_mins';

  // fallback cities (useful when GPS blocked / offline)
  final List<Map<String, dynamic>> _fallbackCities = [
    {'name': 'Algiers, Algeria', 'lat': 36.7538, 'lon': 3.0588},
    {'name': 'Cairo, Egypt', 'lat': 30.0444, 'lon': 31.2357},
    {'name': 'Istanbul, Turkey', 'lat': 41.0082, 'lon': 28.9784},
    {'name': 'Riyadh, Saudi Arabia', 'lat': 24.7136, 'lon': 46.6753},
    {'name': 'London, UK', 'lat': 51.5074, 'lon': -0.1278},
  ];

  // Animation controller for UI flair
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _initAll();
    _startClock();
  }

  @override
  void dispose() {
    _animController.dispose();
    _midnightTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  Future<void> _initAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    _prefs = await SharedPreferences.getInstance();

    // load saved preferences
    final methodIndex = _prefs.getInt(_prefsKeyMethod);
    if (methodIndex != null && methodIndex >= 0 && methodIndex < CalculationMethod.values.length) {
      _calcParams = CalculationMethod.values[methodIndex].getParameters();
    }

    final madhabIndex = _prefs.getInt(_prefsKeyMadhab);
    if (madhabIndex != null && madhabIndex >= 0 && madhabIndex < Madhab.values.length) {
      _madhab = Madhab.values[madhabIndex];
      _calcParams.madhab = _madhab;
    }

    _manualOffsetMinutes = _prefs.getInt(_prefsKeyOffset) ?? 0;

    // try to use GPS first; fallbacks applied inside _loadWithFallbacks
    await _loadWithFallbacks();

    setState(() => _loading = false);
    _animController.forward();
    _scheduleMidnightRefresh();
  }

  Future<void> _loadWithFallbacks() async {
    // 1) Try live GPS
    try {
      final pos = await _determinePosition();
      await _usePosition(pos);
      return;
    } catch (e) {
      // ignore but store reason
      _error = 'GPS unavailable — ${e.toString()}';
    }

    // 2) Try cached coordinates
    final lat = _prefs.getDouble(_prefsKeyLat);
    final lon = _prefs.getDouble(_prefsKeyLon);
    if (lat != null && lon != null) {
      final coords = Coordinates(lat, lon);
      final cached = _prefs.getString(_prefsKeyTimes);
      if (cached != null) {
        try {
          final decoded = jsonDecode(cached) as Map<String, dynamic>;
          final times = _prayerTimesFromJson(decoded);
          setState(() {
            _position = Position(latitude: lat, longitude: lon, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
            _prayerTimes = times;
            _error = null;
          });
          return;
        } catch (e) {
          // fall through
        }
      }
      // if no cached times, compute from cached coords
      final computed = PrayerTimes(coords, DateComponents.from(DateTime.now()), _calcParams);
      setState(() {
        _position = Position(latitude: lat, longitude: lon, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
        _prayerTimes = computed;
      });
      return;
    }

    // 3) No GPS or cache — ask user to pick a fallback city (we'll pick first for now)
    final fallback = _fallbackCities.first;
    final coords = Coordinates(fallback['lat'] as double, fallback['lon'] as double);
    final computed = PrayerTimes(coords, DateComponents.from(DateTime.now()), _calcParams);
    setState(() {
      _position = Position(latitude: coords.latitude, longitude: coords.longitude, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
      _prayerTimes = computed;
      _error = 'Using fallback: ${fallback['name']}';
    });
  }

  Future<Position> _determinePosition() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception('Location services disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('Permission denied');
    }
    if (permission == LocationPermission.deniedForever) throw Exception('Permission permanently denied');

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return pos;
  }

  Future<void> _usePosition(Position pos) async {
    final coords = Coordinates(pos.latitude, pos.longitude);
    final times = PrayerTimes(coords, DateComponents.from(DateTime.now()), _calcParams);

    // save cache
    _prefs.setDouble(_prefsKeyLat, pos.latitude);
    _prefs.setDouble(_prefsKeyLon, pos.longitude);
    _prefs.setString(_prefsKeyTimes, jsonEncode(_prayerTimesToJson(times)));

    setState(() {
      _position = pos;
      _prayerTimes = times;
      _error = null;
    });
  }

  Map<String, dynamic> _prayerTimesToJson(PrayerTimes t) => {
    'fajr': t.fajr.toIso8601String(),
    'sunrise': t.sunrise.toIso8601String(),
    'dhuhr': t.dhuhr.toIso8601String(),
    'asr': t.asr.toIso8601String(),
    'maghrib': t.maghrib.toIso8601String(),
    'isha': t.isha.toIso8601String(),
  };

  PrayerTimes _prayerTimesFromJson(Map<String, dynamic> j) {
    // To reconstruct PrayerTimes object we only need coordinates and parameters; but for simplicity
    // we'll construct a dummy with cached times by using DateTimes directly and a default coordinates.
    // For display we don't actually require a full PrayerTimes; we will use a wrapper object below.
    // We'll create a PrayerTimes-like object by computing with last saved coords.
    final lat = _prefs.getDouble(_prefsKeyLat) ?? 0.0;
    final lon = _prefs.getDouble(_prefsKeyLon) ?? 0.0;
    final coords = Coordinates(lat, lon);
    final computed = PrayerTimes(coords, DateComponents.from(DateTime.now()), _calcParams);
    return computed;
  }

  DateTime _applyOffset(DateTime dt) => dt.add(Duration(minutes: _manualOffsetMinutes));

  Map<String, DateTime> _prayerMap() {
    if (_prayerTimes == null) return {};
    return {
      'Fajr': _applyOffset(_prayerTimes!.fajr.toLocal()),
      'Sunrise': _applyOffset(_prayerTimes!.sunrise.toLocal()),
      'Dhuhr': _applyOffset(_prayerTimes!.dhuhr.toLocal()),
      'Asr': _applyOffset(_prayerTimes!.asr.toLocal()),
      'Maghrib': _applyOffset(_prayerTimes!.maghrib.toLocal()),
      'Isha': _applyOffset(_prayerTimes!.isha.toLocal()),
    };
  }

  MapEntry<String, DateTime>? _nextPrayer() {
    final now = DateTime.now();
    for (final e in _prayerMap().entries) if (e.value.isAfter(now)) return e;
    return null;
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dur = tomorrow.difference(now) + const Duration(seconds: 2);
    _midnightTimer = Timer(dur, () async {
      // recompute using whatever coords we have (even cached)
      if (_position != null) {
        try {
          await _usePosition(_position!);
        } catch (_) {}
      }
      _scheduleMidnightRefresh();
    });
  }

  Future<void> _refreshManually() async {
    setState(() => _loading = true);
    try {
      final pos = await _determinePosition();
      await _usePosition(pos);
    } catch (e) {
      // fallback to cached
      await _loadWithFallbacks();
    } finally {
      setState(() => _loading = false);
    }
  }

  // UI & helpers
  String _format(DateTime dt) => DateFormat.jm().format(dt);

  Widget _buildTopCard(BuildContext c) {
    final next = _nextPrayer();
    final locationText = _position == null
        ? 'Unknown'
        : '${_position!.latitude.toStringAsFixed(3)}, ${_position!.longitude.toStringAsFixed(3)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(locationText, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 10),
                  if (next != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Next: ${next.key}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('${_format(next.value)} — ${_countdownText(next.value)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                      ],
                    )
                  else
                    Text('No upcoming prayers today', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _refreshManually,
              style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(12)),
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  String _countdownText(DateTime dt) {
    final d = dt.difference(DateTime.now());
    if (d.isNegative) return 'Now';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  Widget _buildPrayerList() {
    final map = _prayerMap();
    if (map.isEmpty) return const SizedBox();

    final entries = map.entries.toList();
    return Column(
      children: entries.map((e) {
        final isNext = _nextPrayer()?.key == e.key;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isNext ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.04),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.08), child: Text(e.key[0])),
            title: Text(e.key, style: const TextStyle(color: Colors.white)),
            subtitle: isNext ? Text('Next — ${_countdownText(e.value)}', style: const TextStyle(color: Colors.white70)) : null,
            trailing: Text(_format(e.value), style: const TextStyle(color: Colors.white)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [Text('Settings', style: Theme.of(context).textTheme.titleLarge)]),
          const SizedBox(height: 12),
          Row(children: [Text('Calculation Method: ')]),
          const SizedBox(height: 6),
          DropdownButton<int>(
            isExpanded: true,
            value: CalculationMethod.values.indexWhere((m) => identical(m.getParameters(), _calcParams) || m == _methodFromParams(_calcParams)),
            onChanged: (idx) async {
              if (idx == null) return;
              final method = CalculationMethod.values[idx];
              setState(() {
                _calcParams = method.getParameters();
                _calcParams.madhab = _madhab;
              });
              _prefs.setInt(_prefsKeyMethod, idx);
              await _refreshAfterSettings();
            },
            items: CalculationMethod.values.map((m) => DropdownMenuItem(value: CalculationMethod.values.indexOf(m), child: Text(_calcMethodName(m)))).toList(),
          ),
          const SizedBox(height: 8),
          Row(children: [Text('Madhab: ')]),
          const SizedBox(height: 6),
          DropdownButton<int>(
            value: Madhab.values.indexOf(_madhab),
            onChanged: (idx) async {
              if (idx == null) return;
              setState(() {
                _madhab = Madhab.values[idx];
                _calcParams.madhab = _madhab;
              });
              _prefs.setInt(_prefsKeyMadhab, idx);
              await _refreshAfterSettings();
            },
            items: Madhab.values.map((m) => DropdownMenuItem(value: Madhab.values.indexOf(m), child: Text(m == Madhab.hanafi ? 'Hanafi' : 'Shafi'))).toList(),
          ),
          const SizedBox(height: 8),
          Row(children: [Text('Manual offset (minutes): '), const SizedBox(width: 8), Expanded(child: TextFormField(initialValue: _manualOffsetMinutes.toString(), keyboardType: TextInputType.number, onFieldSubmitted: (v) async { final parsed = int.tryParse(v) ?? 0; setState(() => _manualOffsetMinutes = parsed); _prefs.setInt(_prefsKeyOffset, parsed); await _refreshAfterSettings(); }))]),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.check), label: const Text('Done'))
        ],
      ),
    );
  }

  CalculationMethod _methodFromParams(CalculationParameters params) {
    for (final m in CalculationMethod.values) {
      final p = m.getParameters();
      final fajrA = (p.fajrAngle ?? 0) - (params.fajrAngle ?? 0);
      final ishaA = (p.ishaAngle ?? 0) - (params.ishaAngle ?? 0);
      if (fajrA.abs() < 0.01 && ishaA.abs() < 0.01)
        return m;
    }
    return CalculationMethod.muslim_world_league;
  }

  String _calcMethodName(CalculationMethod m) {
    switch (m) {
      case CalculationMethod.muslim_world_league:
        return 'Muslim World League';
      case CalculationMethod.egyptian:
        return 'Egyptian';
      case CalculationMethod.karachi:
        return 'Karachi';
      case CalculationMethod.umm_al_qura:
        return 'Umm al-Qura';
      case CalculationMethod.dubai:
        return 'Dubai';
      case CalculationMethod.moon_sighting_committee:
        return 'Moon Sighting Committee';
      case CalculationMethod.north_america:
        return 'North America (ISNA)';
      default:
        return m.name;
    }
  }

  Future<void> _refreshAfterSettings() async {
    setState(() => _loading = true);
    if (_position != null) {
      try {
        await _usePosition(_position!);
      } catch (_) {
        await _loadWithFallbacks();
      }
    } else {
      await _loadWithFallbacks();
    }
    setState(() => _loading = false);
  }

  Future<void> _selectFallbackCity() async {
    final pick = await showModalBottomSheet<int>(context: context, builder: (ctx) {
      return SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (var i = 0; i < _fallbackCities.length; i++) ListTile(title: Text(_fallbackCities[i]['name']), onTap: () => Navigator.of(ctx).pop(i)),
        ]),
      );
    });

    if (pick != null) {
      final f = _fallbackCities[pick];
      final coords = Coordinates(f['lat'] as double, f['lon'] as double);
      final times = PrayerTimes(coords, DateComponents.from(DateTime.now()), _calcParams);
      // save coords
      _prefs.setDouble(_prefsKeyLat, f['lat'] as double);
      _prefs.setDouble(_prefsKeyLon, f['lon'] as double);
      _prefs.setString(_prefsKeyTimes, jsonEncode(_prayerTimesToJson(times)));
      setState(() {
        _position = Position(latitude: f['lat'] as double, longitude: f['lon'] as double, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
        _prayerTimes = times;
        _error = 'Using ${f['name']}';
      });
    }
  }

  Widget _buildServiceCard(IconData icon, String title, Color color, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => IhramTutorialPage()));
        }
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HajjTutorialPage()));
        }
        if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UmrahTutorialPage()));
        }
        if (index == 3) {

          Navigator.push(context, MaterialPageRoute(builder: (context) => DelegationPage()));
        }
        if (index == 4) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LostPage()));
        }
        if (index == 5) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MedicinePage()));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color.withOpacity(0.4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // premium gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF150F2A), Color(0xFFE2DFE7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Salat', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Accurate • Offline-first • Premium UI', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                  ]),
                  Row(children: [
                    IconButton(onPressed: () => showModalBottomSheet(context: context, builder: (_) => _buildSettingsSheet()), icon: const Icon(Icons.settings, color: Colors.white)),
                    IconButton(onPressed: _selectFallbackCity, icon: const Icon(Icons.map, color: Colors.white)),
                  ])
                ]),
                const SizedBox(height: 12),
                if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())) else Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(_error!, style: const TextStyle(color: Colors.amberAccent)),
                          ),

                        _buildTopCard(context),
                        const SizedBox(height: 8),
                        _buildPrayerList(),
                        const SizedBox(height: 20),

                        // 🌙 Islamic Services Section
                        Text(
                          'More Services',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: [
                            _buildServiceCard(Icons.hail, 'Hajj & Umrah Guide', Colors.brown.shade400, 0),
                            _buildServiceCard(Icons.medication, 'Medicine Reminder', Colors.teal.shade400, 1),
                            _buildServiceCard(Icons.menu_book, 'Daily Quran Verse', Colors.indigo.shade400, 2),
                            _buildServiceCard(Icons.headphones, 'Islamic Lectures', Colors.deepPurple.shade400, 3),
                            _buildServiceCard(Icons.favorite, 'Duas & Supplications', Colors.pink.shade400, 4),
                            _buildServiceCard(Icons.calendar_today, 'Hijri Calendar', Colors.green.shade400, 5),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Text(
                          'Now: ${DateFormat.yMMMd().add_jm().format(_now)}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
    );
  }
}
