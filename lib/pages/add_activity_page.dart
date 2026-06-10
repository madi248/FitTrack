import 'package:flutter/material.dart';
import '../models/activity_log.dart';

class AddActivityPage extends StatefulWidget {
  final VoidCallback onBack;
  final String? selectedActivity;
  final Function(ActivityLog) onAddActivity;

  const AddActivityPage({
    super.key,
    required this.onBack,
    this.selectedActivity,
    required this.onAddActivity,
  });

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  static const Map<ActivityType, int> caloriesPerMinute = {
    ActivityType.walking: 5,
    ActivityType.running: 10,
    ActivityType.cycling: 8,
  };

  late ActivityType _activityType;
  int _duration = 15;
  final List<int> _timePresets = [5, 10, 15, 20, 30, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    _activityType = widget.selectedActivity == 'walking'
        ? ActivityType.walking
        : widget.selectedActivity == 'running'
            ? ActivityType.running
            : ActivityType.cycling;
  }

  int get _caloriesBurned => _duration * caloriesPerMinute[_activityType]!;

  String get _activityName {
    switch (_activityType) {
      case ActivityType.walking:
        return 'Walking';
      case ActivityType.running:
        return 'Running';
      case ActivityType.cycling:
        return 'Cycling';
    }
  }

  String get _activityEmoji {
    switch (_activityType) {
      case ActivityType.walking:
        return '🚶';
      case ActivityType.running:
        return '🏃';
      case ActivityType.cycling:
        return '🚴';
    }
  }

  void _handleLogActivity() {
    widget.onAddActivity(ActivityLog(
      type: _activityType,
      duration: _duration,
      caloriesBurned: _caloriesBurned,
      timestamp: DateTime.now(),
    ));
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF475569)),
                    onPressed: widget.onBack,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Log $_activityName',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${caloriesPerMinute[_activityType]} cal/min',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Activity Icon
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _activityEmoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _activityName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How long did you exercise?',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Duration Input
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Duration (minutes)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    _duration = (_duration > 1) ? _duration - 1 : 1;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 96,
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(text: _duration.toString())
                                    ..selection = TextSelection.collapsed(offset: _duration.toString().length),
                                  onChanged: (value) {
                                    final duration = int.tryParse(value) ?? 1;
                                    setState(() {
                                      _duration = duration > 0 ? duration : 1;
                                    });
                                  },
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _duration++;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Time Presets
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _timePresets.map((preset) {
                              final isSelected = _duration == preset;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _duration = preset;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(
                                            colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                                          )
                                        : null,
                                    color: isSelected ? null : Colors.white.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    '$preset min',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF475569),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Calories Preview
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_fire_department, color: Color(0xFF14B8A6), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Calories Burned',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                            ).createShader(bounds),
                            child: Text(
                              '$_caloriesBurned',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_duration ${_duration == 1 ? 'minute' : 'minutes'} × ${caloriesPerMinute[_activityType]} cal/min',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tip
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF3B82F6), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tip: These calorie estimates are based on moderate intensity exercise. Actual calories burned may vary based on your weight, intensity, and fitness level.',
                              style: TextStyle(color: Colors.blue[900], fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Log Activity Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: _handleLogActivity,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Log $_duration ${_duration == 1 ? 'Minute' : 'Minutes'} ($_caloriesBurned cal)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
