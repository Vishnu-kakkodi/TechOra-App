// import 'package:flutter/material.dart';
// import '../services/api_service.dart';

// class CourseDetailProvider with ChangeNotifier {
//   Map<String, dynamic>? course;
//   bool isLoading = false;
//   bool hasError = false;
//   String errorMessage = '';

//   Future<void> fetchCourseData(String courseId) async {
//     try {
//       isLoading = true;
//       hasError = false;
//       errorMessage = '';
//       notifyListeners();

//       final result = await ApiService.fetchCourseDetail(courseId);

//       if (result["success"]) {
//         course = result["data"];
//       } else {
//         hasError = true;
//         errorMessage = result["message"] ?? "Failed to load course";
//         course = null;
//       }
//     } catch (e) {
//       hasError = true;
//       errorMessage = "An error occurred: ${e.toString()}";
//       course = null;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   void reset() {
//     course = null;
//     isLoading = false;
//     hasError = false;
//     errorMessage = '';
//     notifyListeners();
//   }
// }


import 'package:flutter/material.dart';
import 'package:project/models/course_detail_model.dart';
import 'package:project/services/api_service.dart';

class CourseDetailProvider with ChangeNotifier {
  CourseDetailModel? _courseDetail;
  bool isLoading = false;
  String? errorMessage;

  CourseDetailModel? get courseDetail => _courseDetail;

  Future<void> fetchCourseDetail(String courseId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await ApiService.fetchCourseDetail(courseId);
      
      if (response['status'] == 200) {
        _courseDetail = CourseDetailModel.fromJson(response);
      } else {
        errorMessage = response['message'] ?? 'Failed to fetch course details';
      }
    } catch (e) {
      errorMessage = 'An error occurred: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}