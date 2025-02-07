import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import the API service

class CourseProvider with ChangeNotifier {
  List<Map<String, dynamic>> courseData = [];
  bool isLoading = true;
  bool hasError = false;

  Future<void> fetchWinnersData() async {
    final result = await ApiService.fetchCourses();

    if (result["success"]) {
      courseData = (result["data"] as List).map((course) => {
        'title': course['title'] ?? 'Unknown',
        'thumbnail': course['thumbnail'] ?? '',
        'tutorname': course['tutorId']?['tutorname'] ?? '',
        'description': course['description'] ?? '',
        'averageRating': course['averageRating'] ?? 0,
        'totalReviews': course['totalReviews'] ?? 0,
        'duration': course['duration'] ?? '',
        'price': course['price'] ?? 0,
        'enrolledStudents': course['enrolledStudents'] ?? 0
      }).toList();
    } else {
      hasError = true;
      print("Error loading courses: ${result['message']}"); // Debugging
    }

    isLoading = false;
    notifyListeners();
  }
}
