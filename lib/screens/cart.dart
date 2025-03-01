import 'package:flutter/material.dart';
import 'package:project/providers/cart_provider.dart';
import 'package:project/screens/payment_success_screen.dart';
import 'package:project/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCartItem('userId');
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Payment Successful! Payment ID: ${response.paymentId}")),
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedOrderId = prefs.getString('lastOrderId');

  if (storedOrderId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error: Order ID is missing.")),
    );
    return;
  }

  final confirmationResponse = await ApiService.confirmPayment({
    "orderId": storedOrderId,
    "paymentId": response.paymentId,
    "status": "success",
  });

  if (confirmationResponse["success"] == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order Confirmed Successfully!")),
    );

        Provider.of<CartProvider>(context, listen: false).clearCart();


    // ✅ Navigate to Payment Success Screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => OrderPlacedScreen(orderId: storedOrderId)),
);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to confirm order.")),
    );
  }
}



  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

void _startPayment(int? totalAmount, List<Map<String, dynamic>>? orderItems) async {
  if (totalAmount == null || orderItems == null || orderItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid order details. Please try again.")),
    );
    return;
  }

  Map<String, dynamic> orderDetails = {
    "orderItems": orderItems, 
    "total": totalAmount, 
  };

  print("Order Details: $orderDetails");

  final response = await ApiService.processPayment(orderDetails);

      String orderId = response["orderId"];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("lastOrderId", orderId);


  if (response["success"] == true) {
    var options = {
      'key': 'rzp_test_x4yKuLEYJQuXwJ',
      'amount': totalAmount * 100,
      'name': 'Tech Ora',
      'description': 'Purchase of Courses',
      'orderId': orderId,
      'prefill': {
        'email': 'techoraworld@gmail.com',
        'contact': '1234567890',
      },
      'theme': {'color': '#3399cc'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response["message"]}")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.cartItems == null ||
              cartProvider.cartItems!.isEmpty) {
            return _buildEmptyCart();
          }

          return _buildCartContent(cartProvider);
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Your cart is empty',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Browse Courses')),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartProvider cartProvider) {
    final courses = cartProvider.cartItems!;
    int totalAmount = cartProvider.totalPrice ?? 0;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildCartItem(course);
            },
          ),
        ),
        _buildOrderSummary(cartProvider, totalAmount),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            course['course']['thumbnail'] ?? '',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: Icon(Icons.image, color: Colors.grey.shade400),
              );
            },
          ),
        ),
        title: Text(
          course['course']['title'] ?? 'Untitled Course',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '\$${course['price'] ?? 0}',
          style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider, int totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                Text(
                  '\$$totalAmount',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                List<Map<String, dynamic>> orderDetails =
                    cartProvider.cartItems!.map((item) {
                  return {
                    "courseId": item['course']['_id'],
                    "name": item['course']['title'],
                    "description": item['course']['description'],
                    "thumbnail": item['course']['thumbnail'],
                    "price": item['price'],
                  };
                }).toList();

                _startPayment(cartProvider.totalPrice ?? 0, orderDetails);
              },
              child: const Text('Proceed to Buy'),
            ),
          ],
        ),
      ),
    );
  }
}
