import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/activity_log.dart';
import 'add_activity_page.dart';
import '../widgets/bottom_nav.dart';

class ActivityPage extends StatefulWidget {
  final Function(String, {String? meal, String? activity}) navigateTo;

  const ActivityPage({super.key, required this.navigateTo});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Request permissions on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).requestHealthPermissions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, _) {
            final caloriesBurnedGoal = appState.dailyGoals.caloriesToBurn;
            
            // Calculate total manual calories
            final manualCalories = appState.activities.fold(0.0, (sum, item) => sum + item.caloriesBurned);
            
            // Auto calories from Health Connect
            final autoCalories = appState.autoBurnedCalories;
            final steps = appState.steps;

            final totalBurned = manualCalories + autoCalories;
            final progress = (totalBurned / caloriesBurnedGoal).clamp(0.0, 1.0);

            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Activity Tracking',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.sync, color: Color(0xFF14B8A6)),
                            onPressed: () {
                              appState.fetchHealthData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Syncing health data...')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Progress Ring
                       Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[100],
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)), // Teal for activity
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${totalBurned.round()}',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                '/ $caloriesBurnedGoal kcal',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Tabs
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF14B8A6),
                    unselectedLabelColor: Colors.grey[500],
                    indicatorColor: const Color(0xFF14B8A6),
                    tabs: const [
                      Tab(text: 'Manual Log'),
                      Tab(text: 'Auto Data'),
                    ],
                  ),
                ),

                // Tab View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Manual Tab
                      _buildManualList(context, appState),
                      
                      // Auto Tab
                      _buildAutoStats(context, steps, autoCalories),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentPage: 'activity',
        onNavigate: (page) => widget.navigateTo(page),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActivityOption(
                    context,
                    icon: Icons.directions_walk,
                    label: 'Walking',
                    color: const Color(0xFF14B8A6),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToAddActivity(context, 'walking');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActivityOption(
                    context,
                    icon: Icons.directions_run,
                    label: 'Running',
                    color: const Color(0xFF06B6D4),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToAddActivity(context, 'running');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActivityOption(
                    context,
                    icon: Icons.directions_bike,
                    label: 'Cycling',
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToAddActivity(context, 'cycling');
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF14B8A6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      ),
    );
  }

  Widget _buildActivityOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _navigateToAddActivity(BuildContext context, String activityType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddActivityPage(
          onBack: () => Navigator.pop(context),
          selectedActivity: activityType,
          onAddActivity: (activity) {
            Provider.of<AppState>(context, listen: false).addActivity(activity);
          },
        ),
      ),
    );
  }

  Widget _buildManualList(BuildContext context, AppState appState) {
    if (appState.activities.isEmpty) {
       return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_run, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No manual activities logged',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: appState.activities.length,
      itemBuilder: (context, index) {
        final activity = appState.activities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA), // Teal-50
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center, color: Color(0xFF14B8A6)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.activityName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '${activity.durationMinutes} minutes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${activity.caloriesBurned} kcal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14B8A6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAutoStats(BuildContext context, int steps, double calories) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
           Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.directions_walk, size: 32, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Steps count',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$steps',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.local_fire_department_rounded, size: 32, color: Colors.teal.shade600),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Automated Burn',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${calories.round()} kcal',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Data synced from Health Connect / Google Fit',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
