import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClockSettings extends ChangeNotifier {
  static final ClockSettings instance = ClockSettings._internal();
  ClockSettings._internal();

  int hoursPerDay = 24;
  int minutesPerHour = 60;
  int secondsPerMinute = 60;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    hoursPerDay = prefs.getInt('hoursPerDay') ?? 24;
    minutesPerHour = prefs.getInt('minutesPerHour') ?? 60;
    secondsPerMinute = prefs.getInt('secondsPerMinute') ?? 60;
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hoursPerDay', hoursPerDay);
    await prefs.setInt('minutesPerHour', minutesPerHour);
    await prefs.setInt('secondsPerMinute', secondsPerMinute);
  }

  Future<void> update({
    required int hours,
    required int minutes,
    required int seconds,
  }) async {
    hoursPerDay = hours;
    minutesPerHour = minutes;
    secondsPerMinute = seconds;
    await save();
    notifyListeners();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    final s = ClockSettings.instance;
    _hoursController = TextEditingController(text: s.hoursPerDay.toString());
    _minutesController = TextEditingController(
      text: s.minutesPerHour.toString(),
    );
    _secondsController = TextEditingController(
      text: s.secondsPerMinute.toString(),
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final int h = int.parse(_hoursController.text);
    final int m = int.parse(_minutesController.text);
    final int s = int.parse(_secondsController.text);
    await ClockSettings.instance.update(hours: h, minutes: m, seconds: s);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hours per day'),
              TextFormField(
                controller: _hoursController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter hours';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Invalid hours';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text('Minutes per hour'),
              TextFormField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter minutes';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Invalid minutes';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text('Seconds per minute'),
              TextFormField(
                controller: _secondsController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter seconds';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Invalid seconds';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      _hoursController.text = '24';
                      _minutesController.text = '60';
                      _secondsController.text = '60';
                    },
                    child: const Text('Reset to default'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
