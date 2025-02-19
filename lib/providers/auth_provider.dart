import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import the API service

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await ApiService.login(email, password);

    _isLoading = false;
    notifyListeners();

    if (result["success"]) {
      print("Login successful: ${result['data']}");
      return true;
    } else {
      print("Login failed: ${result['message']}");
      return false;
    }
  }

Future<bool> register(String userName, String email, String password, String phoneNumber) async {
  _isLoading = true;
  notifyListeners();
  
  final result = await ApiService.register(userName, email, password, phoneNumber);

  _isLoading = false;
  notifyListeners();

  if (result["success"]) {
  print("Login successful");
    return true;
  } else {
    return false;
  }
}
}





// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;

// class AuthProvider with ChangeNotifier {
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   // API Base URL
//   final String baseUrl = "https://api.techora.online/api/users";

//   // Email & Password Login
//   Future<bool> login(String email, String password) async {
//     _isLoading = true;
//     notifyListeners();

//     final String url = "$baseUrl/login";
//     final Map<String, String> headers = {"Content-Type": "application/json"};
//     final Map<String, String> body = {
//       "email": email,
//       "password": password
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: jsonEncode(body),
//       );

//       _isLoading = false;
//       notifyListeners();

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         print("Login successful: ${responseData['data']}");
//         return true; // Login success
//       } else {
//         print("Login failed: ${response.body}");
//         return false;
//       }
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       print("Error: $error");
//       return false;
//     }
//   }

//   // Google Sign-In
//   Future<bool> loginWithGoogle() async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         _isLoading = false;
//         notifyListeners();
//         return false; // User canceled login
//       }

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // Send the Google ID token to your backend
//       final response = await http.post(
//         Uri.parse("$baseUrl/google-login"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "idToken": googleAuth.idToken, // Send Google ID token to backend
//         }),
//       );

//       _isLoading = false;
//       notifyListeners();

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         print("Google Login successful: ${responseData['data']}");
//         return true;
//       } else {
//         print("Google Login failed: ${response.body}");
//         return false;
//       }
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       print("Google Sign-In Error: $error");
//       return false;
//     }
//   }

//   // Logout Function
//   Future<void> logout() async {
//     await _googleSignIn.signOut();
//     notifyListeners();
//   }
// }




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthProvider with ChangeNotifier {
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   // API Base URL
//   final String baseUrl = "https://api.techora.online/api/users";

//   // Email & Password Login
//   Future<bool> login(String email, String password) async {
//     _isLoading = true;
//     notifyListeners();

//     final String url = "$baseUrl/login";
//     final Map<String, String> headers = {"Content-Type": "application/json"};
//     final Map<String, String> body = {
//       "email": email,
//       "password": password
//     };

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: jsonEncode(body),
//       );

//       _isLoading = false;
//       notifyListeners();

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         await _saveUserData(responseData['token'], email);
//         print("Login successful: ${responseData['data']}");
//         return true; // Login success
//       } else {
//         print("Login failed: ${response.body}");
//         return false;
//       }
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       print("Error: $error");
//       return false;
//     }
//   }

//   // Google Sign-In with Backend Authentication
//   Future<bool> loginWithGoogle() async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         _isLoading = false;
//         notifyListeners();
//         return false; // User canceled login
//       }

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // Extract user details
//       String? email = googleUser.email;
//       String? userName = googleUser.displayName; // Google usually does not provide this

//       // Send user data to backend
//       final response = await http.post(
//         Uri.parse("$baseUrl/google-login"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "idToken": googleAuth.idToken, // Google ID token
//           "email": email,
//           "userName": userName,
//         }),
//       );

//       _isLoading = false;
//       notifyListeners();

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
        
//         // Store user data
//         await _saveUserData(responseData['token'], email);

//         print("Google Login successful: ${responseData['data']}");
//         return true;
//       } else {
//         print("Google Login failed: ${response.body}");
//         return false;
//       }
//     } catch (error) {
//       _isLoading = false;
//       notifyListeners();
//       print("Google Sign-In Error: $error");
//       return false;
//     }
//   }

//   // Store user data in SharedPreferences
//   Future<void> _saveUserData(String token, String email) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString("token", token);
//     await prefs.setString("email", email);
//   }

//   // Logout Function
//   Future<void> logout() async {
//     await _googleSignIn.signOut();
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     notifyListeners();
//   }
// }
