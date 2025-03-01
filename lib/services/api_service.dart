// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static const String _baseUrl = "https://api.techora.online/api";

//   static Future<Map<String, dynamic>> login(String email, String password) async {
//     final String url = "$_baseUrl/users/login";
//     final Map<String, String> headers = {"Content-Type": "application/json"};
//     final Map<String, String> body = {"email": email, "password": password};

//     try {
//       final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));

//       if (response.statusCode == 200) {
//         return {"success": true, "data": jsonDecode(response.body)};
//       } else {
//         return {"success": false, "message": response.body};
//       }
//     } catch (error) {
//       return {"success": false, "message": "Error: $error"};
//     }
//   }

//     static Future<Map<String, dynamic>> fetchCourses() async {
//     final String url = "$_baseUrl/users/home-data";

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         return {"success": true, "data": jsonResponse['data']['courses']['course'] ?? []};
//       } else {
//         return {"success": false, "message": "Failed to load courses"};
//       }
//     } catch (error) {
//       return {"success": false, "message": "Error: $error"};
//     }
//   }

//    static Future<Map<String, dynamic>> fetchWinners() async {
//     final String url = "$_baseUrl/users/home-data";

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         return {"success": true, "data": jsonResponse['data']['winners']['quizWinners'] ?? []};
//       } else {
//         return {"success": false, "message": "Failed to load winners"};
//       }
//     } catch (error) {
//       return {"success": false, "message": "Error: $error"};
//     }
//   }

// static Future<Map<String, dynamic>> fetchAllCourse({
//   int? page,
//   int? limit,
//   String? search,
//   String? filter,
//   String? sort,
// }) async {
//   final queryParameters = {
//     if (page != null) 'page': page.toString(),
//     if (limit != null) 'limit': limit.toString(),
//     if (search != null && search.isNotEmpty) 'search': search,
//     if (filter != null && filter.isNotEmpty) 'filter': filter,
//     if (sort != null && sort.isNotEmpty) 'sort': sort,
//   };

//   final Uri url = Uri.parse('$_baseUrl/users/course-list').replace(
//     queryParameters: queryParameters,
//   );

//   try {
//     final response = await http.get(url);

//       final Map<String, dynamic> jsonResponse = json.decode(response.body);
//       print('🔍 API Response - Course List Data: $jsonResponse');
//       return {
//         "success": true,
//         "data": jsonResponse['course'] ?? [],
//         "totalPages": jsonResponse['totalPages'],
//         "currentPage": jsonResponse['currentPage'],
//         "totalCourses": jsonResponse['totalCourses'],
//       };
//   } catch (error) {
//     return {
//       "success": false,
//       "message": "Error: $error"
//     };
//   }
// }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> _getHeaders() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString("accessToken");
  String? refreshToken = prefs.getString("refreshToken");

  String? role = prefs.getString("role");

  return {
    "Content-Type": "application/json",
    "Authorization": "Bearer $accessToken",
    "x-refresh-token": "$refreshToken",
    "role": role ?? "user"
  };
}

class ApiService {
  static const String _baseUrl = "https://api.techora.online/api";
  static const Map<String, String> roleHeader = {"role": "user"};

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final String url = "$_baseUrl/users/login";
    final Map<String, String> body = {"email": email, "password": password};

    try {
      print("🔹 Sending Login Request: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("🔹 Raw API Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final String accessToken =
            data['data']['accessToken']?.toString() ?? "";
        final String refreshToken =
            data['data']['refreshToken']?.toString() ?? "";
        final String userName = data['data']['userName']?.toString() ?? "";
        final String phoneNumber =
            data['data']['phoneNumber']?.toString() ?? "";
        final String profilePhoto =
            data['data']['profilePhoto']?.toString() ?? "";
        final String email = data['data']['email']?.toString() ?? "";
        final String userId = data['data']['_id']?.toString() ?? "";

        if (accessToken.isEmpty || refreshToken.isEmpty) {
          return {"success": false, "message": "Invalid response from server"};
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("name", userName);
        await prefs.setString("email", email);
        await prefs.setString("phoneNumber", phoneNumber);
        await prefs.setString("profilePhoto", profilePhoto);
        await prefs.setString("accessToken", accessToken);
        await prefs.setString("refreshToken", refreshToken);
        await prefs.setString("role", 'user');
        await prefs.setString("userId", userId);
        await prefs.setBool("isLoggedIn", true);
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> register(String userName, String email,
      String password, String phoneNumber) async {
    final String url = "$_baseUrl/users/register";
    final Map<String, String> body = {
      "name": userName,
      "email": email,
      "password": password,
      "phoneNumber": phoneNumber
    };

    try {
      print("📝 Registering User: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("🔹 Register Response: ${response.body}");

      if (response.statusCode == 200) {
        return {"success": true, "message": "User registered successfully!"};
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> fetchCourses() async {
    final String url = "$_baseUrl/users/home-data";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return {
          "success": true,
          "data": jsonResponse['data']['courses']['course'] ?? []
        };
      } else {
        return {"success": false, "message": "Failed to load courses"};
      }
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> fetchWinners() async {
    final String url = "$_baseUrl/users/home-data";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return {
          "success": true,
          "data": jsonResponse['data']['winners']['quizWinners'] ?? []
        };
      } else {
        return {"success": false, "message": "Failed to load winners"};
      }
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> fetchAllCourse({
    int? page,
    int? limit,
    String? search,
    String? filter,
    String? sort,
  }) async {
    print('$search,$filter,$sort,mmmmmmmmmmmmmmmmmm');
    final queryParameters = {
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (search != null && search.isNotEmpty)
        'search': search
      else
        'search': '',
      if (filter != null && filter.isNotEmpty)
        'filter': filter
      else
        'filter': '',
      if (sort != null && sort.isNotEmpty) 'sort': sort else 'sort': '',
    };

    final Uri url = Uri.parse('$_baseUrl/users/course-list').replace(
      queryParameters: queryParameters,
    );
    final Map<String, String> headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('🔍 API Response - Course List Data: $jsonResponse');
      return {
        "success": true,
        "data": jsonResponse['course'] ?? [],
        "totalPages": jsonResponse['totalPages'],
        "currentPage": jsonResponse['currentPage'],
        "totalCourses": jsonResponse['totalCourses'],
      };
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }



    static Future<Map<String, dynamic>> fetchAllQuiz({
    int? page,
    int? limit,
    String? search,
    String? filter,
    String? sort,
  }) async {
    print('$search,$filter,$sort,mmmmmmmmmmmmmmmmmm');
    final queryParameters = {
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (search != null && search.isNotEmpty)
        'search': search
      else
        'search': '',
      if (filter != null && filter.isNotEmpty)
        'filter': filter
      else
        'filter': '',
      if (sort != null && sort.isNotEmpty) 'sort': sort else 'sort': '',
    };

    final Uri url = Uri.parse('$_baseUrl/users/quiz-list').replace(
      queryParameters: queryParameters,
    );
    final Map<String, String> headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('🔍 API Response - Quiz List Data: $jsonResponse');
      return {
        "success": true,
        "quiz": jsonResponse['quiz'] ?? [],
        "department": jsonResponse['department'] ?? [],
        "totalPages": jsonResponse['totalPages'],
        "currentPage": jsonResponse['currentPage'],
        "totalCourses": jsonResponse['totalCourses'],
      };
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> fetchMyCourse({
    int? page,
    int? limit,
    String? search,
  }) async {
    print('$search,mmmmmmmmmmmmmmmmmm');
    final queryParameters = {
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (search != null && search.isNotEmpty)
        'search': search
      else
        'search': '',
    };

    final Uri url = Uri.parse('$_baseUrl/users/my-courses').replace(
      queryParameters: queryParameters,
    );
    final Map<String, String> headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('🔍 API Response - Course List Data: $jsonResponse');
      return {
        "success": true,
        "data": jsonResponse['data'] ?? [],
        "totalPages": jsonResponse['totalPages'],
        "currentPage": jsonResponse['currentPage'],
        "totalCourses": jsonResponse['totalCourses'],
      };
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> fetchOrder({
    int? page,
    int? limit,
    String? search,
  }) async {
    final queryParameters = {
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      if (search != null && search.isNotEmpty)
        'search': search
      else
        'search': '',
    };

    final Uri url = Uri.parse('$_baseUrl/users/order-list').replace(
      queryParameters: queryParameters,
    );
    final Map<String, String> headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('🔍 API Response - Course List Data: $jsonResponse');
      return {
        "success": true,
        "orders": jsonResponse['data']["orders"] ?? [],
        "totalPages": jsonResponse['totalPages'],
        "currentPage": jsonResponse['currentPage'],
        "totalCourses": jsonResponse['totalCourses'],
      };
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> fetchOrderDetail({
    String? orderId,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/users/order-detail/$orderId');
    final Map<String, String> headers = await _getHeaders();

    try {
      print('oooooooooooooo');
      final response = await http.get(url, headers: headers);

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('🔍 API Response - Course List Data: $jsonResponse');
      return {
        "success": true,
        "order": jsonResponse['data'] ?? '',
        "totalPages": jsonResponse['totalPages'],
        "currentPage": jsonResponse['currentPage'],
        "totalCourses": jsonResponse['totalCourses'],
      };
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> fetchCourseDetail(String courseId) async {
    try {
      final Uri url = Uri.parse('$_baseUrl/users/course-detail/$courseId');
      final Map<String, String> headers = await _getHeaders();

      final response = await http.get(url, headers: headers);
      return json.decode(response.body);
    } catch (error) {
      return {'status': 500, 'message': 'Error: $error'};
    }
  }

  static Future<Map<String, dynamic>> fetchCartItem({String? userId}) async {
    final Uri url = Uri.parse('$_baseUrl/users/cart-items');
    final Map<String, String> headers = await _getHeaders();

    try {
      final response = await http.get(url, headers: headers);
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      print('🔍 API Response - Course List Data: $jsonResponse');

      return {
        "success": true,
        "courses": List<Map<String, dynamic>>.from(
            jsonResponse['data']["items"] ?? []), // Explicit cast
        "totalPrice": jsonResponse["data"]["totalPrice"] ?? 0,
        "totalPages": jsonResponse['totalPages'],
        "currentPage": jsonResponse['currentPage'],
        "totalCourses": jsonResponse['totalCourses'],
      };
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> addToCart(
      String courseId, String userId) async {
    final Uri url = Uri.parse('$_baseUrl/users/add-cart'); // Backend endpoint
    final Map<String, String> headers = await _getHeaders();

    final Map<String, dynamic> body = {"userId": userId, "courseId": courseId};

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('🛒 Add to Cart Response: $jsonResponse');

      return jsonResponse;
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> removeCart(
      String courseId, String userId) async {
    final Uri url =
        Uri.parse('$_baseUrl/users/remove-cart'); // Backend endpoint
    final Map<String, String> headers = await _getHeaders();

    final Map<String, dynamic> body = {"userId": userId, "courseId": courseId};

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('🛒 Add to Cart Response: $jsonResponse');

      return jsonResponse;
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> removeFromCart(
      String courseId, String userId) async {
    final Uri url = Uri.parse("$_baseUrl/users/remove-cart");
    final Map<String, String> headers = await _getHeaders();
    final Map<String, dynamic> body = {"userId": userId, "courseId": courseId};

    try {
      final response =
          await http.patch(url, headers: headers, body: jsonEncode(body));

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print('🗑 API Response - Remove Course: $jsonResponse');

      return jsonResponse;
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<bool> updateProfile(String field, String value) async {
    try {
      final Uri url = Uri.parse('$_baseUrl/users/profile-update');
      final Map<String, String> headers = await _getHeaders();
      final Map<String, dynamic> body = {field: value};
      print('$jsonEncode(body),hhhhhhhhhhhhhhhhh');
      final response =
          await http.put(url, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        print("Profile updated successfully: ${response.body}");
        return true;
      } else {
        print("Failed to update profile: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final String url = "$_baseUrl/users/change-password";

    try {
      final headers = await _getHeaders();
      final Map<String, String> body = {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      };

      print("🔹 Sending Change Password Request: $body");

      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print("🔹 Change Password Response: ${response.statusCode}");
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse["status"] == 201) {
        return {
          "success": true,
          "message": jsonResponse["message"] ?? "Password changed successfully"
        };
      } else {
        return {
          "success": false,
          "message": jsonResponse["message"] ?? "Failed to change password"
        };
      }
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> fetchLeaderBoard() async {
    try {
      final Uri url = Uri.parse('$_baseUrl/users/leaderBoard');
      final Map<String, String> headers = await _getHeaders();

      final response = await http.get(url, headers: headers);
      print('datafetchhhhhhhhhhhhhhhh,${json.decode(response.body)}');
      return json.decode(response.body);
    } catch (error) {
      return {'status': 500, 'message': 'Error: $error'};
    }
  }

  static Future<Map<String, dynamic>> processPayment(
      Map<String, dynamic> orderDetails) async {
    final url = Uri.parse('$_baseUrl/users/payment');
    final Map<String, String> headers = await _getHeaders();

    try {
      print('Order Details Sent: $orderDetails');
      final body = jsonEncode({
        "orderDetails": orderDetails,
        "paymentMethod": "razorpay",
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      final jsonResponse = jsonDecode(response.body);
      print('API Response: $jsonResponse');
      if (jsonResponse["status"] == 200) {
        return {
          "success": true,
          "orderId": jsonResponse["data"]["orderID"],
        };
      } else {
        return {
          "success": false,
          "orderId": jsonResponse["data"]["orderID"],
          "message": jsonResponse["message"] ?? "Failed"
        };
      }
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }

  static Future<Map<String, dynamic>> confirmPayment(
      Map<String, dynamic> paymentData) async {
    final url = Uri.parse('$_baseUrl/users/payment-success');
    final Map<String, String> headers = await _getHeaders();

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(paymentData),
      );

      final jsonResponse = jsonDecode(response.body);
      print('Payment Confirmation Response: $jsonResponse');
      if (jsonResponse["status"] == 200) {
        return {
          "success": true,
          "message": jsonResponse["message"] ?? "Failed"
        };
      } else {
        return {
          "success": false,
          "message": jsonResponse["message"] ?? "Failed"
        };
      }
    } catch (error) {
      return {"success": false, "message": "Error: $error"};
    }
  }
}
