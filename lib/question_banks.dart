import 'question_banks/question.dart';
export 'question_banks/question.dart';
import 'dart:math' as math;

// History imports
import 'question_banks/first_chapter.dart';
import 'question_banks/second_chapter.dart';
import 'question_banks/third_chapter.dart';
import 'question_banks/fourth_chapter.dart';
import 'question_banks/fifth_chapter.dart';
import 'question_banks/sixth_chapter.dart';

// Computer Science imports
import 'question_banks/cs_first_chapter.dart';
import 'question_banks/cs_second_chapter.dart';

// Biology imports
import 'question_banks/bio_first_chapter.dart';
import 'question_banks/bio_second_chapter.dart';
import 'question_banks/bio_third_chapter.dart';
import 'question_banks/bio_fourth_chapter.dart';

// Main QuestionBank class that delegates to specific subject banks
class QuestionBank {
  static List<Question> getQuestionsForCategory(String categoryName) {
    print('Getting questions for category: $categoryName');
    List<Question> questions = [];
    
    try {
      // Check for specific test area identifiers
      if (categoryName == 'Сынақ алаңы (Биология)') {
        print('Using Biology question bank for test area');
        return BiologyQuestionBank.getQuestionsForCategory('Сынақ алаңы');
      } else if (categoryName == 'Сынақ алаңы (Информатика)') {
        print('Using Computer Science question bank for test area');
        return ComputerScienceQuestionBank.getQuestionsForCategory('Сынақ алаңы');
      } else if (categoryName == 'Сынақ алаңы (Тарих)') {
        print('Using History question bank for test area');
        return HistoryQuestionBank.getQuestionsForCategory('Сынақ алаңы');
      }
      
      // Extract category ID from the categoryName if it ends with a number
      int categoryId = 0;
      if (categoryName == 'Сынақ алаңы') {
        categoryId = getCategoryIdFromCall();
        print('Test area detected, using categoryId: $categoryId from call stack');
      }
      
      // Determine which subject question bank to use
      if (categoryName.contains('(Тарих)') || 
          (categoryName == 'Сынақ алаңы' && (categoryId == 10 || categoryId < 100))) {
        // History questions
        print('Using History question bank');
        questions = HistoryQuestionBank.getQuestionsForCategory(categoryName);
      } else if (categoryName.contains('(Биология)') || 
                (categoryName == 'Сынақ алаңы' && (categoryId == 210 || (categoryId >= 200 && categoryId < 300)))) {
        // Biology questions
        print('Using Biology question bank');
        questions = BiologyQuestionBank.getQuestionsForCategory(categoryName);
      } else if (categoryName.contains('Алгоритмдер') || categoryName.contains('Деректер') || 
                (categoryName == 'Сынақ алаңы' && (categoryId == 110 || (categoryId >= 100 && categoryId < 200)))) {
        // Computer Science questions
        print('Using Computer Science question bank');
        questions = ComputerScienceQuestionBank.getQuestionsForCategory(categoryName);
      } else {
        print('Warning: No matching subject found for: $categoryName, ID: $categoryId');
      }
    } catch (e) {
      print('Error loading questions for category $categoryName: $e');
    }
    
    print('Found ${questions.length} questions for category: $categoryName');
    if (questions.isEmpty) {
      print('Warning: No questions found for category: $categoryName');
    }
    
    return questions;
  }
  
  // Helper method to get the category ID from the call stack
  static int getCategoryIdFromCall() {
    try {
      // Try to parse the stack trace to find a category ID
      final stack = StackTrace.current.toString();
      print("DEBUG - Stack trace in getCategoryIdFromCall: ${stack.substring(0, math.min(500, stack.length))}");
      
      if (stack.contains('id: 110') || stack.contains('ComputerScience')) {
        print("DEBUG - Detected Computer Science test");
        return 110; // Computer Science test
      } else if (stack.contains('id: 210') || stack.contains('(Биология)') || 
                stack.contains('Biology') || stack.contains("category.id: 210")) {
        print("DEBUG - Detected Biology test");
        return 210; // Biology test
      } else if (stack.contains('id: 10') || stack.contains('(Тарих)') || 
                stack.contains('History') || stack.contains("category.id: 10")) {
        print("DEBUG - Detected History test");
        return 10; // History test
      }
    } catch (e) {
      print('Error getting category ID: $e');
    }
    
    print("DEBUG - No specific test detected, defaulting to history");
    // Default to history
    return 10;
  }
  
  // Helper method to ensure all question IDs are unique by adding a prefix
  static List<Question> _ensureUniqueIds(List<Question> questions, int prefix) {
    return questions.map((question) {
      // If ID is already in the correct range (has prefix), keep it
      if (question.id >= prefix && question.id < prefix + 1000) {
        return question;
      }
      
      // Otherwise create a new question with the correct ID prefix
      return Question(
        id: prefix + (question.id % 1000), // Make sure smaller IDs fit in the range
        text: question.text,
        options: question.options,
        correctOptionIndex: question.correctOptionIndex,
        imageAsset: question.imageAsset,
      );
    }).toList();
  }
}

// History specific question bank
class HistoryQuestionBank {
  static List<Question> getQuestionsForCategory(String categoryName) {
    List<Question> questions = [];
    
    switch (categoryName) {
      case 'Бірінші тарау (Тарих)':
        questions = QuestionBank._ensureUniqueIds(firstChapterQuestions, 1000);
        break;
      case 'Екінші тарау (Тарих)':
        questions = QuestionBank._ensureUniqueIds(secondChapterQuestions, 2000);
        break;
      case 'Үшінші тарау (Тарих)':
        questions = QuestionBank._ensureUniqueIds(thirdChapterQuestions, 3000);
        break;
      case 'Төртінші тарау (Тарих)':
        questions = QuestionBank._ensureUniqueIds(fourthChapterQuestions, 4000);
        break;
      case 'Бесінші тарау (Тарих)':
        questions = QuestionBank._ensureUniqueIds(fifthChapterQuestions, 5000);
        break;
      case 'Алтыншы тарау (Тарих)':
        questions = QuestionBank._ensureUniqueIds(sixthChapterQuestions, 6000);
        break;
      case 'Жалпы жаттығу (Тарих)':
        // For general practice, combine questions from all chapters
        questions = [
          ...QuestionBank._ensureUniqueIds(firstChapterQuestions, 1000),
          ...QuestionBank._ensureUniqueIds(secondChapterQuestions, 2000),
          ...QuestionBank._ensureUniqueIds(thirdChapterQuestions, 3000),
          ...QuestionBank._ensureUniqueIds(fourthChapterQuestions, 4000),
          ...QuestionBank._ensureUniqueIds(fifthChapterQuestions, 5000),
          ...QuestionBank._ensureUniqueIds(sixthChapterQuestions, 6000),
        ];
        break;
      case 'Сынақ алаңы':
        // History test area
        List<Question> allHistoryQuestions = [
          ...QuestionBank._ensureUniqueIds(firstChapterQuestions, 1000),
          ...QuestionBank._ensureUniqueIds(secondChapterQuestions, 2000),
          ...QuestionBank._ensureUniqueIds(thirdChapterQuestions, 3000),
          ...QuestionBank._ensureUniqueIds(fourthChapterQuestions, 4000),
          ...QuestionBank._ensureUniqueIds(fifthChapterQuestions, 5000),
          ...QuestionBank._ensureUniqueIds(sixthChapterQuestions, 6000),
        ];
        
        allHistoryQuestions.shuffle();
        allHistoryQuestions.sort((a, b) {
          if (a.wasAnsweredIncorrectly && !b.wasAnsweredIncorrectly) {
            return -1;
          } else if (!a.wasAnsweredIncorrectly && b.wasAnsweredIncorrectly) {
            return 1;
          } else {
            return 0;
          }
        });
        
        questions = allHistoryQuestions;
        break;
      default:
        print('Warning: No matching history category found for: $categoryName');
    }
    
    return questions;
  }
}

// Biology specific question bank
class BiologyQuestionBank {
  static List<Question> getQuestionsForCategory(String categoryName) {
    List<Question> questions = [];
    
    switch (categoryName) {
      case 'Бірінші тарау (Биология)':
        questions = QuestionBank._ensureUniqueIds(bioFirstChapterQuestions, 201000);
        break;
      case 'Екінші тарау (Биология)':
        questions = QuestionBank._ensureUniqueIds(bioSecondChapterQuestions, 202000);
        break;
      case 'Үшінші тарау (Биология)':
        questions = QuestionBank._ensureUniqueIds(bioThirdChapterQuestions, 203000);
        break;
      case 'Төртінші тарау (Биология)':
        questions = QuestionBank._ensureUniqueIds(bioFourthChapterQuestions, 204000);
        break;
      case 'Жалпы жаттығу (Биология)':
        // For general practice, combine questions from all biology chapters
        questions = [
          ...QuestionBank._ensureUniqueIds(bioFirstChapterQuestions, 201000),
          ...QuestionBank._ensureUniqueIds(bioSecondChapterQuestions, 202000),
          ...QuestionBank._ensureUniqueIds(bioThirdChapterQuestions, 203000),
          ...QuestionBank._ensureUniqueIds(bioFourthChapterQuestions, 204000),
        ];
        break;
      case 'Сынақ алаңы':
        // Biology test area
        List<Question> allBioQuestions = [
          ...QuestionBank._ensureUniqueIds(bioFirstChapterQuestions, 201000),
          ...QuestionBank._ensureUniqueIds(bioSecondChapterQuestions, 202000),
          ...QuestionBank._ensureUniqueIds(bioThirdChapterQuestions, 203000),
          ...QuestionBank._ensureUniqueIds(bioFourthChapterQuestions, 204000),
        ];
        
        // First shuffle all questions randomly
        allBioQuestions.shuffle();
        
        // Sort incorrectly answered questions to appear first
        allBioQuestions.sort((a, b) {
          if (a.wasAnsweredIncorrectly && !b.wasAnsweredIncorrectly) {
            return -1;
          } else if (!a.wasAnsweredIncorrectly && b.wasAnsweredIncorrectly) {
            return 1;
          } else {
            return 0;
          }
        });
        
        // Ensure we have a good mix of questions from each chapter
        final int questionsPerChapter = (allBioQuestions.length / 4).ceil();
        Map<int, List<Question>> chapterQuestions = {
          201: [], // First chapter
          202: [], // Second chapter
          203: [], // Third chapter
          204: [], // Fourth chapter
        };
        
        // Group questions by chapter
        for (var question in allBioQuestions) {
          int chapterId = (question.id ~/ 1000);
          if (chapterQuestions.containsKey(chapterId)) {
            chapterQuestions[chapterId]!.add(question);
          }
        }
        
        // Create a balanced selection of questions
        List<Question> balancedQuestions = [];
        for (var chapterList in chapterQuestions.values) {
          if (chapterList.isNotEmpty) {
            chapterList.shuffle(); // Shuffle each chapter's questions
            balancedQuestions.addAll(
              chapterList.take(questionsPerChapter)
            );
          }
        }
        
        // Final shuffle of the balanced selection
        balancedQuestions.shuffle();
        
        questions = balancedQuestions;
        break;
      default:
        print('Warning: No matching biology category found for: $categoryName');
    }
    
    return questions;
  }
}

// Computer Science specific question bank
class ComputerScienceQuestionBank {
  static List<Question> getQuestionsForCategory(String categoryName) {
    List<Question> questions = [];
    
    switch (categoryName) {
      case 'Алгоритмдер негіздері':
        questions = QuestionBank._ensureUniqueIds(csFirstChapterQuestions, 101000);
        break;
      case 'Деректер құрылымдары':
        questions = QuestionBank._ensureUniqueIds(csSecondChapterQuestions, 102000);
        break;
      case 'Сынақ алаңы':
        // Computer Science test area
        List<Question> allCsQuestions = [
          ...QuestionBank._ensureUniqueIds(csFirstChapterQuestions, 101000),
          ...QuestionBank._ensureUniqueIds(csSecondChapterQuestions, 102000),
        ];
        
        allCsQuestions.shuffle();
        allCsQuestions.sort((a, b) {
          if (a.wasAnsweredIncorrectly && !b.wasAnsweredIncorrectly) {
            return -1;
          } else if (!a.wasAnsweredIncorrectly && b.wasAnsweredIncorrectly) {
            return 1;
          } else {
            return 0;
          }
        });
        
        questions = allCsQuestions;
        break;
      default:
        print('Warning: No matching computer science category found for: $categoryName');
    }
    
    return questions;
  }
} 