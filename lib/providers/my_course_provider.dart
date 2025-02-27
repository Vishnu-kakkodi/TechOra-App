
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyCourseListProvider with ChangeNotifier {
  List<Map<String, dynamic>> courseData = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  Future<void> fetchMyCourseData(search) async {
    // Start loading immediately
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final result = await ApiService.fetchMyCourse(
        page: 1,
        limit: 20,
        search: search,
      );
      print(result["data"]);

      if (result["success"]) {
        print("jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj");
        courseData = (result["data"] as List)
            .map((course) => {
                  'courseId': course['_id'] ?? 'Unknown',
                  'title': course['title'] ?? 'Unknown',
                  'thumbnail': course['thumbnail'] ?? '',
                  'tutorname': course['tutorId']?['tutorname'] ?? '',
                  'description': course['description'] ?? '',
                  'averageRating': course['averageRating'] ?? 0,
                  'totalReviews': course['totalReviews'] ?? 0,
                  'duration': course['duration'] ?? '',
                  'price': course['price'] ?? 0,
                  'enrolledStudents': course['enrolledStudents'] ?? 0
                })
            .toList();
            print("ffffffffffffffffffffffffffffffffffffffff"); 
        
        isLoading = false;
      } else {
        print('object');
        hasError = true;
        errorMessage = result["message"] ?? "Failed to load courses";
        isLoading = false;
      }
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      isLoading = false;
    }

    notifyListeners();
  }
}
