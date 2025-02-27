import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderListProvider with ChangeNotifier {
  List<Map<String, dynamic>> courseData = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  Future<void> fetchOrderData(search) async {
    // Start loading immediately
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final result = await ApiService.fetchOrder(
        page: 1,
        limit: 20,
        search: search,
      );

      if (result["success"]) {
        courseData = (result["orders"] as List)
            .map((order) => {
                  'Id': order['_id'] ?? 'Unknown',
                  'orderId': order['orderId'] ?? 'Unknown',
                  'paymentMethod': order['paymentMethod'] ?? 'Unknown',
                  'price': order['totalPrice'] ?? 0,
                  'date': order['createdAt'] ?? '',
                  'status': order['paymentStatus'] ?? ''
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
