import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/bottom_nav.dart';

class StopwatchPage extends StatefulWidget {
  final Function(String) navigateTo;

  const StopwatchPage({super.key, required this.navigateTo});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  int _time = 0;
  bool _isRunning = false;
  List<int> _laps = [];
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPause() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {
          _time += 10;
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _reset() {
    setState(() {
      _time = 0;
      _isRunning = false;
      _laps = [];
    });
    _timer?.cancel();
  }

  void _lap() {
    if (_isRunning) {
      setState(() {
        _laps.insert(0, _time);
      });
    }
  }

  Map<String, String> _formatTime(int milliseconds) {
    final totalSeconds = milliseconds ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final ms = (milliseconds % 1000) ~/ 10;

    return {
      'minutes': minutes.toString().padLeft(2, '0'),
      'seconds': seconds.toString().padLeft(2, '0'),
      'milliseconds': ms.toString().padLeft(2, '0'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(_time);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  'Stopwatch',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Timer Display
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            time['minutes']!,
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Text(
                            ':',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            time['seconds']!,
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Text(
                            '.',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            time['milliseconds']!,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Control Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _startPause,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: _isRunning
                                  ? const Color(0xFFEA580C)
                                  : const Color(0xFF14B8A6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isRunning ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isRunning ? 'Pause' : 'Start',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _reset,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, color: Color(0xFF475569)),
                                SizedBox(width: 8),
                                Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_isRunning) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _lap,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF3B82F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Record Lap',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (_laps.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Laps',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: _laps.asMap().entries.map((entry) {
                            final lapTime = _formatTime(entry.value);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Lap ${_laps.length - entry.key}',
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${lapTime['minutes']}:${lapTime['seconds']}.${lapTime['milliseconds']}',
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    if (!_isRunning && _laps.isEmpty && _time == 0) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: const Center(
                          child: Text(
                            'Press Start to begin timing your workout or activity',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentPage: 'stopwatch',
        onNavigate: widget.navigateTo,
      ),
    );
  }
}
