import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/shared_pref.dart';
import '../../data/models/alarm.dart';
import '../../data/services/firebase_service.dart';
import '../../l10n/app_localizations.dart';
import '../helpers/ui_functions.dart';

import 'menu.dart';


class MedicineAlarmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MedicinePage(),
    );
  }
}

class MedicinePage extends StatefulWidget {
  @override
  _MedicinePageState createState() => _MedicinePageState();
}
class _MedicinePageState extends State<MedicinePage> {
  PageController _pageController = PageController();

  List<Alarm> alarms = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    loadData();
  }

  Future<void> loadData() async {
    await SharedPref().getAlarms().then((loadedAlarms) {
      setState(() {
        alarms = loadedAlarms;
      });
    });
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAddAlarmDialog() async {
    final newAlarm = await showModalBottomSheet<Alarm>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddAlarmPage(
        onSave: (alarm) {
          Navigator.pop(context, alarm); // send Alarm object back
        },
      ),
    );
    if (newAlarm != null) {
      setState(() {
        alarms.add(newAlarm);
      });
      await SharedPref().saveAlarms(alarms);
      await UpdateFirebase().UploadAlarmToFirebase(newAlarm);
      await SharedPref().getAlarms();
    }
  }

  void _showDeleteAlarmDialog() {
    List<int> selectedIndexes = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.delete_alarms),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: alarms.asMap().entries.map((entry) {
                    int index = entry.key;
                    Alarm alarm = entry.value;
                    bool isSelected = selectedIndexes.contains(index);

                    return ListTile(
                      onTap: () {
                        setDialogState(() {
                          if (isSelected) {
                            selectedIndexes.remove(index);
                          } else {
                            selectedIndexes.add(index);
                          }
                        });
                      },
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (_) {
                          setDialogState(() {
                            if (isSelected) {
                              selectedIndexes.remove(index);
                            } else {
                              selectedIndexes.add(index);
                            }
                          });
                        },
                      ),
                      title: Text(
                        alarm.times.isNotEmpty
                            ? alarm.times.join(', ')
                            : AppLocalizations.of(context)!.no_time_set,
                      ),
                      subtitle: Text(alarm.medicineName ?? AppLocalizations.of(context)!.no_med_name),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                TextButton(
                  onPressed: selectedIndexes.isNotEmpty
                      ? () {
                    setState(() async {
                      selectedIndexes.sort((a, b) => b.compareTo(a));
                      for (int index in selectedIndexes) {
                        await UpdateFirebase().deleteAlarmFromFirebase(alarms[index].id);
                        alarms.removeAt(index);
                      }
                      await SharedPref().saveAlarms(alarms);
                    });
                    Navigator.pop(context);
                  }
                      : null,
                  child: Text(AppLocalizations.of(context)!.delete_selected),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.medicine),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.deepPurple,),
            onPressed: _showDeleteAlarmDialog,
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swiped Left -> Go to HomePage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuPage()),
            );
          } else if (details.primaryVelocity! > 0) {
            // Optional: Swiped Right -> Do something else or nothing
          }
        },
        child: ListView.builder(
          itemCount: alarms.length,
          itemBuilder: (context, index) {
            return ExpandableAlarmCard(alarm: alarms[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAlarmDialog,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
    );
  }
}

class ExpandableAlarmCard extends StatefulWidget {
  final Alarm alarm;

  ExpandableAlarmCard({required this.alarm});

  @override
  _ExpandableAlarmCardState createState() => _ExpandableAlarmCardState();
}
class _ExpandableAlarmCardState extends State<ExpandableAlarmCard> {
  bool _isExpanded = false;
  static List<String> days(BuildContext context) => [
    AppLocalizations.of(context)!.day_mon,
    AppLocalizations.of(context)!.day_tue,
    AppLocalizations.of(context)!.day_wed,
    AppLocalizations.of(context)!.day_thu,
    AppLocalizations.of(context)!.day_fri,
    AppLocalizations.of(context)!.day_sat,
    AppLocalizations.of(context)!.day_sun,
  ];



  DateTime? getNextAlarmTime(List<String> times) {
    final now = DateTime.now();
    List<DateTime> todayTimes = times.map((t) {
      final parts = t.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(now.year, now.month, now.day, hour, minute);
    }).toList();

    todayTimes.sort();
    for (final time in todayTimes) {
      if (time.isAfter(now)) return time;
    }
    return todayTimes.isNotEmpty ? todayTimes.first.add(Duration(days: 1)) : null;
  }

  String timeUntil(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours > 0) {
      return AppLocalizations.of(context)!.in_hours_and_minutes(hours, minutes);
    } else {
      return AppLocalizations.of(context)!.in_minutes(minutes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> days = [
      AppLocalizations.of(context)!.day_mon,
      AppLocalizations.of(context)!.day_tue,
      AppLocalizations.of(context)!.day_wed,
      AppLocalizations.of(context)!.day_thu,
      AppLocalizations.of(context)!.day_fri,
      AppLocalizations.of(context)!.day_sat,
      AppLocalizations.of(context)!.day_sun,];
    final alarm = widget.alarm;
    final nextTime = getNextAlarmTime(alarm.times);
    final nextTimeFormatted = nextTime != null
        ? DateFormat.jm().format(nextTime)
        : AppLocalizations.of(context)!.no_time_set;
    final timeRemaining = nextTime != null ? timeUntil(nextTime) : '';

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            nextTimeFormatted,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              alarm.medicineName ?? AppLocalizations.of(context)!.no_med_name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      if (timeRemaining.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                          AppLocalizations.of(context)!.alarm_remaining(timeRemaining),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: alarm.enabled ?? false,
                  onChanged: (val) {
                    setState(() {
                      alarm.enabled = val;
                    });
                  },
                ),
              ],
            ),

            if(_isExpanded) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 3,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                runSpacing: 12,
                children: [

                  _infoTile(Icons.repeat_rounded, AppLocalizations.of(context)!.repeat, widget.alarm.repeatDays),

                  if (widget.alarm.importance?.isNotEmpty ?? false)
                    _infoTile(Icons.priority_high_rounded, AppLocalizations.of(context)!.importance, widget.alarm.importance!),

                  if (widget.alarm.dosage?.isNotEmpty ?? false)
                    _infoTile(Icons.medication_outlined, AppLocalizations.of(context)!.dosage, widget.alarm.dosage!),

                  if (widget.alarm.whenToTake?.isNotEmpty ?? false)
                    _infoTile(Icons.access_time_rounded, AppLocalizations.of(context)!.when, widget.alarm.whenToTake!),

                  if (widget.alarm.purpose?.isNotEmpty ?? false)
                    _infoTile(Icons.favorite_outline, AppLocalizations.of(context)!.purpose, widget.alarm.purpose!),

                  if (widget.alarm.notes?.isNotEmpty ?? false)
                    _infoTile(Icons.notes_rounded, AppLocalizations.of(context)!.notes, widget.alarm.notes!),

                  if (widget.alarm.doctor?.isNotEmpty ?? false)
                    _infoTile(Icons.person_outline, AppLocalizations.of(context)!.doctor, widget.alarm.doctor!),

                  if (widget.alarm.timesPerDay > 1 && widget.alarm.times.length > 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context)!.other_times, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: widget.alarm.times
                              .skip(1) // skip the first one that's already shown
                              .map((time) => Chip(
                            label: Text(time),
                            backgroundColor: Colors.deepPurple.shade800.withOpacity(0.1),
                            labelStyle: const TextStyle(color: Colors.black87),
                          ))
                              .toList(),
                        ),
                      ],
                    ),

                  if (widget.alarm.repeatDays == AppLocalizations.of(context)!.custom &&
                      widget.alarm.selectedDays.any((day) => day))
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: List.generate(7, (index) {
                          if (!widget.alarm.selectedDays[index]) return const SizedBox.shrink();
                          return Chip(
                            label: Text(days[index]),
                            backgroundColor: Colors.deepPurple.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: Colors.deepPurple.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.deepPurple.shade100),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ],
            if (!_isExpanded) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 3,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAlarmPageState extends State<AddAlarmPage> {
  String medicineName='';
  String? dosage, purpose, notes, doctor, whenToTake, importance;
  int timesPerDay = 1;
  List<bool> selectedDays = List.filled(7, false);
  bool advanced = false;

  TimeOfDay selectedTime = TimeOfDay.now();
  List<TimeOfDay> timesList = [TimeOfDay(hour: 8, minute: 0)];


  PageController _pageController = PageController();



  void _syncTimesList() {
    if (timesPerDay <= 1) {
      timesList = [selectedTime];
    } else {
      while (timesList.length < timesPerDay) {
        timesList.add(TimeOfDay(hour: 8, minute: 0));
      }
      while (timesList.length > timesPerDay) {
        timesList.removeLast();
      }
    }
  }

  Widget _buildAdvancedPage(ScrollController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: controller,  // Pass the controller here
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.dosage_hint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    dosage = value;
                  },
                ),
                const SizedBox(height: 16),

                /// Timing Instruction
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.when_hint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    AppLocalizations.of(context)!.before_food,
                    AppLocalizations.of(context)!.after_food,
                    AppLocalizations.of(context)!.with_food,
                    AppLocalizations.of(context)!.empty_stomach,
                  ]
                      .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                      .toList(),
                  onChanged: (value) {
                    whenToTake = value;
                  },
                ),
                const SizedBox(height: 16),

                /// Purpose of Medicine
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.purpose_hint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    purpose = value;
                  },
                ),
                const SizedBox(height: 16),

                /// Urgency
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.importance,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [
                    AppLocalizations.of(context)!.optional,
                    AppLocalizations.of(context)!.important,
                    AppLocalizations.of(context)!.must_not_miss,]
                      .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                      .toList(),
                  onChanged: (value) {
                    importance = value;
                  },
                ),
                const SizedBox(height: 16),

                /// Extra Notes
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.notes_hint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    notes = value;
                  },
                ),
                const SizedBox(height: 16),

                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.doctor_hint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    doctor = value;
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            onTap: () {
              _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              Future.delayed(const Duration(milliseconds: 350), () {
                setState(() {
                  advanced = false;
                });
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildMainPage(ScrollController controller) {
    String repeatDays=AppLocalizations.of(context)!.once;
    final List<String> days = [
      AppLocalizations.of(context)!.day_mon,
      AppLocalizations.of(context)!.day_tue,
      AppLocalizations.of(context)!.day_wed,
      AppLocalizations.of(context)!.day_thu,
      AppLocalizations.of(context)!.day_fri,
      AppLocalizations.of(context)!.day_sat,
      AppLocalizations.of(context)!.day_sun,];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: controller,  // Pass the controller here too
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                if (timesPerDay == 1) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SizedBox(
                      height: 200,
                      child: CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.hm,
                        initialTimerDuration: Duration(
                          hours: selectedTime.hour,
                          minutes: selectedTime.minute,
                        ),
                        onTimerDurationChanged: (Duration newTime) {
                          setState(() {
                            selectedTime = TimeOfDay(
                              hour: newTime.inHours,
                              minute: newTime.inMinutes % 60,
                            );
                            timesList = [selectedTime];  // keep timesList synced
                          });
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  ...List.generate(timesPerDay, (index) {
                    final time = timesList[index];
                    return ListTile(
                      title: Text(AppLocalizations.of(context)!.select_time(index + 1)),
                      subtitle: Text(time.format(context)),
                      trailing: const Icon(Icons.edit),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (BuildContext context) {
                            TimeOfDay tempTime = timesList[index]; // local variable now inside the builder
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(AppLocalizations.of(context)!.select_time(index + 1),
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () => Navigator.pop(context),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.check),
                                                  onPressed: () {
                                                    setState(() {
                                                      timesList[index] = tempTime;
                                                    });
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Divider(),

                                      SizedBox(
                                        height: 200,
                                        child: CupertinoTimerPicker(
                                          mode: CupertinoTimerPickerMode.hm,
                                          initialTimerDuration: Duration(
                                            hours: tempTime.hour,
                                            minutes: tempTime.minute,
                                          ),
                                          onTimerDurationChanged: (Duration newTime) {
                                            setModalState(() {
                                              tempTime = TimeOfDay(
                                                hour: newTime.inHours,
                                                minute: newTime.inMinutes % 60,
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  }),
                ],

                const SizedBox(height: 24),

                // Repeat Selector
                DropdownButtonFormField<String>(
                  value: repeatDays,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.repeat,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: [AppLocalizations.of(context)!.repeat_once,
                    AppLocalizations.of(context)!.repeat_daily,
                    AppLocalizations.of(context)!.repeat_custom,].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      repeatDays = newValue!;
                      if (repeatDays == 'Daily') {
                        selectedDays = List.filled(7, true);
                        selectedDays = List.filled(7, true);
                      } else if (repeatDays == 'Custom') {
                        // no change here, but you can keep selectedDays as is
                      } else {
                        selectedDays = List.filled(7, false);
                        selectedDays = List.filled(7, false);
                      }
                    });
                  },
                ),

                if (repeatDays == 'Custom') ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(7, (index) {
                      final bool isSelected = selectedDays[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDays[index] = !selectedDays[index];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.deepPurple.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            days[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.deepPurple.shade700 : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],

                const SizedBox(height: 24),

                DropdownButtonFormField<int>(
                  value: timesPerDay,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.times_per_day,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: List.generate(6, (index) => index + 1).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      timesPerDay = newValue!;
                      _syncTimesList();  // Sync list when user changes timesPerDay
                    });
                  },
                ),
                const SizedBox(height: 24),

              ],
            ),
          ),
        ),

        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  advanced = true;
                });
                Future.delayed(const Duration(milliseconds: 50), () {
                  _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                });
              },
              child: Text(
                AppLocalizations.of(context)!.btn_advanced,
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildSharedHeader() {
    String repeatDays=AppLocalizations.of(context)!.once;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.med_name,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.deepPurple.shade400),
                  ),
                ),
                onChanged: (value) => medicineName = value,
              ),
            ),
            IconButton(
                icon: Icon(Icons.check_circle_rounded, color: Colors.deepPurple.shade400, size: 28),
                onPressed: () async {
                  final uuid = Uuid();
                  String alarmId = uuid.v4();
                  Alarm newAlarm = Alarm(id: alarmId);
                  newAlarm.medicineName = medicineName;
                  newAlarm.timesPerDay = timesPerDay;
                  newAlarm.repeatDays = repeatDays;
                  newAlarm.advanced = advanced;
                  newAlarm.enabled = true;
                  newAlarm.times = timesList.map((e) => e.format(context)).toList();
                  if(advanced){
                    newAlarm.purpose = purpose;
                    newAlarm.notes = notes;
                    newAlarm.dosage = dosage;
                    newAlarm.whenToTake = whenToTake;
                    newAlarm.doctor = doctor;
                    newAlarm.importance = importance;
                  }
                  Navigator.pop(context, newAlarm);
                }),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildSharedHeader(),
              const SizedBox(height: 24),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: advanced
                      ? const PageScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  children: [
                    _buildMainPage(scrollController),  // pass controller
                    Visibility(
                      visible: advanced,
                      maintainState: true,
                      maintainAnimation: true,
                      child: _buildAdvancedPage(scrollController),  // pass controller
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
class AddAlarmPage extends StatefulWidget {
  final Function(Alarm) onSave;

  AddAlarmPage({required this.onSave});

  @override
  _AddAlarmPageState createState() => _AddAlarmPageState();
}

