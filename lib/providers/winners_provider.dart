import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import the API service

class WinnersProvider with ChangeNotifier {
  List<Map<String, dynamic>> winners = [];
  bool isLoading = true;
  bool hasError = false;

  Future<void> fetchWinnersData() async {
    final result = await ApiService.fetchWinners();

    if (result["success"]) {
      winners = (result["data"] as List).map((winner) => {
        'userName': winner['userName'] ?? 'Unknown',
        'profilePhoto': winner['profilePhoto'] ?? '',
        'score': winner['quizProgress']?['score'] ?? 0,
        'rank': winner['quizProgress']?['rank'] ?? '',
      }).toList();
    } else {
      hasError = true;
      print("Error loading winners: ${result['message']}"); // Debugging
    }

    isLoading = false;
    notifyListeners();
  }
}
