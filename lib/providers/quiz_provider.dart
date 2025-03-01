import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/quiz_model.dart'; // Import the models

class QuizListProvider with ChangeNotifier {
  List<Quiz> quizzes = [];
  List<String> departments = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  Future<void> fetchQuizData(String search, String sort, String filter) async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final result = await ApiService.fetchAllQuiz(
        page: 1,
        limit: 20,
        search: search,
        filter: filter,
        sort: sort,
      );

      if (result["success"]) {
        quizzes = (result["quiz"] as List)
            .map((quizData) => Quiz.fromJson(quizData))
            .toList();

        departments = List<String>.from(result["department"] ?? []);
        isLoading = false;
      } else {
        hasError = true;
        errorMessage = result["message"] ?? "Failed to load quizzes";
        isLoading = false;
      }
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      isLoading = false;
    }

    notifyListeners();
  }

  Quiz? getQuizById(String quizId) {
    try {
      return quizzes.firstWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      return null;
    }
  }
}
