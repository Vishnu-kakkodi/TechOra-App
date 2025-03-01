import 'package:flutter/material.dart';
import 'package:project/models/quiz_model.dart';

class QuizResultScreen extends StatelessWidget {
  final Quiz quizData;
  final Map<int, int> userAnswers;
  final int score;
  final int scorePercentage;
  final int passingScore;

  const QuizResultScreen({
    Key? key,
    required this.quizData,
    required this.userAnswers,
    required this.score,
    required this.scorePercentage,
    required this.passingScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPassed = scorePercentage >= passingScore;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildResultSummary(isPassed),
          Expanded(
            child: _buildQuestionList(),
          ),
          _buildFooterButtons(context),
        ],
      ),
    );
  }

  Widget _buildResultSummary(bool isPassed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPassed ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPassed ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isPassed ? Icons.check_circle : Icons.cancel,
            color: isPassed ? Colors.green : Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            isPassed ? 'Congratulations! You Passed!' : 'Not Passed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isPassed ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Score: $score points ($scorePercentage%)',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Passing Score: $passingScore%',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Questions Answered: ${userAnswers.length} of ${quizData.questions.length}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quizData.questions.length,
      itemBuilder: (context, index) {
        final question = quizData.questions[index];
        final userSelectedIndex = userAnswers[index];
        final correctOptionIndex = question.correctOptionIndex;
        final options = question.options as List<dynamic>;
        
        final isAnswered = userSelectedIndex != null;
        final isCorrect = isAnswered && userSelectedIndex == correctOptionIndex;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isAnswered
                  ? (isCorrect ? Colors.green.shade200 : Colors.red.shade200)
                  : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question status indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAnswered
                            ? (isCorrect ? Colors.green.shade100 : Colors.red.shade100)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAnswered
                                ? (isCorrect ? Icons.check_circle : Icons.cancel)
                                : Icons.help_outline,
                            color: isAnswered
                                ? (isCorrect ? Colors.green : Colors.red)
                                : Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isAnswered
                                ? (isCorrect ? 'Correct' : 'Incorrect')
                                : 'Not Answered',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isAnswered
                                  ? (isCorrect ? Colors.green.shade800 : Colors.red.shade800)
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Question ${index + 1}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Question text
                Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Options
                ...List.generate(options.length, (optIndex) {
                  // Access the text property of the Option object instead of using toString()
                  final optionText = options[optIndex] is String 
                      ? options[optIndex] 
                      : options[optIndex].text ?? "Option ${optIndex + 1}";
                  
                  final isUserSelection = userSelectedIndex == optIndex;
                  final isCorrectOption = optIndex == correctOptionIndex;
                  
                  return _buildOptionResult(
                    optionText,
                    isUserSelection,
                    isCorrectOption,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionResult(String optionText, bool isUserSelection, bool isCorrectOption) {
    Color backgroundColor;
    Color borderColor;
    IconData iconData;
    Color iconColor;
    
    if (isUserSelection && isCorrectOption) {
      // User selected the correct option
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      iconData = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isUserSelection && !isCorrectOption) {
      // User selected the wrong option
      backgroundColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      iconData = Icons.cancel;
      iconColor = Colors.red;
    } else if (!isUserSelection && isCorrectOption) {
      // This is the correct option but user didn't select it
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green.shade300;
      iconData = Icons.check_circle_outline;
      iconColor = Colors.green;
    } else {
      // Regular unselected option
      backgroundColor = Colors.grey.shade50;
      borderColor = Colors.grey.shade300;
      iconData = Icons.radio_button_unchecked;
      iconColor = Colors.grey.shade700;
    }
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(iconData, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              optionText,
              style: TextStyle(
                color: isCorrectOption ? Colors.black : Colors.grey.shade800,
                fontWeight: isCorrectOption ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Quiz'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home or another quiz
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Go to Home'),
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