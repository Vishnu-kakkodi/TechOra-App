import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OrderPlacedScreen extends StatelessWidget {
  final String orderId;

  const OrderPlacedScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top section with back button and title
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Order Confirmation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40), // To balance the appbar
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Success animation
                      SizedBox(
                        height: 200,
                        child: Image.network(
                          'https://example.com/success.gif', // Replace with your GIF URL
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.check_circle,
                                color: Colors.green.shade500, size: 120);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Success message
                      const Text(
                        'Order Placed Successfully!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Order details
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              'Order ID:',
                              '#$orderId',
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Date:',
                              DateTime.now().toString().substring(0, 10),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Status:',
                              'Payment Successful',
                              valueColor: Colors.green.shade600,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/orders');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View My Orders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/courses', (route) => false);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.blue.shade700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue Shopping',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build info rows
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
