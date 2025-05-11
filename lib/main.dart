import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' show Random, min, max, sin, pi, cos;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'question_banks.dart';
import 'main_page.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: '你的 Supabase Project URL',
    anonKey: '你的 Supabase anon key',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Қазақстан тарихы',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          secondary: Colors.purple,
        ),
        useMaterial3: true,
        // Add support for edge-to-edge display
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/main': (context) => MainPage(),
      },
    );
  }
}

class Level {
  final String name;
  final int id;
  bool isLocked;
  bool isCompleted;
  final String description;

  Level({
    required this.name,
    required this.id,
    this.isLocked = true,
    this.isCompleted = false,
    required this.description,
  });
}

class QuestionResponse {
  final Question question;
  final int selectedOptionIndex;
  final bool isCorrect;
  final String categoryName;
  
  QuestionResponse({
    required this.question,
    required this.selectedOptionIndex,
    required this.isCorrect,
    required this.categoryName,
  });
  
  // Helper method to determine which category a question belongs to based on its ID
  static String getCategoryNameFromQuestionId(int questionId) {
    // History questions
    if (questionId >= 1000 && questionId < 2000) return 'Бірінші тарау (Тарих)';
    if (questionId >= 2000 && questionId < 3000) return 'Екінші тарау (Тарих)';
    if (questionId >= 3000 && questionId < 4000) return 'Үшінші тарау (Тарих)';
    if (questionId >= 4000 && questionId < 5000) return 'Төртінші тарау (Тарих)';
    if (questionId >= 5000 && questionId < 6000) return 'Бесінші тарау (Тарих)';
    if (questionId >= 6000 && questionId < 7000) return 'Алтыншы тарау (Тарих)';
    
    // Biology questions
    if (questionId >= 201000 && questionId < 202000) return 'Бірінші тарау (Биология)';
    if (questionId >= 202000 && questionId < 203000) return 'Екінші тарау (Биология)';
    if (questionId >= 203000 && questionId < 204000) return 'Үшінші тарау (Биология)';
    if (questionId >= 204000 && questionId < 205000) return 'Төртінші тарау (Биология)';
    
    // Computer Science questions
    if (questionId >= 101000 && questionId < 102000) return 'Алгоритмдер негіздері';
    if (questionId >= 102000 && questionId < 103000) return 'Деректер құрылымдары';
    
    return 'Белгісіз';
  }
}

class TestResult {
  final DateTime date;
  final int correctAnswers;
  final int totalQuestions;
  final double percentage;
  final String grade;
  final String subject; // Added subject field
  
  TestResult({
    required this.date,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percentage,
    required this.grade,
    required this.subject, // Added to constructor
  });
  
  // Convert TestResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'percentage': percentage,
      'grade': grade,
      'subject': subject, // Added to JSON
    };
  }
  
  // Create a TestResult from JSON
  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      date: DateTime.parse(json['date']),
      correctAnswers: json['correctAnswers'],
      totalQuestions: json['totalQuestions'],
      percentage: json['percentage'],
      grade: json['grade'],
      subject: json['subject'] ?? 'Unknown', // Default if missing in old data
    );
  }
  
  // Save a test result to SharedPreferences
  static Future<void> saveTestResult(TestResult result) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing results for this subject
    List<TestResult> existingResults = await loadTestResults(subject: result.subject);
    
    // Add the new result
    existingResults.add(result);
    
    // Keep only the last 10 results for this subject
    if (existingResults.length > 10) {
      existingResults = existingResults.sublist(existingResults.length - 10);
    }
    
    // Convert to JSON and save
    final List<String> jsonResults = existingResults.map((result) => jsonEncode(result.toJson())).toList();
    await prefs.setStringList('test_results_${result.subject}', jsonResults);
  }
  
  // Load test results from SharedPreferences
  static Future<List<TestResult>> loadTestResults({String? subject}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (subject != null) {
      // Load results for a specific subject
      final List<String>? jsonResults = prefs.getStringList('test_results_$subject');
      
      if (jsonResults == null || jsonResults.isEmpty) {
        return [];
      }
      
      // Convert JSON to TestResult objects
      return jsonResults.map((jsonResult) => TestResult.fromJson(jsonDecode(jsonResult))).toList();
    } else {
      // For backward compatibility, also check the old key
      final List<String>? jsonResults = prefs.getStringList('test_results');
      
      if (jsonResults == null || jsonResults.isEmpty) {
        return [];
      }
      
      // Convert JSON to TestResult objects
      return jsonResults.map((jsonResult) => TestResult.fromJson(jsonDecode(jsonResult))).toList();
    }
  }
}

class Category {
  final String name;
  final String displayName;
  final int id;
  final bool isLocked;
  bool isCompleted;
  final int totalLevels;
  int completedLevels;
  final List<Level> levels;

  Category({
    required this.name,
    String? displayName,
    required this.id,
    this.isLocked = true,
    this.isCompleted = false,
    this.totalLevels = 12,
    this.completedLevels = 0,
  }) : displayName = displayName ?? name,
       levels = List.generate(
         12,  // All categories have 12 levels now
         (index) => Level(
           name: 'Деңгей ${index + 1}',
           id: index + 1,
           isLocked: index != 0,  // First level is unlocked
           isCompleted: false,
           description: 'Келесі деңгейді ашу үшін осы деңгейді аяқтаңыз',
         ),
       );

  void completeLevel(int levelId) {
    if (levelId > 0 && levelId <= levels.length) {
      // Mark the current level as completed
      levels[levelId - 1].isCompleted = true;
      
      // Unlock the next level if it exists
      if (levelId < levels.length) {
        levels[levelId].isLocked = false;
      }
      
      // Update completed levels count
      completedLevels = levels.where((level) => level.isCompleted).length;
      
      // Update category completion status
      isCompleted = completedLevels == totalLevels;

      // Save progress
      saveProgress();
    }
  }

  // Convert category to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'id': id,
      'isLocked': isLocked,
      'isCompleted': isCompleted,
      'totalLevels': totalLevels,
      'completedLevels': completedLevels,
      'levels': levels.map((level) => {
        'name': level.name,
        'id': level.id,
        'isLocked': level.isLocked,
        'isCompleted': level.isCompleted,
        'description': level.description,
      }).toList(),
    };
  }

  // Create category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    var category = Category(
      name: json['name'],
      displayName: json['displayName'],
      id: json['id'],
      isLocked: json['isLocked'],
      isCompleted: json['isCompleted'],
      totalLevels: json['totalLevels'],
      completedLevels: json['completedLevels'],
    );
    
    // Override generated levels with saved ones
    if (json['levels'] != null) {
      List<dynamic> levelsList = json['levels'];
      category.levels.clear();
      category.levels.addAll(
        levelsList.map((levelJson) => Level(
          name: levelJson['name'],
          id: levelJson['id'],
          isLocked: levelJson['isLocked'],
          isCompleted: levelJson['isCompleted'],
          description: levelJson['description'],
        )),
      );
    }
    
    return category;
  }

  // Save progress to SharedPreferences
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = 'category_${id}';
    final String json = jsonEncode(toJson());
    await prefs.setString(key, json);
  }

  // Load progress from SharedPreferences
  static Future<Category?> loadProgress(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = 'category_${categoryId}';
    final String? json = prefs.getString(key);
    if (json == null) return null;
    return Category.fromJson(jsonDecode(json));
  }

  double get progress => completedLevels / totalLevels;
  bool get hasCompletionBadge => completedLevels == totalLevels;
}

class LearningPathPage extends StatefulWidget {
  const LearningPathPage({super.key});

  @override
  State<LearningPathPage> createState() => _LearningPathPageState();
}

class _LearningPathPageState extends State<LearningPathPage> {
  late List<Category> categories;
  bool isLoading = true;

  double get totalProgress {
    if (categories.isEmpty) return 0.0;
    double totalCompletedLevels = categories
        .map((category) => category.completedLevels)
        .fold(0, (sum, levels) => sum + levels);
    
    double totalPossibleLevels = categories
        .map((category) => category.totalLevels)
        .fold(0, (sum, levels) => sum + levels);
    
    return totalPossibleLevels > 0 ? (totalCompletedLevels / totalPossibleLevels) : 0.0;
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _clearAllCategoryData() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= 9; i++) {
      await prefs.remove('category_$i');
    }
    print('All category data has been cleared');
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Initialize with default categories
    categories = [
      Category(name: 'Бірінші тарау (Тарих)', displayName: 'Ежелгі Қазақстан', id: 1, isLocked: false, completedLevels: 0),
      Category(name: 'Екінші тарау (Тарих)', displayName: 'Орта ғасыр', id: 2, isLocked: false, completedLevels: 0),
      Category(name: 'Үшінші тарау (Тарих)', displayName: 'Жаңа замандағы Қазақстан 1', id: 3, isLocked: false, completedLevels: 0),
      Category(name: 'Төртінші тарау (Тарих)', displayName: 'Жаңа замандағы Қазақстан 2', id: 4, isLocked: false, completedLevels: 0),
      Category(name: 'Бесінші тарау (Тарих)', displayName: 'Қазіргі замандағы Қазақстан 1', id: 5, isLocked: false, completedLevels: 0),
      Category(name: 'Алтыншы тарау (Тарих)', displayName: 'Қазіргі замандағы Қазақстан 2', id: 6, isLocked: false, completedLevels: 0),
      Category(name: 'Жалпы жаттығу (Тарих)', id: 9, isLocked: false, completedLevels: 0),
      Category(name: 'Сынақ алаңы', displayName: 'Сынақ алаңы', id: 10, isLocked: false, completedLevels: 0, totalLevels: 1),
    ];

    // Load saved progress for each category
    for (int i = 0; i < categories.length; i++) {
      final savedCategory = await Category.loadProgress(categories[i].id);
      if (savedCategory != null) {
        categories[i] = savedCategory;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Қазақстан тарихы'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha((0.95 * 255).round()),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Барлық деректерді тазарту'),
                  content: const Text('Барлық категориялардың прогресін тазалауды қалайсыз ба?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Жоқ'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearAllCategoryData();
                      },
                      child: const Text('Иә'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      // Use SafeArea to handle insets properly with edge-to-edge display
      body: SafeArea(
        // Use MediaQuery.removePadding to control which edges have padding
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true, // Remove top padding since AppBar already handles it
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withAlpha((0.7 * 255).round()),
                              Theme.of(context).colorScheme.secondary.withAlpha((0.7 * 255).round()),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.1 * 255).round()),
                              blurRadius: 8,
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
                                  'Жалпы прогресс',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${(totalProgress * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white.withAlpha((0.2 * 255).round()),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: totalProgress,
                                  backgroundColor: Colors.transparent,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${categories.fold(0, (sum, c) => sum + c.completedLevels)}/${categories.fold(0, (sum, c) => sum + c.totalLevels)} деңгей',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withAlpha((0.9 * 255).round()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Оқу үрдісі',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LearningPathGrid(categories: categories),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LearningPathGrid extends StatelessWidget {
  final List<Category> categories;

  const LearningPathGrid({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,  // Adjusted for better proportions
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return CategoryCard(category: categories[index]);
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Change all card colors to transparent dark blue with increased transparency
    List<Color> cardGradientColors = category.isLocked
        ? [Colors.blueGrey.shade700.withAlpha((0.5 * 255).round()), Colors.blueGrey.shade900.withAlpha((0.6 * 255).round())]
        : [
            Colors.blue.shade800.withAlpha((0.5 * 255).round()),
            Colors.blue.shade900.withAlpha((0.6 * 255).round()),
          ];

    return GestureDetector(
      onTap: category.isLocked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Бұл бөлімді ашу үшін алдыңғы бөлімдерді аяқтаңыз'),
                ),
              );
            }
          : () {
              // For special categories, go directly to the questions instead of level selection
              if (category.name == 'Сынақ алаңы') {
                print('Opening test area with category ID: ${category.id}'); // Add debug print
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                      level: Level(
                        name: 'Сынақ алаңы',
                        id: category.id,
                        isLocked: false,
                        description: 'Тест режимі'
                      ),
                      category: category,
                    ),
                  ),
                );
              } else {
                // Regular categories go to level selection
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryLevelsPage(category: category),
                  ),
                );
              }
            },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: cardGradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (category.hasCompletionBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300.withAlpha((0.8 * 255).round()),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).round()),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            // Special icon for test area
            if (category.name == 'Сынақ алаңы' && !category.isLocked)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300.withAlpha((0.4 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.quiz,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double contentMaxWidth = constraints.maxWidth < 600 ? constraints.maxWidth : 600;
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (category.isLocked)
                              const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 32,
                              ),
                            const SizedBox(height: 8),
                            Text(
                              category.displayName,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: category.isLocked ? Colors.grey.shade700 : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (!category.isLocked) ...[
                              category.name == 'Сынақ алаңы'
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha((0.2 * 255).round()),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Білім тексеру',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: category.progress,
                                      backgroundColor: Colors.white.withAlpha((0.2 * 255).round()),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        category.hasCompletionBadge ? Colors.blue.shade300 : Colors.white,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                              const SizedBox(height: 8),
                              category.name != 'Сынақ алаңы'
                                ? Text(
                                    '${category.completedLevels}/${category.totalLevels} деңгей',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryLevelsPage extends StatefulWidget {
  final Category category;

  const CategoryLevelsPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryLevelsPage> createState() => _CategoryLevelsPageState();
}

class _CategoryLevelsPageState extends State<CategoryLevelsPage> {
  late Category category;

  @override
  void initState() {
    super.initState();
    category = widget.category;
  }

  void _refreshProgress() async {
    final savedCategory = await Category.loadProgress(category.id);
    if (savedCategory != null) {
      setState(() {
        category = savedCategory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(category.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha((0.95 * 255).round()),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        // Use MediaQuery.removePadding to control which edges have padding
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true, // Remove top padding since AppBar already handles it
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Прогресс: ${category.completedLevels}/${category.totalLevels}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double buttonSize = 80.0; // Increased size for the yurt shape
                          final double topPadding = 20.0;
                          final double bottomPadding = 20.0;
                          final double verticalSpacing = 60.0; // Increased spacing
                          
                          final double totalHeight = topPadding + bottomPadding + 
                            (buttonSize * category.levels.length) + 
                            (verticalSpacing * (category.levels.length - 1));

                          return SizedBox(
                            height: totalHeight,
                            child: Stack(
                              children: [
                                CustomPaint(
                                  size: Size(constraints.maxWidth, totalHeight),
                                  painter: CurvedLinePainter(
                                    levels: category.levels,
                                    buttonSize: buttonSize,
                                    verticalSpacing: verticalSpacing,
                                    topPadding: topPadding,
                                    width: constraints.maxWidth,
                                  ),
                                ),
                                ...List.generate(
                                  category.levels.length,
                                  (index) {
                                    final level = category.levels[index];
                                    final y = topPadding + (index * (buttonSize + verticalSpacing));
                                    
                                    // Calculate x position with alternating curves
                                    final amplitude = constraints.maxWidth * 0.4; // Reduced amplitude
                                    final frequency = 2 * pi / 6;
                                    final phase = index * frequency;
                                    final x = constraints.maxWidth / 2 + amplitude * sin(phase);

                                    return Positioned(
                                      top: y,
                                      left: x - buttonSize / 2,
                                      child: SizedBox(
                                        width: buttonSize,
                                        height: buttonSize,
                                        child: Transform.scale(
                                          scale: level.isLocked ? 0.85 : 1.0,
                                          child: LevelButton(
                                            level: level,
                                            category: category,
                                            onLevelComplete: _refreshProgress,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CurvedLinePainter extends CustomPainter {
  final List<Level> levels;
  final double buttonSize;
  final double verticalSpacing;
  final double topPadding;
  final double width;

  CurvedLinePainter({
    required this.levels,
    required this.buttonSize,
    required this.verticalSpacing,
    required this.topPadding,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < levels.length - 1; i++) {
      final startY = topPadding + (i * (buttonSize + verticalSpacing)) + buttonSize / 2;
      final endY = startY + buttonSize + verticalSpacing;
      
      // Calculate smooth wave pattern
      final amplitude = width * 0.45;
      final frequency = 2 * pi / 6;
      final startPhase = i * frequency;
      final endPhase = (i + 1) * frequency;
      
      final startX = width / 2 + amplitude * sin(startPhase);
      final endX = width / 2 + amplitude * sin(endPhase);

      final path = Path();
      path.moveTo(startX, startY);
      
      // Enhanced control points for smoother curves
      final verticalDistance = endY - startY;
      final horizontalDistance = endX - startX;
      
      // Calculate control points with dynamic tension
      final tension = 0.5; // Adjust this value between 0 and 1 for different curve styles
      final control1X = startX + horizontalDistance * tension;
      final control1Y = startY + verticalDistance * (1 - tension);
      final control2X = endX - horizontalDistance * tension;
      final control2Y = endY - verticalDistance * (1 - tension);
      
      path.cubicTo(
        control1X, control1Y,
        control2X, control2Y,
        endX, endY,
      );

      // Set color based on completion status with smoother gradient
      if (levels[i].isCompleted && levels[i + 1].isCompleted) {
        final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF9B6E46).withAlpha((0.8 * 255).round()), // Traditional brown
            Color(0xFF654321).withAlpha((0.6 * 255).round()), // Darker brown
          ],
        );
        paint.shader = gradient.createShader(Rect.fromPoints(
          Offset(startX, startY),
          Offset(endX, endY),
        ));
      } else {
        paint.shader = null;
        paint.color = Colors.grey.withAlpha((0.3 * 255).round());
      }

      // Enhanced glow effect for completed path
      if (levels[i].isCompleted && levels[i + 1].isCompleted) {
        final glowPaint = Paint()
          ..strokeWidth = 8.0
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF9B6E46).withAlpha((0.2 * 255).round()) // Traditional brown glow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
        canvas.drawPath(path, glowPaint);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class LevelButton extends StatelessWidget {
  final Level level;
  final Category category;
  final VoidCallback onLevelComplete;

  const LevelButton({
    super.key,
    required this.level,
    required this.category,
    required this.onLevelComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: level.isLocked
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Бұл деңгейді ашу үшін алдыңғы деңгейлерді аяқтаңыз'),
                  ),
                );
              }
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                      level: level,
                      category: category,
                    ),
                  ),
                );
                onLevelComplete();
              },
        customBorder: YurtShape(),
        child: CustomPaint(
          painter: YurtPainter(
            isLocked: level.isLocked,
            isCompleted: level.isCompleted,
            primaryColor: Theme.of(context).colorScheme.primary,
            secondaryColor: Theme.of(context).colorScheme.secondary,
          ),
          child: SizedBox(
            width: 80,
            height: 80,
          ),
        ),
      ),
    );
  }
}

class YurtShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final Path path = Path();
    
    // Make hit area slightly larger than the visual yurt
    
    // Roof (conical shape)
    final roofBaseY = rect.top + height * 0.4;
    path.moveTo(rect.left + width * 0.08, roofBaseY);
    path.quadraticBezierTo(
      rect.left + width * 0.2, rect.top + height * 0.2,
      rect.left + width / 2, rect.top + height * 0.05
    );
    path.quadraticBezierTo(
      rect.left + width * 0.8, rect.top + height * 0.2,
      rect.left + width * 0.92, roofBaseY
    );
    
    // Body (cylindrical part)
    path.lineTo(rect.left + width * 0.92, rect.top + height * 0.75);
    path.quadraticBezierTo(
      rect.left + width / 2, rect.top + height * 0.85,
      rect.left + width * 0.08, rect.top + height * 0.75
    );
    path.close();
    
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // No additional painting needed here
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }
}

class YurtPainter extends CustomPainter {
  final bool isLocked;
  final bool isCompleted;
  final Color primaryColor;
  final Color secondaryColor;

  YurtPainter({
    required this.isLocked,
    required this.isCompleted,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // Define colors based on state with more vibrant, realistic tones
    final List<Color> mainGradientColors = isLocked
        ? [Colors.grey.shade400, Colors.grey.shade700]
        : [
            Color(0xFF9B6E46), // Richer brown for more realism
            Color(0xFF654321), // Dark brown
          ];
    
    // =====  3D Environment Effects =====
    
    // Background environment shadow (simulating yurt casting shadow on ground)
    final environmentShadowPath = Path();
    environmentShadowPath.addOval(
      Rect.fromCenter(
        center: Offset(width / 2, height * 0.88),
        width: width * 1.1, 
        height: height * 0.15,
      )
    );
    
    final environmentShadowPaint = Paint()
      ..color = Colors.black.withAlpha((0.35 * 255).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    canvas.drawPath(environmentShadowPath, environmentShadowPaint);
    
    // Ground texture with subtle grass/dirt details
    final groundPaint = Paint()
      ..style = PaintingStyle.fill;
      
    // Ground gradient for more realistic terrain
    final groundGradient = RadialGradient(
      center: Alignment(0.0, 0.0),
      radius: 1.2,
      colors: isLocked
          ? [Colors.grey.shade400, Colors.grey.shade300]
          : [Color(0xFF8FBC8F), Color(0xFF6B8E23)], // Green terrain
      stops: [0.2, 1.0],
    );
    
    groundPaint.shader = groundGradient.createShader(
      Rect.fromCenter(
        center: Offset(width / 2, height * 0.82),
        width: width * 0.9,
        height: height * 0.14,
      )
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(width / 2, height * 0.82),
        width: width * 0.9,
        height: height * 0.14,
      ),
      groundPaint
    );
    
    // Add subtle ground texture pattern if not locked
    if (!isLocked) {
      final groundPatternPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = isCompleted 
            ? Colors.green.shade400.withAlpha((0.3 * 255).round())
            : Colors.brown.shade300.withAlpha((0.3 * 255).round());
      
      // Subtle grass/terrain pattern
      for (int i = 0; i < 8; i++) {
        final patternX = width * 0.3 + (i * width * 0.07);
        final patternHeight = height * 0.03;
        final yVariation = (i % 3) * height * 0.01;
        
        final grassPath = Path();
        grassPath.moveTo(patternX, height * 0.82 - yVariation);
        grassPath.lineTo(patternX - width * 0.01, height * 0.82 - patternHeight - yVariation);
        grassPath.lineTo(patternX + width * 0.01, height * 0.82 - yVariation);
        
        canvas.drawPath(grassPath, groundPatternPaint);
      }
    }
    
    // ===== Main Yurt Structure with Enhanced 3D Effects =====
    
    // Create a conical dome shape for the yurt roof with improved curvature
    final Path roofPath = Path();
    
    // Bottom of the roof connects to the cylindrical body
    final roofBaseY = height * 0.4;
    final roofBaseWidth = width * 0.8;
    
    // Top of the roof is at a point
    final roofTopX = width / 2;
    final roofTopY = height * 0.05;
    
    // Side points for the conical dome with slight asymmetry for realism
    roofPath.moveTo(width * 0.1, roofBaseY);
    // Left side to peak with realistic curve
    roofPath.cubicTo(
      width * 0.15, height * 0.3, // Control point 1
      width * 0.3, height * 0.12, // Control point 2
      roofTopX, roofTopY // Endpoint
    );
    // Peak to right side with similar but slightly different curve for realism
    roofPath.cubicTo(
      width * 0.7, height * 0.12, // Control point 1
      width * 0.85, height * 0.3, // Control point 2
      width * 0.9, roofBaseY // Endpoint
    );
    
    // Close the roof path
    roofPath.close();
    
    // Enhanced drop shadow for the roof with more depth
    final roofShadowPaint = Paint()
      ..color = Colors.black.withAlpha((0.6 * 255).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    final roofShadowPath = Path()..addPath(roofPath, const Offset(6, 6));
    canvas.drawPath(roofShadowPath, roofShadowPaint);
    
    // Draw the roof with enhanced texture and gradient for felt material
    final roofPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: isLocked
            ? [Colors.grey.shade500, Colors.grey.shade700]
            : [
                Color(0xFFB5651D), // Rich dark brown
                Color(0xFF7D4B2A), // Deeper brown for shadow side
              ],
        begin: Alignment(-0.3, -0.8), // Light source from top-left
        end: Alignment(0.8, 0.8),    // Shadow towards bottom-right
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    
    canvas.drawPath(roofPath, roofPaint);
    
    // Enhanced roof texture with more detailed pattern
    if (!isLocked) {
      // Felt texture pattern suggestion
      final feltTexturePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4
        ..color = Colors.brown.shade200.withAlpha((0.3 * 255).round());
      
      // Create a more subtle felt texture pattern
      for (int i = 0; i < 20; i++) {
        final y = roofTopY + (i * (roofBaseY - roofTopY) / 20);
        final x = width * 0.15 + (i * 0.04 * width);
        final patternWidth = (roofBaseWidth * 0.8) - (i * 0.04 * width);
        
        final texturePath = Path();
        texturePath.moveTo(x, y);
        texturePath.lineTo(x + patternWidth, y);
        
        canvas.drawPath(texturePath, feltTexturePaint);
      }
      
      // Horizontal rings on the roof (enhanced with better perspective)
      final roofLinePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.brown.shade300.withAlpha((0.7 * 255).round())
        ..strokeWidth = 1.0;
      
      for (int i = 1; i <= 7; i++) {
        final ringY = roofTopY + ((roofBaseY - roofTopY) * i / 8);
        final ringWidth = (roofBaseWidth * i / 8);
        final ringHeight = ringWidth * (0.25 + (i * 0.01)); // Increasing oval squash for perspective
        
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(width / 2 + (i * width * 0.005), ringY), // Slight offset for perspective
            width: ringWidth,
            height: ringHeight,
          ),
          roofLinePaint
        );
      }
      
      // Enhanced diagonal supports (uyk) with varying thickness
      final uykPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.brown.shade400.withAlpha((0.8 * 255).round());
      
      for (int i = 0; i < 12; i++) {
        final angle = (i * pi / 6);
        final startX = width / 2;
        final startY = roofTopY;
        
        // Thicker poles in the foreground, thinner in the background for depth
        final thickness = 0.5 + (sin(angle + (pi/4)) + 1) * 0.5;
        uykPaint.strokeWidth = thickness * 1.5;
        
        // Calculate endpoint on the base of the roof 
        final radius = roofBaseWidth / 2;
        final endX = startX + cos(angle) * radius;
        final endY = roofBaseY;
        
        final path = Path();
        path.moveTo(startX, startY);
        path.lineTo(endX, endY);
        
        canvas.drawPath(path, uykPaint);
        
        // Add a subtle second layer of wooden structure
        if (i % 2 == 0 && !isCompleted) {
            final crossY = roofTopY + ((roofBaseY - roofTopY) * 0.4);
            final crossRadius = roofBaseWidth * 0.3;
            final crossX1 = startX + cos(angle) * crossRadius;
            final crossY1 = crossY;
            
            final crosspath = Path();
            crosspath.moveTo(startX, startY);
            crosspath.lineTo(crossX1, crossY1);
            
            canvas.drawPath(crosspath, uykPaint..strokeWidth = thickness);
        }
      }
    }
    
    // Draw the main body (cylindrical part) with enhanced 3D perspective
    final Path bodyPath = Path();
    
    // The cylindrical body with slight bulge for realism (yurts aren't perfectly cylindrical)
    bodyPath.moveTo(width * 0.1, roofBaseY);
    
    // Left side wall with slight curve
    bodyPath.cubicTo(
      width * 0.08, roofBaseY + (height * 0.75 - roofBaseY) * 0.3, // Control point 1
      width * 0.08, roofBaseY + (height * 0.75 - roofBaseY) * 0.7, // Control point 2
      width * 0.1, height * 0.75 // Endpoint
    );
    
    // Bottom curve
    bodyPath.quadraticBezierTo(
      width / 2, height * 0.85,
      width * 0.9, height * 0.75
    );
    
    // Right side wall with slight curve
    bodyPath.cubicTo(
      width * 0.92, roofBaseY + (height * 0.75 - roofBaseY) * 0.7, // Control point 1
      width * 0.92, roofBaseY + (height * 0.75 - roofBaseY) * 0.3, // Control point 2
      width * 0.9, roofBaseY // Endpoint
    );
    
    // Close the body path by connecting to the roof
    bodyPath.close();
    
    // Enhanced body shadow with realistic light direction
    final bodyShadowPaint = Paint()
      ..color = Colors.black.withAlpha((0.45 * 255).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    final bodyShadowPath = Path()..addPath(bodyPath, const Offset(5, 5));
    canvas.drawPath(bodyShadowPath, bodyShadowPaint);
    
    // Draw the body with enhanced gradient for felt texture
    final bodyPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: isLocked
            ? [Colors.grey.shade400, Colors.grey.shade600]
            : [
                Color(0xFFF8E0C0), // Light felt color
                Color(0xFFEDCEA6), // Medium felt
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    
    canvas.drawPath(bodyPath, bodyPaint);
    
    // Add subtle texture to the walls for realistic felt appearance
    if (!isLocked) {
      final wallTexturePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = Colors.brown.shade700.withAlpha((0.2 * 255).round());
      
      // Horizontal texture lines
      for (int i = 1; i < 8; i++) {
        final y = roofBaseY + (height * 0.75 - roofBaseY) * (i / 8);
        final bodyWidthAtY = width * 0.8 - (i * width * 0.01); // Slight tapering
        
        final leftX = width / 2 - bodyWidthAtY / 2;
        final rightX = width / 2 + bodyWidthAtY / 2;
        
        canvas.drawLine(
          Offset(leftX, y),
          Offset(rightX, y),
          wallTexturePaint
        );
      }
      
      // Vertical ropes/cords that traditionally secure the felt covering
      for (int i = 0; i < 4; i++) {
        final x = width * 0.25 + (i * width * 0.17);
        
        final ropePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Color(0xFF5C4033).withAlpha((0.4 * 255).round()); // Brown rope
        
        canvas.drawLine(
          Offset(x, roofBaseY),
          Offset(x, height * 0.75 - (i % 2) * height * 0.02), // Slight variation in length
          ropePaint
        );
      }
    }
    
    // Enhanced traditional ornamental band around the yurt with more detail
    if (!isLocked) {
      final bandY = roofBaseY + (height * 0.75 - roofBaseY) * 0.25;
      final bandHeight = (height * 0.75 - roofBaseY) * 0.18;
      
      // Enhance the band with more traditional colors and gradients
      final bandPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          colors: [
              Color(0xFFD22730).withAlpha((0.85 * 255).round()), // Traditional Kazakh red
              Color(0xFFAA1428).withAlpha((0.85 * 255).round()), // Deeper red
            ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, bandY, width, bandHeight));
      
      // Draw the ornamental band with slightly curved top and bottom for 3D effect
      final bandPath = Path();
      
      // Top curve
      bandPath.moveTo(width * 0.1, bandY);
      bandPath.quadraticBezierTo(
        width * 0.5, bandY - bandHeight * 0.1,
        width * 0.9, bandY
      );
      
      // Right side
      bandPath.lineTo(width * 0.9, bandY + bandHeight);
      
      // Bottom curve
      bandPath.quadraticBezierTo(
        width * 0.5, bandY + bandHeight * 1.1,
        width * 0.1, bandY + bandHeight
      );
      
      // Close path
      bandPath.close();
      
      canvas.drawPath(bandPath, bandPaint);
      
      // Enhanced traditional Kazakh pattern on the band - more authentic patterns
      final patternPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withAlpha((0.85 * 255).round())
        ..strokeWidth = 1.2;
      
      // Kazakh "qoshqar muiz" (ram's horn) pattern - a common traditional motif
      final int patternCount = 6;
      final patternWidth = (width * 0.8) / patternCount;
      
      for (int i = 0; i < patternCount; i++) {
        final patternX = width * 0.1 + (i * patternWidth) + (patternWidth / 2);
        final patternY = bandY + (bandHeight / 2);
        
        final patternSize = patternWidth * 0.35;
        final hornPath = Path();
        
        // Draw ram's horn spiral pattern
        hornPath.moveTo(patternX, patternY - patternSize / 2);
        
        // Top spiral curl (right side)
        hornPath.cubicTo(
          patternX + patternSize / 3, patternY - patternSize / 2,
          patternX + patternSize / 1.5, patternY - patternSize / 4,
          patternX + patternSize / 2, patternY
        );
        
        // Bottom spiral curl (right side)
        hornPath.cubicTo(
          patternX + patternSize / 1.5, patternY + patternSize / 4,
          patternX + patternSize / 3, patternY + patternSize / 2,
          patternX, patternY + patternSize / 2
        );
        
        // Top spiral curl (left side) - mirror of right side
        hornPath.cubicTo(
          patternX - patternSize / 3, patternY + patternSize / 2,
          patternX - patternSize / 1.5, patternY + patternSize / 4,
          patternX - patternSize / 2, patternY
        );
        
        // Bottom spiral curl (left side)
        hornPath.cubicTo(
          patternX - patternSize / 1.5, patternY - patternSize / 4,
          patternX - patternSize / 3, patternY - patternSize / 2,
          patternX, patternY - patternSize / 2
        );
        
        canvas.drawPath(hornPath, patternPaint);
        
        // Small decorative dots within the pattern
        final dotPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = isCompleted 
              ? Colors.green.shade100.withAlpha((0.9 * 255).round())
              : Colors.white.withAlpha((0.9 * 255).round());
        
        canvas.drawCircle(Offset(patternX, patternY), 1.2, dotPaint);
        canvas.drawCircle(Offset(patternX + patternSize / 3, patternY), 0.8, dotPaint);
        canvas.drawCircle(Offset(patternX - patternSize / 3, patternY), 0.8, dotPaint);
      }
      
      // Add border lines to the band
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withAlpha((0.6 * 255).round())
        ..strokeWidth = 1.0;
      
      final topBorderPath = Path();
      topBorderPath.moveTo(width * 0.1, bandY);
      topBorderPath.quadraticBezierTo(
        width * 0.5, bandY - bandHeight * 0.1,
        width * 0.9, bandY
      );
      
      final bottomBorderPath = Path();
      bottomBorderPath.moveTo(width * 0.1, bandY + bandHeight);
      bottomBorderPath.quadraticBezierTo(
        width * 0.5, bandY + bandHeight * 1.1,
        width * 0.9, bandY + bandHeight
      );
      
      canvas.drawPath(topBorderPath, borderPaint);
      canvas.drawPath(bottomBorderPath, borderPaint);
    }
    
    // Enhanced door with more realistic proportions and details
    final doorPath = Path();
    
    // Create an arched door with better perspective
    final doorWidth = width * 0.32;
    final doorLeft = width / 2 - doorWidth / 2;
    final doorRight = width / 2 + doorWidth / 2;
    final doorTop = height * 0.45;
    final doorBottom = height * 0.75;
    
    // Door with curved top (more realistic arch)
    doorPath.moveTo(doorLeft, doorBottom);
    doorPath.lineTo(doorLeft, doorTop + doorWidth * 0.25);
    doorPath.cubicTo(
      doorLeft + doorWidth * 0.2, doorTop, // Control point 1
      doorRight - doorWidth * 0.2, doorTop, // Control point 2
      doorRight, doorTop + doorWidth * 0.25 // Endpoint
    );
    doorPath.lineTo(doorRight, doorBottom);
    
    // Enhanced door with deeper shadow for more 3D effect
    final doorShadowPath = Path()..addPath(doorPath, const Offset(3, 3));
    final doorShadowPaint = Paint()
      ..color = Colors.black.withAlpha((0.6 * 255).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawPath(doorShadowPath, doorShadowPaint);
    
    // Door fill with richer wood texture
    final doorFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: isLocked
            ? [Colors.grey.shade600, Colors.grey.shade700]
            : [
                Color(0xFF8B4513), // Dark wooden door
                Color(0xFF6B3811), // Even darker shadow
              ],
        begin: Alignment(-0.5, -0.5), // Light from top-left
        end: Alignment(0.8, 0.8),    // Shadow towards bottom-right
      ).createShader(Rect.fromLTWH(doorLeft, doorTop, doorRight - doorLeft, doorBottom - doorTop));
    
    canvas.drawPath(doorPath, doorFillPaint);
    
    // Door frame with richer color and 3D effect
    final doorFramePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = isLocked
          ? Colors.grey.shade400
          : Color(0xFFD6BC8C) // Rich tan color for wooden frame
      ..strokeWidth = 2.5;
    
    canvas.drawPath(doorPath, doorFramePaint);
    
    // Add enhanced decorative elements if not locked
    if (!isLocked) {
      // Door with woodgrain texture
      final woodgrainPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Color(0xFFA67B5B).withAlpha((0.3 * 255).round()) // Wood color
        ..strokeWidth = 0.6;
      
      // Vertical wood grain
      for (int i = 1; i < 6; i++) {
        final x = doorLeft + (doorWidth * i / 6);
        final curveFactor = sin(i * 0.8) * doorWidth * 0.03;
        
        final grainPath = Path();
        grainPath.moveTo(x + curveFactor, doorTop + doorWidth * 0.3);
        grainPath.lineTo(x - curveFactor, doorBottom - doorWidth * 0.1);
        
        canvas.drawPath(grainPath, woodgrainPaint);
      }
      
      // Traditional Kazakh door decorations with more detail
      final doorPatternPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Color(0xFFDAA520).withAlpha((0.8 * 255).round()) // Gold color
        ..strokeWidth = 1.2;
      
      // Door threshold line with slight curve for realism
      final thresholdPath = Path();
      thresholdPath.moveTo(doorLeft + doorWidth * 0.1, doorBottom - doorWidth * 0.1);
      thresholdPath.quadraticBezierTo(
        width / 2, doorBottom - doorWidth * 0.08,
        doorRight - doorWidth * 0.1, doorBottom - doorWidth * 0.1
      );
      
      canvas.drawPath(thresholdPath, doorPatternPaint);
      
      // Enhanced central door decoration with traditional motifs
      final middleX = width / 2;
      final doorCenterY = doorTop + (doorBottom - doorTop) * 0.5;
      
      // Central decorative pattern (stylized tulip - common in Kazakh art)
      final tulipPath = Path();
      final tulipSize = doorWidth * 0.3;
      
      // Stem
      tulipPath.moveTo(middleX, doorCenterY + tulipSize * 0.4);
      tulipPath.lineTo(middleX, doorCenterY - tulipSize * 0.25);
      
      // Left petal
      tulipPath.moveTo(middleX, doorCenterY - tulipSize * 0.1);
      tulipPath.quadraticBezierTo(
        middleX - tulipSize * 0.25, doorCenterY - tulipSize * 0.4,
        middleX - tulipSize * 0.1, doorCenterY - tulipSize * 0.5
      );
      
      // Right petal
      tulipPath.moveTo(middleX, doorCenterY - tulipSize * 0.1);
      tulipPath.quadraticBezierTo(
        middleX + tulipSize * 0.25, doorCenterY - tulipSize * 0.4,
        middleX + tulipSize * 0.1, doorCenterY - tulipSize * 0.5
      );
      
      // Middle petal
      tulipPath.moveTo(middleX, doorCenterY - tulipSize * 0.1);
      tulipPath.quadraticBezierTo(
        middleX, doorCenterY - tulipSize * 0.6,
        middleX, doorCenterY - tulipSize * 0.5
      );
      
      canvas.drawPath(tulipPath, doorPatternPaint);
      
      // Decorative door handle/knocker
      final handlePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Color(0xFFDAA520).withAlpha((0.9 * 255).round()); // Gold
      
      canvas.drawCircle(
        Offset(middleX, doorCenterY + tulipSize * 0.6),
        doorWidth * 0.06,
        handlePaint
      );
      
      // Inner circle of handle
      canvas.drawCircle(
        Offset(middleX, doorCenterY + tulipSize * 0.6),
        doorWidth * 0.03,
        doorFillPaint // Dark center
      );
    }
    
    // Draw the shanyrak (the crown of the roof) with enhanced 3D effect
    final shanyraqShadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withAlpha((0.6 * 255).round())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    canvas.drawCircle(
      Offset(width / 2, roofTopY) + const Offset(3, 3),
      width * 0.08,
      shanyraqShadowPaint
    );
    
    final shanyraqPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: isLocked
          ? [Colors.grey.shade600, Colors.grey.shade800]
          : [Color(0xFF8D6E63), Color(0xFF5D4037)], // Brown wood shades
        radius: 0.7,
      ).createShader(Rect.fromCircle(
        center: Offset(width / 2, roofTopY),
        radius: width * 0.08,
      ));
    
    // Outer ring with more detailed woodgrain
    canvas.drawCircle(
      Offset(width / 2, roofTopY),
      width * 0.08,
      shanyraqPaint
    );
    
    // Inner circle of the shanyrak (sky opening) with atmospheric effect
    final skyPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: isLocked
          ? [Colors.grey.shade300, Colors.grey.shade500]
          : [Color(0xFF87CEEB), Color(0xFF1E90FF).withAlpha((0.7 * 255).round())], // Sky blue gradient
        radius: 0.7,
      ).createShader(Rect.fromCircle(
        center: Offset(width / 2, roofTopY),
        radius: width * 0.05,
      ));
    
    canvas.drawCircle(
      Offset(width / 2, roofTopY),
      width * 0.05,
      skyPaint
    );
    
    // Enhanced cross structure in shanyrak with more realistic wooden texture
    if (!isLocked) {
      final crossPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Color(0xFFD2B48C).withAlpha((0.8 * 255).round()) // Tan wood color
        ..strokeWidth = 1.2;
      
      // Draw more detailed cross structure
      for (int i = 0; i < 4; i++) {
        final angle = (i * pi / 4);
        
        final startX = width / 2 + cos(angle) * width * 0.02;
        final startY = roofTopY + sin(angle) * width * 0.02;
        
        final endX = width / 2 + cos(angle) * width * 0.07;
        final endY = roofTopY + sin(angle) * width * 0.07;
        
        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          crossPaint
        );
      }
    }
    
    // Enhanced ambient lighting effects with highlights
    // Top light reflection (simulating sunlight hitting the felt/roof)
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withAlpha((0.5 * 255).round())
      ..strokeWidth = 1.8;
    
    // Roof highlight enhanced to follow the curve of the roof
    final roofHighlightPath = Path();
    roofHighlightPath.moveTo(width * 0.25, height * 0.15);
    roofHighlightPath.quadraticBezierTo(
      width * 0.35, height * 0.07,
      width * 0.55, height * 0.12
    );
    
    canvas.drawPath(roofHighlightPath, highlightPaint);
    
    // Body highlight enhanced to follow the curve of the wall
    final bodyHighlightPath = Path();
    bodyHighlightPath.moveTo(width * 0.2, height * 0.45);
    bodyHighlightPath.quadraticBezierTo(
      width * 0.35, height * 0.42,
      width * 0.45, height * 0.45
    );
    
    // Create a new Paint object for the body highlight with a different stroke width
    final bodyHighlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withAlpha((0.5 * 255).round())
      ..strokeWidth = 1.0;
    
    canvas.drawPath(bodyHighlightPath, bodyHighlightPaint);
    
    // Add ambient occlusion (shadows where surfaces meet) for more realism
    final ambientOcclusionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withAlpha((0.3 * 255).round())
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    
    // Shadow where roof meets body
    canvas.drawLine(
      Offset(width * 0.15, roofBaseY),
      Offset(width * 0.85, roofBaseY),
      ambientOcclusionPaint
    );
    
    // Add level indicator in the center of the door
    if (!isLocked && !isCompleted) {
      // Number is added in the parent widget, centered on the door
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class QuizManager {
  final int levelNumber;
  final List<Question> questions;
  final int requiredCorrectAnswers;
  final double questionPercentage;
  final bool isMemoryTest;
  
  List<Question> _questionPool = [];
  List<Question> _questionQueue = [];
  int _consecutiveCorrectAnswers = 0;
  final Random _random = Random();

  QuizManager({
    required this.levelNumber,
    required this.questions,
    this.isMemoryTest = false,
  })  : // Define required correct answers for each level
        requiredCorrectAnswers = levelNumber <= 10 ? 10 :
                                (levelNumber == 11 ? 20 : 40),
        // Define question percentage for each level
        questionPercentage = levelNumber <= 6 ? 0.1 :
                             levelNumber == 7 ? 0.2 :
                             levelNumber == 8 ? 0.3 :
                             levelNumber == 9 ? 0.4 :
                             levelNumber <= 12 ? 1.0 : 1.0 {
    print('Деңгей $levelNumber үшін ${questions.length} сұрақ инициализацияланды');
    if (questions.isEmpty) {
      throw Exception('Бұл санат үшін сұрақтар жоқ! Санат атауы дұрыс екенін тексеріңіз.');
    }
    _initializeQuestionPool();
    _initializeQuestionQueue();
  }

  void _initializeQuestionPool() {
    // Create a copy of all questions
    List<Question> allQuestions = List.from(questions);
    
    if (isMemoryTest) {
      // For memory test, prioritize questions that were answered incorrectly
      allQuestions.sort((a, b) {
        if (a.wasAnsweredIncorrectly && !b.wasAnsweredIncorrectly) {
          return -1; // a comes first
        } else if (!a.wasAnsweredIncorrectly && b.wasAnsweredIncorrectly) {
          return 1; // b comes first
        } else {
          return 0; // no change in order
        }
      });
      
      // For memory test, use all available questions instead of a subset
      _questionPool = allQuestions;
      
      print('Using all ${_questionPool.length} questions for memory test');
    } else {
      // For regular levels, shuffle the questions
      allQuestions.shuffle(_random);
      
      // Calculate how many questions to include based on the percentage
      int numberOfQuestionsToInclude = (allQuestions.length * questionPercentage).ceil();
      // Make sure we include at least 10 questions or all available questions if less than 10
      numberOfQuestionsToInclude = min(max(numberOfQuestionsToInclude, 10), allQuestions.length);
      
      // Select the subset of questions for this level
      _questionPool = allQuestions.sublist(0, numberOfQuestionsToInclude);
      
      print('Selected ${_questionPool.length} questions (${(questionPercentage * 100).toStringAsFixed(0)}%) for level $levelNumber');
    }
  }

  void _initializeQuestionQueue() {
    // Start with an empty queue
    _questionQueue = [];
    
    // Add all questions from the pool to the queue
    _questionQueue.addAll(_questionPool);
    
    // Shuffle the queue
    _questionQueue.shuffle(_random);
    
    // Reset shuffled state for all questions
    for (var question in _questionQueue) {
      question.resetShuffledState();
    }
  }

  Question? getNextQuestion() {
    if (_questionQueue.isEmpty) {
      // If we've used all questions in the queue, reinitialize with the pool
      _initializeQuestionQueue();
      
      // If we still have no questions, return null
      if (_questionQueue.isEmpty) {
        return null;
      }
    }
    
    // Get a random question from the queue
    final index = _random.nextInt(_questionQueue.length);
    final question = _questionQueue[index];
    
    // For memory test, remove the question immediately to avoid repetition
    if (isMemoryTest) {
      _questionQueue.removeAt(index);
    }
    
    // Only reset the shuffled state if this is a new question (not currently displayed)
    if (!question.isCurrentlyDisplayed) {
      question.resetShuffledState();
    }
    
    print("New Question: ${question.text}, Correct Answer Index: ${question.currentCorrectIndex}");
    
    return question;
  }

  bool answerQuestion(Question question, int selectedOptionIndex) {
    // Store the result immediately to avoid different evaluations due to reshuffling
    final bool isCorrect = question.isCorrect(selectedOptionIndex);
    print("First check: Selected=$selectedOptionIndex, Correct=${question.currentCorrectIndex}, Question ID=${question.id}, IsCorrect=$isCorrect");
    
    // For memory test, don't track consecutive correct answers, just mark the question answered
    if (isMemoryTest) {
      // Prevent any further reshuffling by keeping this flag true
      question.isCurrentlyDisplayed = true;
      
      // Remove the question from the queue to avoid repetition
      _questionQueue.remove(question);
      
      return isCorrect;
    }
    
    // Regular learning mode behavior
    // Prevent further changes to the question options by freezing the question state
    if (isCorrect) {
      // Prevent any further reshuffling by keeping this flag true
      question.isCurrentlyDisplayed = true;
      
      _consecutiveCorrectAnswers++;
      
      // Remove the question from the queue temporarily to avoid immediate repetition
      _questionQueue.remove(question);
      
      // If queue is empty, reinitialize it
      if (_questionQueue.isEmpty) {
        _initializeQuestionQueue();
      }
    } else {
      // Reset consecutive correct answers counter for any wrong answer
      _consecutiveCorrectAnswers = 0;
      
      // Keep the isCurrentlyDisplayed flag true for incorrect answers
      // so the question doesn't get reshuffled when shown again
      question.isCurrentlyDisplayed = true;
    }

    return isCorrect;
  }

  bool get isLevelComplete {
    // Level is complete when the required number of consecutive correct answers is reached
    return _consecutiveCorrectAnswers >= requiredCorrectAnswers;
  }
  
  int get consecutiveCorrectAnswers => _consecutiveCorrectAnswers;
  
  void reset() {
    _consecutiveCorrectAnswers = 0;
    _initializeQuestionQueue();
  }
}

// Replace the getMockQuestionsForCategory function with:
List<Question> getMockQuestionsForCategory(String categoryName, {int? categoryId}) {
  print('Getting mock questions for category: $categoryName, ID: ${categoryId ?? "Not provided"}');
  
  if (categoryName == 'Сынақ алаңы' && categoryId != null) {
    print('Processing test area for category ID: $categoryId');
    
    // Create specific test area category name based on ID
    String specificCategoryName = categoryName;
    if (categoryId >= 200 && categoryId < 300) {
      specificCategoryName = 'Сынақ алаңы (Биология)';
      print('Using Biology test area');
    } else if (categoryId >= 100 && categoryId < 200) {
      specificCategoryName = 'Сынақ алаңы (Информатика)';
      print('Using Computer Science test area');
    } else {
      specificCategoryName = 'Сынақ алаңы (Тарих)';
      print('Using History test area');
    }
    
    // Use specific category name that includes subject identifier
    var questions = QuestionBank.getQuestionsForCategory(specificCategoryName);
    print('Retrieved ${questions.length} questions for $specificCategoryName');
    return questions;
  }
  
  // For regular categories, use the standard approach
  var questions = QuestionBank.getQuestionsForCategory(categoryName);
  print('Retrieved ${questions.length} questions');
  return questions;
}

class QuizPage extends StatefulWidget {
  final Level level;
  final Category category;

  const QuizPage({
    super.key,
    required this.level,
    required this.category,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  late QuizManager quizManager;
  late Question currentQuestion;
  int? selectedAnswerIndex;
  bool hasAnswered = false;
  late AnimationController _shakeController;
  bool isMemoryTest = false;
  int correctAnswers = 0;
  int totalAnswered = 0;
  // Add a list to track all question responses for review
  List<QuestionResponse> questionResponses = [];
  int totalQuestionsForTest = 20; // Default number of questions for the memory test
  bool isLoading = true;
  // Add state for test results
  List<TestResult> testResults = [];
  bool isLoadingResults = true;

  @override
  void initState() {
    super.initState();
    isMemoryTest = widget.category.name == 'Сынақ алаңы';
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initializeQuiz();
    
    if (isMemoryTest) {
      _loadTestResults();
    }
  }
  
  // Load test results from SharedPreferences
  Future<void> _loadTestResults() async {
    if (isMemoryTest) {
      // Determine the subject based on the category ID
      String subject = "History";
      if (widget.category.id >= 200 && widget.category.id < 300) {
        subject = "Biology";
      } else if (widget.category.id >= 100 && widget.category.id < 200) {
        subject = "ComputerScience";
      }
      
      final results = await TestResult.loadTestResults(subject: subject);
      setState(() {
        testResults = results;
        isLoadingResults = false;
      });
    }
  }
  
  // Build a section that displays the last 10 test results
  Widget _buildTestResultsSection() {
    // Determine subject title based on category ID
    String subjectTitle = "Тарих";
    if (widget.category.id >= 200 && widget.category.id < 300) {
      subjectTitle = "Биология";
    } else if (widget.category.id >= 100 && widget.category.id < 200) {
      subjectTitle = "Информатика";
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.blue.shade900.withAlpha((0.8 * 255).round()),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Соңғы 10 тест нәтижесі - $subjectTitle',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              isLoadingResults
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : testResults.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Тест нәтижелері әлі жоқ',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Күні',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Нәтиже',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Баға',
                                style: TextStyle(
                                  color: Colors.blue.shade100,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white30),
                        ...testResults.reversed.map((result) {
                          // Format the date as DD.MM.YYYY
                          final dateStr = '${result.date.day.toString().padLeft(2, '0')}.${result.date.month.toString().padLeft(2, '0')}.${result.date.year}';
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    dateStr,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${result.correctAnswers}/${result.totalQuestions} (${result.percentage.toStringAsFixed(1)}%)',
                                    style: const TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    result.grade,
                                    style: TextStyle(
                                      color: _getGradeColor(result.grade),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to get color based on grade
  Color _getGradeColor(String grade) {
    switch (grade[0]) {
      case 'A':
        return Colors.green.shade300;
      case 'B':
        return Colors.lightGreen.shade300;
      case 'C':
        return Colors.amber.shade300;
      case 'D':
        return Colors.orange.shade300;
      default:
        return Colors.red.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            isMemoryTest ? 'Сынақ алаңы' : 
            'Деңгей ${widget.level.id}'
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha((0.95 * 255).round()),
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Сұрақтар жүктелуде...'),
            ],
          ),
        ),
      );
    }

    // Get the category name for the current question
    String categoryName = QuestionResponse.getCategoryNameFromQuestionId(currentQuestion.id);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          isMemoryTest ? 'Сынақ алаңы' : 
          'Деңгей ${widget.level.id}'
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha((0.95 * 255).round()),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              if (isMemoryTest)
                Text(
                  'Тест прогресі: $totalAnswered/$totalQuestionsForTest сұрақ',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  'Дұрыс жауаптар: ${quizManager.consecutiveCorrectAnswers}/${quizManager.requiredCorrectAnswers}',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              Text(
                currentQuestion.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Display the image if available
              if (currentQuestion.imageAsset != null) ...[
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    currentQuestion.imageAsset!,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: ${currentQuestion.imageAsset}');
                      print('Error details: $error');
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 40),
                          SizedBox(height: 8),
                          Text('Image loading failed', style: TextStyle(color: Colors.red)),
                          SizedBox(height: 4),
                          Text('Path: ${currentQuestion.imageAsset}', 
                            style: TextStyle(fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
              ...List.generate(
                currentQuestion.currentOptions.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: selectedAnswerIndex == index && !currentQuestion.isCorrect(index)
                            ? Offset(sin(_shakeController.value * 2 * pi) * 10, 0)
                            : Offset.zero,
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: double.infinity, // Make all buttons full width
                      child: ElevatedButton(
                        onPressed: hasAnswered ? null : () => _handleAnswer(index),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (selectedAnswerIndex == index && hasAnswered) {
                              // Store whether this was correct in a local variable based on the current question
                              final bool wasCorrect = currentQuestion.isCorrect(index);
                              return wasCorrect ? Colors.green : Colors.red;
                            }
                            return Theme.of(context).colorScheme.primary;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            return Colors.white;
                          }),
                          padding: WidgetStateProperty.all(const EdgeInsets.all(16)),
                          // Ensure consistent shape and minimum size
                          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 54)),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                        ),
                        child: Text(
                          currentQuestion.currentOptions[index],
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Add the test results section if this is a memory test
              if (isMemoryTest) 
                _buildTestResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAnswer(int index) {
    if (hasAnswered) return;

    // Store the result immediately to avoid different evaluations due to reshuffling
    final bool isCorrect = quizManager.answerQuestion(currentQuestion, index);

    // Mark this question as answered incorrectly if needed
    if (!isCorrect) {
      currentQuestion.wasAnsweredIncorrectly = true;
    }

    // Track progress differently for memory test
    if (isMemoryTest) {
      if (isCorrect) {
        correctAnswers++;
      }
      totalAnswered++;
      
      // Store the response for review
      questionResponses.add(QuestionResponse(
        question: currentQuestion,
        selectedOptionIndex: index,
        isCorrect: isCorrect,
        categoryName: QuestionResponse.getCategoryNameFromQuestionId(currentQuestion.id),
      ));
    }

    setState(() {
      selectedAnswerIndex = index;
      hasAnswered = true;
      print("Selected Index: $selectedAnswerIndex, Current Question's Correct Index: ${currentQuestion.currentCorrectIndex}");
    });

    if (!isCorrect) {
      _shakeController.forward(from: 0);
    }

    Future.delayed(const Duration(seconds: 1), () {
      // Regular study level completion
      if (!isMemoryTest && quizManager.isLevelComplete) {
        widget.category.completeLevel(widget.level.id);
        Navigator.pop(context);
        return;
      }
      
      // For memory test, show results when enough questions answered
      if (isMemoryTest && totalAnswered >= totalQuestionsForTest) {
        _showMemoryTestResults();
        return;
      }

      // Only proceed to the next question if:
      // 1. This is the memory test (last category) OR
      // 2. The answer was correct
      if (isMemoryTest || isCorrect) {
      setState(() {
          // Get the next question
        Question? nextQuestion = quizManager.getNextQuestion();
        if (nextQuestion != null) {
          currentQuestion = nextQuestion;
        } else if (isMemoryTest) {
          // If we've run out of questions for the memory test before reaching totalQuestionsForTest,
          // show the results anyway
          _showMemoryTestResults();
          return;
        }
        selectedAnswerIndex = null;
        hasAnswered = false;
      });
      } else {
        // For categories 1-7, if the answer was incorrect, 
        // just reset the answer state to allow the user to try again
        setState(() {
          selectedAnswerIndex = null;
          hasAnswered = false;
        });
      }
    });
  }
  
  void _showMemoryTestResults() {
    final double percentage = (correctAnswers / totalAnswered) * 100;
    final String grade = percentage >= 90 ? 'A+' : 
                         percentage >= 80 ? 'A' : 
                         percentage >= 70 ? 'B' : 
                         percentage >= 60 ? 'C' : 
                         percentage >= 50 ? 'D' : 'F';
    
    // Determine the subject based on the category ID
    String subject = "History";
    if (widget.category.id >= 200 && widget.category.id < 300) {
      subject = "Biology";
    } else if (widget.category.id >= 100 && widget.category.id < 200) {
      subject = "ComputerScience";
    }
    
    // Save the test result
    final testResult = TestResult(
      date: DateTime.now(),
      correctAnswers: correctAnswers,
      totalQuestions: totalAnswered,
      percentage: percentage,
      grade: grade,
      subject: subject,
    );
    
    TestResult.saveTestResult(testResult);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Жаттау тесті нәтижелері'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Дұрыс жауаптар: $correctAnswers из $totalAnswered'),
            const SizedBox(height: 8),
            Text('Пайыз: ${percentage.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Баға: $grade', style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: percentage >= 70 ? Colors.green : (percentage >= 50 ? Colors.orange : Colors.red),
            )),
            const SizedBox(height: 16),
            Text(
              'Нәтижелерді төменде қарауға болады. Қате жауап берген сұрақтарға назар аударыңыз.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // No need to mark level as completed for pure assessment
              // Show review screen directly
              Navigator.of(context).pop();
              _showReviewScreen();
            },
            child: const Text('Нәтижелерді қарау'),
          ),
        ],
      ),
    );
  }
  
  void _showReviewScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestReviewScreen(
          responses: questionResponses,
          totalCorrect: correctAnswers,
          totalQuestions: totalAnswered,
          categoryId: widget.category.id, // Pass the category ID
        ),
      ),
    ).then((_) => Navigator.pop(context)); // Return to category screen after review
  }

  Future<void> _initializeQuiz() async {
    try {
      // Debug: Print category information
      print('Initializing quiz for category: ${widget.category.name}, ID: ${widget.category.id}');
      print('Current context: ${widget.level.id}, IsBiologyTest: ${widget.category.id >= 200 && widget.category.id < 300}');
      
      // Get questions for this category
      final questions = getMockQuestionsForCategory(widget.category.name, categoryId: widget.category.id);
      
      // Print debug info about the questions
      print('Got ${questions.length} questions, first ID range: ${questions.isNotEmpty ? questions.first.id ~/ 1000 : "None"}');
      
      // For memory test, adjust the number of questions based on what's available
      if (isMemoryTest && questions.length > 0) {
        // Use at most 30 questions, but no more than what's available 
        totalQuestionsForTest = questions.length > 30 ? 30 : questions.length;
      }

      quizManager = QuizManager(
        levelNumber: widget.level.id,
        questions: questions,
        isMemoryTest: isMemoryTest,
      );
      
      currentQuestion = quizManager.getNextQuestion()!;
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error initializing quiz: $e');
      // Show an error dialog and return to previous screen
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Қате'),
            content: Text('Сұрақтарды жүктеу кезінде қате пайда болды: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Артқа'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
}

class TestReviewScreen extends StatefulWidget {
  final List<QuestionResponse> responses;
  final int totalCorrect;
  final int totalQuestions;
  final int categoryId; // Add categoryId to track which subject this is

  const TestReviewScreen({
    super.key,
    required this.responses,
    required this.totalCorrect, 
    required this.totalQuestions,
    required this.categoryId, // Add to constructor
  });

  @override
  State<TestReviewScreen> createState() => _TestReviewScreenState();
}

class _TestReviewScreenState extends State<TestReviewScreen> {
  // Group responses by category
  late Map<String, List<QuestionResponse>> categorizedResponses;
  List<String> categories = [];
  String? selectedCategory;
  bool showOnlyIncorrect = false;

  @override
  void initState() {
    super.initState();
    _categorizeResponses();
  }

  void _categorizeResponses() {
    categorizedResponses = {};
    
    // Group responses by category
    for (var response in widget.responses) {
      if (!categorizedResponses.containsKey(response.categoryName)) {
        categorizedResponses[response.categoryName] = [];
      }
      categorizedResponses[response.categoryName]!.add(response);
    }
    
    // Sort categories by name
    categories = categorizedResponses.keys.toList()..sort();
    
    // Set initial selected category
    selectedCategory = categories.isNotEmpty ? categories.first : null;
  }

  @override
  Widget build(BuildContext context) {
    // Determine subject title based on category ID
    String subjectTitle = "Тарих";
    if (widget.categoryId >= 200 && widget.categoryId < 300) {
      subjectTitle = "Биология";
    } else if (widget.categoryId >= 100 && widget.categoryId < 200) {
      subjectTitle = "Информатика";
    }
    
    List<QuestionResponse> displayedResponses = [];
    
    if (selectedCategory != null) {
      displayedResponses = categorizedResponses[selectedCategory]!;
    } else {
      displayedResponses = widget.responses;
    }
    
    // Filter to show only incorrect answers if needed
    if (showOnlyIncorrect) {
      displayedResponses = displayedResponses.where((r) => !r.isCorrect).toList();
    }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('$subjectTitle: Тест нәтижелері'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha((0.95 * 255).round()),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        // Use MediaQuery.removePadding to control which edges have padding
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true, // Remove top padding since AppBar already handles it
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Жалпы нәтиже: ${widget.totalCorrect}/${widget.totalQuestions}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Пайыз: ${(widget.totalCorrect / widget.totalQuestions * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategory,
                        hint: const Text('Барлық санаттар'),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Барлық санаттар'),
                          ),
                          ...categories.map<DropdownMenuItem<String>>((String category) {
                            // Count total and correct answers for this category
                            int total = categorizedResponses[category]!.length;
                            int correct = categorizedResponses[category]!.where((r) => r.isCorrect).length;
                            
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text('$category ($correct/$total)'),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: showOnlyIncorrect,
                          onChanged: (bool? value) {
                            setState(() {
                              showOnlyIncorrect = value ?? false;
                            });
                          },
                        ),
                        const Text('Тек қате жауаптар'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: displayedResponses.isEmpty
                    ? const Center(
                        child: Text('Сұрақтар табылмады'),
                      )
                    : ListView.builder(
                        itemCount: displayedResponses.length,
                        itemBuilder: (context, index) {
                          final response = displayedResponses[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              elevation: 2,
                              color: response.isCorrect 
                                  ? Colors.green.shade50 
                                  : Colors.red.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          response.isCorrect ? Icons.check_circle : Icons.cancel,
                                          color: response.isCorrect ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            response.question.text,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Hide category display
                                    /*Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50, 
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: Text(
                                        'Санат: ${response.categoryName}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),*/
                                    const SizedBox(height: 16),
                                    // Display image if available
                                    if (response.question.imageAsset != null) ...[
                                      Center(
                                        child: Container(
                                          height: 180,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Image.asset(
                                            response.question.imageAsset!,
                                            height: 180,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading image in review: ${response.question.imageAsset}');
                                              print('Error details: $error');
                                              return Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.error, color: Colors.red, size: 40),
                                                  SizedBox(height: 8),
                                                  Text('Image loading failed', style: TextStyle(color: Colors.red)),
                                                  SizedBox(height: 4),
                                                  Text('Path: ${response.question.imageAsset}', 
                                                    style: TextStyle(fontSize: 10),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    ...List.generate(
                                      response.question.options.length,
                                      (index) {
                                        bool isSelected = index == response.selectedOptionIndex;
                                        bool isCorrect = index == response.question.correctOptionIndex;
                                        
                                        Color textColor = Colors.black;
                                        if (isSelected && !isCorrect) {
                                          textColor = Colors.red;
                                        } else if (isCorrect) {
                                          textColor = Colors.green;
                                        }
                                        
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 24,
                                                child: isSelected 
                                                    ? const Icon(Icons.radio_button_checked, size: 16)
                                                    : const Icon(Icons.radio_button_unchecked, size: 16),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  response.question.options[index],
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 24,
                                                child: isCorrect
                                                    ? const Icon(Icons.check, color: Colors.green, size: 16)
                                                    : const SizedBox(),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ComputerScienceLearningPathPage extends StatefulWidget {
  const ComputerScienceLearningPathPage({super.key});

  @override
  State<ComputerScienceLearningPathPage> createState() => _ComputerScienceLearningPathPageState();
}

class _ComputerScienceLearningPathPageState extends State<ComputerScienceLearningPathPage> {
  late List<Category> categories;
  bool isLoading = true;

  double get totalProgress {
    if (categories.isEmpty) return 0.0;
    double totalCompletedLevels = categories
        .map((category) => category.completedLevels)
        .fold(0, (sum, levels) => sum + levels);
    
    double totalPossibleLevels = categories
        .map((category) => category.totalLevels)
        .fold(0, (sum, levels) => sum + levels);
    
    return totalPossibleLevels > 0 ? (totalCompletedLevels / totalPossibleLevels) : 0.0;
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _clearAllCategoryData() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 101; i <= 110; i++) {
      await prefs.remove('category_$i');
    }
    print('All Computer Science category data has been cleared');
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Initialize with default categories for Computer Science
    categories = [
      Category(name: 'Алгоритмдер негіздері', displayName: 'Алгоритмдер негіздері', id: 101, isLocked: false, completedLevels: 0),
      Category(name: 'Деректер құрылымдары', displayName: 'Деректер құрылымдары', id: 102, isLocked: false, completedLevels: 0),
      Category(name: 'Үшінші тарау', displayName: 'Бағдарламалау тілдері', id: 103, isLocked: false, completedLevels: 0),
      Category(name: 'Төртінші тарау', displayName: 'Дерекқорлар', id: 104, isLocked: false, completedLevels: 0),
      Category(name: 'Бесінші тарау', displayName: 'Желілер мен интернет', id: 105, isLocked: false, completedLevels: 0),
      Category(name: 'Алтыншы тарау', displayName: 'Жасанды интеллект', id: 106, isLocked: false, completedLevels: 0),
      Category(name: 'Жалпы жаттығу', id: 109, isLocked: false, completedLevels: 0),
      Category(name: 'Сынақ алаңы', displayName: 'Сынақ алаңы', id: 110, isLocked: false, completedLevels: 0, totalLevels: 1),
    ];

    // Load saved progress for each category
    for (int i = 0; i < categories.length; i++) {
      final savedCategory = await Category.loadProgress(categories[i].id);
      if (savedCategory != null) {
        categories[i] = savedCategory;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Информатика'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha((0.95 * 255).round()),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Барлық деректерді тазарту'),
                  content: const Text('Барлық категориялардың прогресін тазалауды қалайсыз ба?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Жоқ'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearAllCategoryData();
                      },
                      child: const Text('Иә'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withAlpha((0.7 * 255).round()),
                          Theme.of(context).colorScheme.secondary.withAlpha((0.7 * 255).round()),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.1 * 255).round()),
                          blurRadius: 8,
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
                              'Жалпы прогресс',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${(totalProgress * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withAlpha((0.2 * 255).round()),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: totalProgress,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${categories.fold(0, (sum, c) => sum + c.completedLevels)}/${categories.fold(0, (sum, c) => sum + c.totalLevels)} деңгей',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha((0.9 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Оқу үрдісі',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LearningPathGrid(categories: categories),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BiologyLearningPathPage extends StatefulWidget {
  const BiologyLearningPathPage({super.key});

  @override
  State<BiologyLearningPathPage> createState() => _BiologyLearningPathPageState();
}

class _BiologyLearningPathPageState extends State<BiologyLearningPathPage> {
  late List<Category> categories;
  bool isLoading = true;

  double get totalProgress {
    if (categories.isEmpty) return 0.0;
    double totalCompletedLevels = categories
        .map((category) => category.completedLevels)
        .fold(0, (sum, levels) => sum + levels);
    
    double totalPossibleLevels = categories
        .map((category) => category.totalLevels)
        .fold(0, (sum, levels) => sum + levels);
    
    return totalPossibleLevels > 0 ? (totalCompletedLevels / totalPossibleLevels) : 0.0;
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _clearAllCategoryData() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 201; i <= 210; i++) {
      await prefs.remove('category_$i');
    }
    print('All Biology category data has been cleared');
    await _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Initialize with default categories for Biology
    categories = [
      Category(name: 'Бірінші тарау (Биология)', displayName: 'Бірінші тарау', id: 201, isLocked: false, completedLevels: 0),
      Category(name: 'Екінші тарау (Биология)', displayName: 'Екінші тарау', id: 202, isLocked: false, completedLevels: 0),
      Category(name: 'Үшінші тарау (Биология)', displayName: 'Үшінші тарау', id: 203, isLocked: false, completedLevels: 0),
      Category(name: 'Төртінші тарау (Биология)', displayName: 'Төртінші тарау', id: 204, isLocked: false, completedLevels: 0),
      Category(name: 'Жалпы жаттығу (Биология)', displayName: 'Жалпы жаттығу', id: 209, isLocked: false, completedLevels: 0),
      Category(name: 'Сынақ алаңы', displayName: 'Сынақ алаңы', id: 210, isLocked: false, completedLevels: 0, totalLevels: 1),
    ];

    // Load saved progress for each category
    for (int i = 0; i < categories.length; i++) {
      final savedCategory = await Category.loadProgress(categories[i].id);
      if (savedCategory != null) {
        categories[i] = savedCategory;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Биология'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withAlpha((0.95 * 255).round()),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Барлық деректерді тазарту'),
                  content: const Text('Барлық категориялардың прогресін тазалауды қалайсыз ба?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Жоқ'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearAllCategoryData();
                      },
                      child: const Text('Иә'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withAlpha((0.7 * 255).round()),
                          Theme.of(context).colorScheme.secondary.withAlpha((0.7 * 255).round()),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.1 * 255).round()),
                          blurRadius: 8,
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
                              'Жалпы прогресс',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${(totalProgress * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white.withAlpha((0.2 * 255).round()),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: totalProgress,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${categories.fold(0, (sum, c) => sum + c.completedLevels)}/${categories.fold(0, (sum, c) => sum + c.totalLevels)} деңгей',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha((0.9 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Оқу үрдісі',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LearningPathGrid(categories: categories),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
