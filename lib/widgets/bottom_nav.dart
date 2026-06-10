import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final String currentPage;
  final Function(String) onNavigate;

  const BottomNav({
    super.key,
    required this.currentPage,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'id': 'home', 'icon': Icons.add_circle_outline, 'label': 'Track'},
      {'id': 'summary', 'icon': Icons.pie_chart_outline, 'label': 'Diet'},
      {'id': 'activity', 'icon': Icons.directions_run, 'label': 'Activity'},
      {'id': 'stopwatch', 'icon': Icons.timer_outlined, 'label': 'Timer'},
      {'id': 'settings', 'icon': Icons.settings_outlined, 'label': 'Settings'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final isActive = currentPage == item['id'];
              return Expanded(
                child: InkWell(
                  onTap: () => onNavigate(item['id'] as String),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF14B8A6),
                                    Color(0xFF06B6D4),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF14B8A6)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive
                              ? const Color(0xFF14B8A6)
                              : const Color(0xFF94A3B8),
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
