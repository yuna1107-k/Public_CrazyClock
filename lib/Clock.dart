import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'setting.dart';

class ClockPage extends StatefulWidget {
  static const int realHoursPerDay = 24;
  static const int realMinutesPerHour = 60;
  static const int realSecondsPerMinute = 60;

  static int get hoursPerDay => ClockSettings.instance.hoursPerDay;
  static int get minutesPerHour => ClockSettings.instance.minutesPerHour;
  static int get secondsPerMinute => ClockSettings.instance.secondsPerMinute;
  static const int millisecondsPerSecond = 1000;
  static int get analogHourDivisions => hoursPerDay ~/ 2;

  static int get minutesPerDay => hoursPerDay * minutesPerHour;
  static int get secondsPerDay => minutesPerDay * secondsPerMinute;

  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _CustomClockTime {
  final double elapsedSeconds;
  final int hour;
  final int minute;
  final int second;
  final int millisecond;

  const _CustomClockTime({
    required this.elapsedSeconds,
    required this.hour,
    required this.minute,
    required this.second,
    required this.millisecond,
  });

  double get secondProgress => elapsedSeconds % ClockPage.secondsPerMinute;
  double get minuteProgress => minute.toDouble();
  double get hourProgress => (hour % ClockPage.analogHourDivisions).toDouble();
}

class _ClockPageState extends State<ClockPage>
    with SingleTickerProviderStateMixin {
  late DateTime _now;
  Timer? _timer;

  late AnimationController _rippleController;
  Offset _tapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details, double clockSize) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPos = renderBox.globalToLocal(details.globalPosition);
    _tapPosition =
        localPos -
        Offset(renderBox.size.width / 2, (renderBox.size.height - 120) / 2);

    HapticFeedback.vibrate();
    _rippleController.forward(from: 0.0);
  }

  _CustomClockTime _calculateCustomClockTime(DateTime now) {
    const double realSecondsPerDay =
        ClockPage.realHoursPerDay *
        ClockPage.realMinutesPerHour *
        ClockPage.realSecondsPerMinute *
        1.0;
    final double realElapsedSeconds =
        now.hour *
            ClockPage.realMinutesPerHour *
            ClockPage.realSecondsPerMinute +
        now.minute * ClockPage.realSecondsPerMinute +
        now.second +
        (now.millisecond / ClockPage.millisecondsPerSecond);

    final double dayProgress = realElapsedSeconds / realSecondsPerDay;
    final double mappedElapsedSeconds = dayProgress * ClockPage.secondsPerDay;

    final int flooredElapsedSeconds = mappedElapsedSeconds.floor();
    final int secondsInCustomHour =
        ClockPage.minutesPerHour * ClockPage.secondsPerMinute;
    final int hour = flooredElapsedSeconds ~/ secondsInCustomHour;
    final int minute =
        (flooredElapsedSeconds % secondsInCustomHour) ~/
        ClockPage.secondsPerMinute;
    final int second = flooredElapsedSeconds % ClockPage.secondsPerMinute;
    final double fractional = mappedElapsedSeconds - flooredElapsedSeconds;
    final int millisecond = (fractional * ClockPage.millisecondsPerSecond)
        .floor();

    return _CustomClockTime(
      elapsedSeconds: mappedElapsedSeconds,
      hour: hour,
      minute: minute,
      second: second,
      millisecond: millisecond,
    );
  }

  String _formatDigitalTime(_CustomClockTime time) {
    final int hourDigits = ClockPage.hoursPerDay.toString().length;
    final String hh = time.hour.toString().padLeft(hourDigits, '0');
    final String mm = time.minute.toString().padLeft(2, '0');
    final String ss = time.second.toString().padLeft(2, '0');
    // Show milliseconds as two digits (centiseconds)
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    const double navBarAreaHeight = 120.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final _CustomClockTime customTime = _calculateCustomClockTime(_now);
        double clockSize =
            min(constraints.maxWidth, constraints.maxHeight) * 0.75;
        clockSize = clockSize.clamp(230.0, 480.0);

        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.only(bottom: navBarAreaHeight),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTapDown: (details) => _handleTap(details, clockSize),
                  child: Container(
                    width: clockSize,
                    height: clockSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.15),
                          blurRadius: 60,
                          spreadRadius: -10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(clockSize / 2),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.05,
                              colors: [
                                Colors.blueAccent.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 0.8,
                            ),
                          ),
                          child: AnimatedBuilder(
                            animation: _rippleController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: LiquidClockPainter(
                                  customTime: customTime,
                                  rippleAnimation: _rippleController.value,
                                  tapPosition: _tapPosition,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: clockSize * 0.12),

                Text(
                  DateFormat('yyyy/MM/dd E', 'en').format(_now),
                  style: TextStyle(
                    fontSize: (screenWidth * 0.05).clamp(16, 22),
                    fontWeight: FontWeight.w200,
                    color: Colors.white54,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  _formatDigitalTime(customTime),
                  style: TextStyle(
                    fontSize: (screenWidth * 0.22).clamp(64, 100),
                    fontWeight: FontWeight.w100,
                    letterSpacing: -5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LiquidClockPainter extends CustomPainter {
  final _CustomClockTime customTime;
  final double rippleAnimation;
  final Offset tapPosition;

  LiquidClockPainter({
    required this.customTime,
    required this.rippleAnimation,
    required this.tapPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final Paint centerGlow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.blueAccent.withValues(alpha: 0.1), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.4))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius * 0.3, centerGlow);

    if (rippleAnimation > 0 && rippleAnimation < 1.0) {
      final double rippleRadius = radius * 1.2 * rippleAnimation;
      final double rippleOpacity = (1.0 - rippleAnimation).clamp(0.0, 0.2);
      final Paint ripplePaint = Paint()
        ..color = Colors.blueAccent.withValues(alpha: rippleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(tapPosition + center, rippleRadius, ripplePaint);
    }

    void drawGlowingLine(Offset p1, Offset p2, Paint paint, Color glowColor) {
      final shadowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.4)
        ..strokeWidth = paint.strokeWidth * 2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawLine(p1, p2, shadowPaint);
      canvas.drawLine(p1, p2, paint);
    }

    final hourPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final minutePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final secondPaint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const double fullCircleDegrees = 360;
    final double secondStepDegree =
        fullCircleDegrees / ClockPage.secondsPerMinute;
    final double minuteStepDegree =
        fullCircleDegrees / ClockPage.minutesPerHour;
    final double hourStepDegree =
        fullCircleDegrees / ClockPage.analogHourDivisions;

    final double secAngle =
        customTime.secondProgress * secondStepDegree * pi / 180;
    final double minAngle =
        customTime.minuteProgress * minuteStepDegree * pi / 180;
    final double hourAngle =
        customTime.hourProgress * hourStepDegree * pi / 180;

    drawGlowingLine(
      center,
      _getOffset(center, radius * 0.5, hourAngle),
      hourPaint,
      Colors.white,
    );
    drawGlowingLine(
      center,
      _getOffset(center, radius * 0.75, minAngle),
      minutePaint,
      Colors.white,
    );
    drawGlowingLine(
      center,
      _getOffset(center, radius * 0.88, secAngle),
      secondPaint,
      Colors.blueAccent,
    );

    canvas.drawCircle(center, 2, Paint()..color = Colors.white);
    canvas.drawCircle(center, 1, Paint()..color = Colors.blueAccent);

    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.2;
    for (var i = 0; i < ClockPage.analogHourDivisions; i++) {
      final double angle = i * hourStepDegree * pi / 180;
      canvas.drawLine(
        _getOffset(center, radius * 0.9, angle),
        _getOffset(center, radius * 0.96, angle),
        tickPaint,
      );
    }
  }

  Offset _getOffset(Offset center, double radius, double angle) {
    return Offset(
      center.dx + radius * sin(angle),
      center.dy - radius * cos(angle),
    );
  }

  @override
  bool shouldRepaint(covariant LiquidClockPainter oldDelegate) => true;
}
