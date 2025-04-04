import 'package:flutter/material.dart';
import 'main.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // App title
                Center(
                  child: Text(
                    'Қазақстан тарихы',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Logo or icon placeholder
                Container(
                  height: 120,
                  width: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_stories,
                    size: 60,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                // Study button
                MainButton(
                  title: 'Үйрену',
                  icon: Icons.book,
                  color: Colors.blue.shade600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LearningPathPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Test button
                MainButton(
                  title: 'Тест',
                  icon: Icons.quiz,
                  color: Colors.orange.shade600,
                  onTap: () {
                    // Find the test category and navigate to it
                    final categories = [
                      Category(name: 'Сынақ алаңы', displayName: 'Сынақ алаңы', id: 10, isLocked: false, completedLevels: 0, totalLevels: 1),
                    ];
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPage(
                          level: categories[0].levels[0],
                          category: categories[0],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Review button
                MainButton(
                  title: 'Қайталау',
                  icon: Icons.rate_review,
                  color: Colors.green.shade600,
                  onTap: () {
                    // Create the Жалпы жаттығу (General Practice) category
                    final category = Category(
                      name: 'Жалпы жаттығу',
                      displayName: 'Жалпы жаттығу',
                      id: 9,
                      isLocked: false,
                      completedLevels: 0,
                      totalLevels: 1
                    );
                    
                    // Navigate to the category levels page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryLevelsPage(category: category),
                      ),
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MainButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 