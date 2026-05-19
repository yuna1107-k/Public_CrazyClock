import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:ui';
import 'Clock.dart';
import 'setting.dart';

class AppSize {
  static double scale(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return (width / 390).clamp(0.8, 1.3);
  }

  static double title(BuildContext context) => 32 * scale(context);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en', null);
  await ClockSettings.instance.load();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const NavigationScreen(),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});
  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  bool _isStopwatchRunning = false;
  @override
  void initState() {
    super.initState();
    ClockSettings.instance.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() => setState(() {});

  void _showLockedDialog(BuildContext context) {
    final double s = AppSize.scale(context);
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24 * s),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
          title: Icon(
            Icons.lock_outline,
            color: Colors.redAccent,
            size: 40 * s,
          ),
          content: Text(
            "Stopwatch is running.\nStop it to switch pages.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16 * s,
              fontWeight: FontWeight.w300,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [ClockPage(), SettingsPage()],
            ),
          ),
          _buildCustomBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCustomBottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
        height: 72,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.access_time_rounded, 0),
                  _buildNavItem(Icons.settings, 1),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowLayer() {
    final double screenWidth = MediaQuery.of(context).size.width - 48;
    final double tabWidth = screenWidth / 3;
    final double offset = (tabWidth * _selectedIndex) + (tabWidth / 2) - 30;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      left: offset,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (_isStopwatchRunning && _selectedIndex != index) {
          _showLockedDialog(context);
          return;
        }
        setState(() => _selectedIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        height: 60,
        child: Icon(
          icon,
          color: isSelected ? Colors.blueAccent : Colors.white38,
          size: 28,
        ),
      ),
    );
  }
}
