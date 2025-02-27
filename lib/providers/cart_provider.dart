import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> cartItems = [];
  int? totalPrice;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  Future<void> fetchCartItem(String userId) async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final result = await ApiService.fetchCartItem(userId:userId);
      print(result);

      if (result["success"]) {
        cartItems = result["courses"];
        totalPrice = result["totalPrice"];
        isLoading = false;
      } else {
        hasError = true;
        errorMessage = result["message"] ?? "Failed to load order details";
        isLoading = false;
      }
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      isLoading = false;
    }

    notifyListeners();
  }

Future<String> addCourseToCart(String courseId, String userId) async {
  isLoading = true;
  notifyListeners();

  try {
    final response = await ApiService.addToCart(courseId, userId);

    if (response["status"] == 200) {
      fetchCartItem(userId);
      return response["message"]; // ✅ Return success message from server
    } else if (response["status"] == 409) {
      hasError = true;
      return response["message"]; // ✅ Return "Already in Cart" message
    } else {
      hasError = true;
      return "Error: ${response["message"]}";
    }
  } catch (e) {
    hasError = true;
    return "Error: $e"; // ✅ Return error message
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

Future<void> removeCourseFromCart(String courseId, String userId) async {
  isLoading = true;
  notifyListeners();

  try {
    final response = await ApiService.removeFromCart(courseId, userId);

    if (response["status"] == 200) {
      // ✅ Only remove the item locally if server confirms success
      cartItems.removeWhere((course) => course["course"]["_id"] == courseId);
      totalPrice = response["totalPrice"] ?? totalPrice;
      notifyListeners(); // ✅ Update UI in real-time
    } else {
      hasError = true;
      errorMessage = response["message"] ?? "Failed to remove item";
    }
  } catch (e) {
    hasError = true;
    errorMessage = e.toString();
  } finally {
    isLoading = false;
    notifyListeners(); // ✅ Ensure UI updates in any case
  }
}



  
}