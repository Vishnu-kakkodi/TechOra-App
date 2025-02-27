import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderDetailProvider with ChangeNotifier {
  Map<String, dynamic>? orderDetail;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  Future<void> fetchOrderDetail(String orderId) async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final result = await ApiService.fetchOrderDetail(orderId:orderId);
      print(result);

      if (result["success"]) {
        orderDetail = result["order"];
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
}