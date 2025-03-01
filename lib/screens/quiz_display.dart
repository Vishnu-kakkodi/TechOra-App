import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/quiz_model.dart';
import 'package:project/screens/quiz_result_screen.dart';

class QuizParticipationScreen extends StatefulWidget {
  final Quiz quizData;
  
  const QuizParticipationScreen({
    Key? key, 
    required this.quizData,
  }) : super(key: key);

  @override
  State<QuizParticipationScreen> createState() => _QuizParticipationScreenState();
}

class _QuizParticipationScreenState extends State<QuizParticipationScreen> {
  // Question management
  int _currentQuestionIndex = 0;
  List<Question> _questions = [];
  Map<int, int> _userAnswers = {}; // Maps question index to selected option index
  
  // Quiz details
  late String _quizTitle;
  late int _duration;
  late int _passingScore;
  late int _positiveScore;
  late int _negativeScore;
  late String _department;
  late String _difficultyLevel;
  
  // Timer
  late int _remainingSeconds;
  late Timer _timer;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _parseQuizData();
    _startTimer();
  }
  
  void _parseQuizData() {
    try {
      final quizData = widget.quizData;
      
      // Extract quiz details with null safety
      _quizTitle = quizData.title ?? 'Quiz';
      _duration = quizData.duration ?? 30;
      _remainingSeconds = _duration * 60;
      _passingScore = quizData.passingScore ?? 50;
      _positiveScore = quizData.positiveScore ?? 1;
      _negativeScore = quizData.negativeScore ?? 0;
      _department = quizData.department ?? '';
      _difficultyLevel = quizData.difficultyLevel ?? 'medium';
      
      // Safely process the questions
      if (quizData.questions == null) {
        setState(() {
          _questions = [];
          _isLoading = false;
        });
        return;
      }
      
      // Directly assign the questions, assuming the Quiz model has proper typing
      _questions = quizData.questions;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error parsing quiz data: $e');
      setState(() {
        _isLoading = false;
        _questions = [];
      });
    }
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _submitQuiz();
      }
    });
  }
  
  void _submitQuiz() {
    _timer.cancel();

    int score = 0;
    int totalAnswered = _userAnswers.length;

    _userAnswers.forEach((questionIndex, selectedOptionIndex) {
      final question = _questions[questionIndex];
      final correctOptionIndex = question.correctOptionIndex;

      if (selectedOptionIndex == correctOptionIndex) {
        score += _positiveScore;
      } else if (_negativeScore > 0) {
        // Only apply negative scoring if there is a penalty
        score = score > _negativeScore ? score - _negativeScore : 0;
      }
    });

    // Calculate percentage score
    final maxPossibleScore = _questions.length * _positiveScore;
    final scorePercentage = maxPossibleScore > 0
        ? (score / maxPossibleScore * 100).round()
        : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Submitted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Questions: ${_questions.length}'),
            Text('Questions Answered: $totalAnswered'),
            Text(
              'Final Score: $score points ($scorePercentage%)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              scorePercentage >= _passingScore 
                  ? 'Congratulations! You passed!' 
                  : 'You didn\'t reach the passing score.',
              style: TextStyle(
                color: scorePercentage >= _passingScore ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      actions: [
        TextButton(
          child: const Text('View Results'),
          onPressed: () {
            Navigator.pop(context);
            
            // Navigate to the results screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizResultScreen(
                  quizData: widget.quizData,
                  userAnswers: _userAnswers,
                  score: score,
                  scorePercentage: scorePercentage,
                  passingScore: _passingScore,
                ),
              ),
            );
          },
        ),
      ],
      ),
    );
  }
  
  void _handleOptionSelected(int optionIndex, int questionIndex) {
    setState(() {
      _userAnswers[questionIndex] = optionIndex;
    });
  }
  
  void _goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // On last question, ask to submit
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Submit Quiz?'),
          content: const Text('You\'ve reached the end of the quiz. Do you want to submit your answers?'),
          actions: [
            TextButton(
              child: const Text('Review Answers'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                Navigator.pop(context);
                _submitQuiz();
              },
            ),
          ],
        ),
      );
    }
  }
  
  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_quizTitle),
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, size: 18, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? const Center(
                  child: Text(
                    'No questions available for this quiz',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    _buildQuizInfo(),
                    _buildProgressBar(),
                    Expanded(
                      child: _buildQuestionCard(),
                    ),
                    _buildNavigationButtons(),
                  ],
                ),
    );
  }
  
  Widget _buildQuizInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _department,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(_difficultyLevel),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _difficultyLevel.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Passing: $_passingScore%'),
              Row(
                children: [
                  Icon(Icons.add_circle, color: Colors.green, size: 14),
                  Text(' $_positiveScore pts', style: const TextStyle(color: Colors.green)),
                  const SizedBox(width: 8),
                  Icon(Icons.remove_circle, color: Colors.red, size: 14),
                  Text(' $_negativeScore pts', style: const TextStyle(color: Colors.red)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${((_currentQuestionIndex + 1) / _questions.length * 100).toInt()}% Complete',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
 Widget _buildQuestionCard() {
  if (_questions.isEmpty) {
    return const Center(child: Text('No questions available'));
  }
  
  final question = _questions[_currentQuestionIndex];
  final questionType = question.type.toString();
  final options = question.options as List<dynamic>;
  final selectedOptionIndex = _userAnswers[_currentQuestionIndex];
  
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: questionType == 'true-false' ? Colors.amber.shade100 : Colors.purple.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                questionType == 'true-false' ? 'True/False' : 'Multiple Choice',
                style: TextStyle(
                  color: questionType == 'true-false' ? Colors.amber.shade900 : Colors.purple.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Question text
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Options
            ...List.generate(options.length, (index) {
              // Access the text property of the Option object instead of using toString()
              final optionText = options[index] is String 
                  ? options[index] 
                  : options[index].text ?? "Option ${index + 1}";
              
              return _buildOptionButton(
                optionText,
                questionType,
                selectedOptionIndex == index,
                () => _handleOptionSelected(index, _currentQuestionIndex),
              );
            }),
          ],
        ),
      ),
    ),
  );
}

Widget _buildOptionButton(String option, String questionType, bool isSelected, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle
                  : questionType == 'true-false'
                      ? (option == 'True' ? Icons.check_circle_outline : Icons.cancel_outlined)
                      : Icons.radio_button_unchecked,
              color: isSelected
                  ? Colors.blue.shade700
                  : questionType == 'true-false'
                      ? (option == 'True' ? Colors.green.shade700 : Colors.red.shade700)
                      : Colors.grey.shade700,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue.shade700 : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: _currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey.shade100,
              disabledForegroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          
          // Question counter
          Text(
            '${_currentQuestionIndex + 1} of ${_questions.length}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          
          // Next/Submit button
          ElevatedButton.icon(
            onPressed: _goToNextQuestion,
            icon: Icon(
              _currentQuestionIndex < _questions.length - 1
                  ? Icons.arrow_forward
                  : Icons.check_circle,
            ),
            label: Text(
              _currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Finish',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}