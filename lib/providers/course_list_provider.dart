// import 'package:flutter/material.dart';
// import '../services/api_service.dart'; // Import the API service

// class CourseListProvider with ChangeNotifier {
//   List<Map<String, dynamic>> courseData = [];
//   bool isLoading = true;
//   bool hasError = false;

//   Future<void> fetchCourseData(search,sort,filter) async {
//     final result = await ApiService.fetchAllCourse(
//         page: 1,
//         limit: 20,
//         search: search,
//         filter: filter,
//         sort: sort);

//     if (result["success"]) {
//       courseData = (result["data"] as List)
//           .map((course) => {
//                 'title': course['title'] ?? 'Unknown',
//                 'thumbnail': course['thumbnail'] ?? '',
//                 'tutorname': course['tutorId']?['tutorname'] ?? '',
//                 'description': course['description'] ?? '',
//                 'averageRating': course['averageRating'] ?? 0,
//                 'totalReviews': course['totalReviews'] ?? 0,
//                 'duration': course['duration'] ?? '',
//                 'price': course['price'] ?? 0,
//                 'enrolledStudents': course['enrolledStudents'] ?? 0
//               })
//           .toList();
//     } else {
//       hasError = true;
//     }

//     isLoading = false;
//     notifyListeners();
//   }
// }


import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CourseListProvider with ChangeNotifier {
  List<Map<String, dynamic>> courseData = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  Future<void> fetchCourseData(search,sort,filter) async {
    // Start loading immediately
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final result = await ApiService.fetchAllCourse(
        page: 1,
        limit: 20,
        search: search,
        filter: filter,
        sort: sort,
      );

      if (result["success"]) {
        courseData = (result["data"] as List)
            .map((course) => {
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
        
        isLoading = false;
      } else {
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
