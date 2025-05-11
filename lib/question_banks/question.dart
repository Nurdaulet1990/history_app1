import 'dart:math';

class Question {
  final int id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;
  final String? imageAsset; // Optional image asset path
  bool wasAnsweredIncorrectly = false;
  // Add a flag to track if this question is currently being displayed
  bool isCurrentlyDisplayed = false;
  
  // Store shuffled state
  List<String> _shuffledOptions;
  int _currentCorrectIndex;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    this.imageAsset, // Optional parameter for image references
  }) : _shuffledOptions = List<String>.from(options),
       _currentCorrectIndex = correctOptionIndex {
    // Initialize shuffled state immediately
    _initializeShuffledState();
  }

  void _initializeShuffledState() {
    // Don't reshuffle if the question is currently being displayed
    if (isCurrentlyDisplayed) {
      return;
    }
    
    final indices = List<int>.generate(options.length, (i) => i);
    indices.shuffle(Random());

    // Create new shuffled options list
    final tempOptions = List<String>.from(options);
    
    // Reset the current correct index
    _currentCorrectIndex = -1;
    
    for (int i = 0; i < options.length; i++) {
      _shuffledOptions[i] = tempOptions[indices[i]];
      if (indices[i] == correctOptionIndex) {
        _currentCorrectIndex = i;
      }
    }
    
    // Validate that we found the correct index
    if (_currentCorrectIndex == -1) {
      print("ERROR: Failed to map correct index during shuffle for question $id");
      // In case of error, set to first option as fallback (though this shouldn't happen)
      _currentCorrectIndex = 0;
    }
    
    print("Shuffled options for question $id. New correct index: $_currentCorrectIndex");
  }

  bool isCorrect(int selectedIndex) {
    // Mark this question as currently displayed when checking answers
    isCurrentlyDisplayed = true;
    
    // Add debug print to track comparisons
    print("Answer Check: Selected=$selectedIndex, Correct=${_currentCorrectIndex}, Question ID=${id}");
    
    // Validate that _currentCorrectIndex is in a valid range
    if (_currentCorrectIndex < 0 || _currentCorrectIndex >= options.length) {
      print("ERROR: Invalid current correct index: $_currentCorrectIndex for question $id");
      // Fallback to original correctOptionIndex if _currentCorrectIndex is invalid
      return selectedIndex == correctOptionIndex;
    }
    
    bool result = selectedIndex == _currentCorrectIndex;
    print("FINAL ANSWER: $result for question $id (selected=$selectedIndex, correct=${_currentCorrectIndex})");
    return result;
  }

  List<String> get currentOptions => List<String>.from(_shuffledOptions);
  
  int get currentCorrectIndex => _currentCorrectIndex;

  // Reset shuffled state when needed (e.g., when question reappears)
  void resetShuffledState() {
    // Only reshuffle if not currently displayed or processed
    if (!isCurrentlyDisplayed) {
      print("RESHUFFLING question $id (not currently displayed)");
      _initializeShuffledState();
    } else {
      print("SKIPPING RESHUFFLE for question $id (currently displayed)");
    }
  }
} 