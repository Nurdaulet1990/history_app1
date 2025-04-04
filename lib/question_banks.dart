import 'question_banks/question.dart';
export 'question_banks/question.dart';
import 'question_banks/first_chapter.dart';
import 'question_banks/second_chapter.dart';
import 'question_banks/third_chapter.dart';
import 'question_banks/fourth_chapter.dart';
import 'question_banks/fifth_chapter.dart';
import 'question_banks/sixth_chapter.dart';

class QuestionBank {
  static List<Question> getQuestionsForCategory(String categoryName) {
    print('Getting questions for category: $categoryName');
    List<Question> questions;
    
    try {
      // Get questions based on category name
      switch (categoryName) {
        case 'Бірінші тарау':
          questions = _ensureUniqueIds(firstChapterQuestions, 1000);
          break;
        case 'Екінші тарау':
          questions = _ensureUniqueIds(secondChapterQuestions, 2000);
          break;
        case 'Үшінші тарау':
          questions = _ensureUniqueIds(thirdChapterQuestions, 3000);
          break;
        case 'Төртінші тарау':
          questions = _ensureUniqueIds(fourthChapterQuestions, 4000);
          break;
        case 'Бесінші тарау':
          questions = _ensureUniqueIds(fifthChapterQuestions, 5000);
          break;
        case 'Алтыншы тарау':
          questions = _ensureUniqueIds(sixthChapterQuestions, 6000);
          break;
        case 'Жалпы жаттығу':
          // For general practice, combine questions from all chapters
          questions = [
            ..._ensureUniqueIds(firstChapterQuestions, 1000),
            ..._ensureUniqueIds(secondChapterQuestions, 2000),
            ..._ensureUniqueIds(thirdChapterQuestions, 3000),
            ..._ensureUniqueIds(fourthChapterQuestions, 4000),
            ..._ensureUniqueIds(fifthChapterQuestions, 5000),
            ..._ensureUniqueIds(sixthChapterQuestions, 6000),
          ];
          break;
        case 'Сынақ алаңы':
          // For test area, combine all questions from all chapters
          List<Question> allQuestions = [
            ..._ensureUniqueIds(firstChapterQuestions, 1000),
            ..._ensureUniqueIds(secondChapterQuestions, 2000),
            ..._ensureUniqueIds(thirdChapterQuestions, 3000),
            ..._ensureUniqueIds(fourthChapterQuestions, 4000),
            ..._ensureUniqueIds(fifthChapterQuestions, 5000),
            ..._ensureUniqueIds(sixthChapterQuestions, 6000),
          ];
          
          // Shuffle the questions to ensure randomness
          allQuestions.shuffle();
          
          // Prioritize questions that were previously answered incorrectly but keep random order
          allQuestions.sort((a, b) {
            if (a.wasAnsweredIncorrectly && !b.wasAnsweredIncorrectly) {
              return -1; // a comes first
            } else if (!a.wasAnsweredIncorrectly && b.wasAnsweredIncorrectly) {
              return 1; // b comes first
            } else {
              return 0; // no change in order
            }
          });
          
          questions = allQuestions;
          break;
        default:
          print('Warning: No matching category found for: $categoryName');
          questions = [];
      }
    } catch (e) {
      print('Error loading questions for category $categoryName: $e');
      questions = [];
    }
    
    print('Found ${questions.length} questions for category: $categoryName');
    if (questions.isEmpty) {
      print('Warning: No questions found for category: $categoryName');
    }
    
    return questions;
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
      );
    }).toList();
  }
} 