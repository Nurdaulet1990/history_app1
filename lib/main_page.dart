import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double historyProgress = 0.0;
  double biologyProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAllProgress();
  }

  Future<void> _loadAllProgress() async {
    await _loadHistoryProgress();
    await _loadBiologyProgress();
  }

  Future<void> _loadHistoryProgress() async {
    // Load all categories to find total progress
    double totalProgress = 0.0;
    int totalCompletedLevels = 0;
    int totalPossibleLevels = 85; // Total number of levels including test area

    // Load progress from all history categories
    for (int i = 1; i <= 6; i++) {
      final savedCategory = await Category.loadProgress(i);
      if (savedCategory != null) {
        totalCompletedLevels += savedCategory.completedLevels;
      }
    }

    // Load progress from test area
    final testCategory = await Category.loadProgress(10);
    if (testCategory != null) {
      totalCompletedLevels += testCategory.completedLevels;
    }

    setState(() {
      historyProgress = totalCompletedLevels / totalPossibleLevels;
    });
  }

  Future<void> _loadBiologyProgress() async {
    double totalProgress = 0.0;
    int totalCompletedLevels = 0;
    int totalPossibleLevels = 85; // Total number of levels including test area

    // Load progress from all biology categories
    for (int i = 201; i <= 206; i++) {
      final savedCategory = await Category.loadProgress(i);
      if (savedCategory != null) {
        totalCompletedLevels += savedCategory.completedLevels;
      }
    }

    // Load progress from test area
    final testCategory = await Category.loadProgress(210);
    if (testCategory != null) {
      totalCompletedLevels += testCategory.completedLevels;
    }

    setState(() {
      biologyProgress = totalCompletedLevels / totalPossibleLevels;
    });
  }

  void showExamTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Дайындық кеңестері',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.blue.shade700),
              title: const Text('Күнделікті 2 сағат дайындалыңыз'),
            ),
            ListTile(
              leading: Icon(Icons.book, color: Colors.blue.shade700),
              title: const Text('Өткен тақырыптарды қайталаңыз'),
            ),
            ListTile(
              leading: Icon(Icons.psychology, color: Colors.blue.shade700),
              title: const Text('Тест тапсырмаларын шешіңіз'),
            ),
          ],
        ),
      ),
    );
  }

  void showSubjectOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Пәнді таңдаңыз',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.history_edu, color: Colors.blue.shade700),
              title: const Text('Тарих'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                // Create test category and level
                final testCategory = Category(
                  name: 'Сынақ алаңы',
                  displayName: 'Сынақ алаңы',
                  id: 10,
                  isLocked: false,
                  totalLevels: 1
                );
                final testLevel = Level(
                  name: 'Тест',
                  id: 1,
                  isLocked: false,
                  description: 'Білім тексеру'
                );
                // Navigate directly to the quiz page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                      level: testLevel,
                      category: testCategory,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.biotech, color: Colors.green.shade700),
              title: const Text('Биология'),
              onTap: () {
                Navigator.pop(context);
                // Create test category and level
                final testCategory = Category(
                  name: 'Сынақ алаңы',
                  displayName: 'Сынақ алаңы',
                  id: 210,
                  isLocked: false,
                  totalLevels: 1
                );
                final testLevel = Level(
                  name: 'Тест',
                  id: 1,
                  isLocked: false,
                  description: 'Білім тексеру'
                );
                // Navigate directly to the quiz page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                      level: testLevel,
                      category: testCategory,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top App Bar with Profile
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'ҰБТ ға дайындық',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              
              // Practice Progress
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: PracticeProgress(),
              ),

              const SizedBox(height: 16),
              
              // Subjects Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Пәндер',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.2,
                          children: [
                            // History Subject Card
                            SubjectCard(
                              title: 'Тарих',
                              icon: Icons.history_edu,
                              color: const Color(0xFF5B8FF9),
                              progress: historyProgress,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LearningPathPage(),
                                  ),
                                );
                                // Reload progress when returning from LearningPathPage
                                _loadHistoryProgress();
                              },
                            ),
                            
                            // Biology Subject Card
                            SubjectCard(
                              title: 'Биология',
                              icon: Icons.biotech,
                              color: const Color(0xFF47B881),
                              progress: biologyProgress,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BiologyLearningPathPage(),
                                  ),
                                );
                                // Reload progress when returning
                                _loadBiologyProgress();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Quick Actions
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withAlpha((0.5 * 255).round()),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => showSubjectOptions(context),
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Тест тапсыру',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Subject Card Widget
class SubjectCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double progress;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 50),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.05 * 255).round()),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
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

// Quick Action Button Widget
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.2 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade900,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.blue.shade900,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PracticeProgress extends StatefulWidget {
  const PracticeProgress({Key? key}) : super(key: key);

  @override
  _PracticeProgressState createState() => _PracticeProgressState();
}

class _PracticeProgressState extends State<PracticeProgress> {
  int _daysStreak = 0;
  int _todayMinutes = 0;
  final int _targetMinutes = 30;
  late Timer _timer;
  int _daysLeft = 0;
  int _hoursLeft = 0;
  int _minutesLeft = 0;
  DateTime? _sessionStartTime;
  Timer? _practiceTimer;
  bool _hasStudiedToday = false;

  @override
  void initState() {
    super.initState();
    _loadPracticeData();
    _updateCountdown();
    // Update countdown and check streak every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateCountdown();
      _checkAndUpdateStreak();
    });
    // Start tracking practice time when widget initializes
    _startPracticeTracking();
  }

  @override
  void dispose() {
    _timer.cancel();
    _practiceTimer?.cancel();
    _savePracticeTime(); // Save practice time when widget disposes
    super.dispose();
  }

  Future<void> _loadPracticeData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPracticeDate = DateTime.parse(
      prefs.getString('lastPracticeDate') ?? DateTime.now().toIso8601String()
    );
    
    final now = DateTime.now();
    final todayMinutes = prefs.getInt('todayMinutes') ?? 0;
    
    // Check if we need to reset for a new day
    if (!_isSameDay(lastPracticeDate, now)) {
      // If yesterday was the last practice day, increment streak
      if (_isSameDay(lastPracticeDate, now.subtract(const Duration(days: 1))) &&
          (prefs.getInt('yesterdayMinutes') ?? 0) >= _targetMinutes) {
        await prefs.setInt('daysStreak', (prefs.getInt('daysStreak') ?? 0) + 1);
      } else if (!_isSameDay(lastPracticeDate, now.subtract(const Duration(days: 1)))) {
        // Reset streak if a day was missed
        await prefs.setInt('daysStreak', 0);
      }
      
      // Store yesterday's minutes and reset today's
      await prefs.setInt('yesterdayMinutes', todayMinutes);
      await prefs.setInt('todayMinutes', 0);
      _hasStudiedToday = false;
    } else {
      _hasStudiedToday = todayMinutes >= _targetMinutes;
    }

    setState(() {
      _todayMinutes = prefs.getInt('todayMinutes') ?? 0;
      _daysStreak = prefs.getInt('daysStreak') ?? 0;
    });
  }

  Future<void> _checkAndUpdateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final todayMinutes = prefs.getInt('todayMinutes') ?? 0;
    
    // If target is reached today and streak hasn't been updated
    if (todayMinutes >= _targetMinutes && !_hasStudiedToday) {
      _hasStudiedToday = true;
      // Only increment streak if it's a new day and yesterday was successful
      final lastPracticeDate = DateTime.parse(
        prefs.getString('lastPracticeDate') ?? DateTime.now().toIso8601String()
      );
      
      if (!_isSameDay(lastPracticeDate, DateTime.now())) {
        if (_isSameDay(lastPracticeDate, DateTime.now().subtract(const Duration(days: 1))) &&
            (prefs.getInt('yesterdayMinutes') ?? 0) >= _targetMinutes) {
          await prefs.setInt('daysStreak', (prefs.getInt('daysStreak') ?? 0) + 1);
          setState(() {
            _daysStreak = prefs.getInt('daysStreak') ?? 0;
          });
        }
      }
    }
  }

  Future<void> _updatePracticeTime() async {
    if (_sessionStartTime == null) return;

    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final currentTotalMinutes = prefs.getInt('todayMinutes') ?? 0;
    final newTotalMinutes = currentTotalMinutes + 1;

    await prefs.setInt('todayMinutes', newTotalMinutes);
    await prefs.setString('lastPracticeDate', now.toIso8601String());

    setState(() {
      _todayMinutes = newTotalMinutes;
    });

    // Check if we've hit the target minutes for today
    if (newTotalMinutes >= _targetMinutes) {
      _checkAndUpdateStreak();
    }
  }

  Future<void> _savePracticeTime() async {
    if (_sessionStartTime == null) return;

    final now = DateTime.now();
    final minutesInSession = now.difference(_sessionStartTime!).inMinutes;
    
    if (minutesInSession > 0) {
      final prefs = await SharedPreferences.getInstance();
      final currentTotalMinutes = prefs.getInt('todayMinutes') ?? 0;
      final newTotalMinutes = currentTotalMinutes + minutesInSession;

      await prefs.setInt('todayMinutes', newTotalMinutes);
      await prefs.setString('lastPracticeDate', now.toIso8601String());
    }
  }

  void _updateCountdown() {
    final examDate = DateTime(2025, 6, 16);
    final now = DateTime.now();
    final difference = examDate.difference(now);

    setState(() {
      _daysLeft = difference.inDays;
      _hoursLeft = difference.inHours.remainder(24);
      _minutesLeft = difference.inMinutes.remainder(60);
    });
  }

  void _startPracticeTracking() {
    _sessionStartTime = DateTime.now();
    _practiceTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updatePracticeTime();
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: _buildStatCard(
              icon: Icons.local_fire_department,
              value: _daysStreak,
              label: 'Күн қатарынан',
              color: const Color(0xFFFF7043),
              backgroundColor: const Color(0xFFFFECE7),
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            flex: 1,
            child: _buildCountdownCard(),
          ),
          SizedBox(width: 8),
          Flexible(
            flex: 1,
            child: _buildStatCard(
              icon: Icons.timer_outlined,
              value: _todayMinutes,
              label: 'Минут',
              maxValue: _targetMinutes,
              color: const Color(0xFF4CAF50),
              backgroundColor: const Color(0xFFE8F5E9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
    required Color backgroundColor,
    int? maxValue,
  }) {
    final bool isStreak = label == 'Күн қатарынан';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: isStreak && value > 0
            ? Border.all(color: color.withAlpha((0.5 * 255).round()), width: 2)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                if (isStreak && value >= 7)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            maxValue != null ? '$value/$maxValue' : value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withAlpha((0.8 * 255).round()),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (isStreak && value > 0) ...[
            const SizedBox(height: 2),
            Text(
              '🔥 Жарайсың!',
              style: TextStyle(
                fontSize: 10,
                color: color.withAlpha((0.8 * 255).round()),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountdownCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF3F51B5).withAlpha((0.1 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF3F51B5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Color(0xFF3F51B5),
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_daysLeft',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F51B5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'Күн қалды',
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF3F51B5).withAlpha((0.8 * 255).round()),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (_daysLeft == 0) ...[
            const SizedBox(height: 2),
            Text(
              '$_hoursLeft с $_minutesLeft м',
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF3F51B5).withAlpha((0.8 * 255).round()),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
} 