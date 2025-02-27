import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/providers/order_datail_provider.dart';
import 'package:project/screens/course_detail.dart';
import 'package:provider/provider.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderDetailProvider>(context, listen: false)
          .fetchOrderDetail(widget.orderId);
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Detail'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        elevation: 1,
      ),
      body: Consumer<OrderDetailProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    orderProvider.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      orderProvider.fetchOrderDetail(widget.orderId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final orderData = orderProvider.orderDetail;
          if (orderData == null) {
            return const Center(child: Text('Order not found'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Order ID:',
                            orderData['_id'] ?? '-',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Order Date:',
                            DateFormat('MMM dd, yyyy hh:mm a').format(
                              DateTime.parse(orderData['createdAt']),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Total Amount:',
                            '\$${(orderData['totalPrice'] ?? 0).toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Payment Method:',
                            orderData['paymentMethod'] ?? '-',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Total Items:',
                            '${(orderData['items'] as List?)?.length ?? 0} Courses',
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text(
                                'Payment Status:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    orderData['paymentStatus'] ?? '',
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  orderData['paymentStatus'] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Courses Section
                  const Text(
                    'Purchased Courses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Courses List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (orderData['items'] as List?)?.length ?? 0,
                    itemBuilder: (context, index) {
                      final course = (orderData['items'] as List)[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context)=>CourseDetailScreen(id: course['course']['_id']))),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                course['course']['thumbnail'] ?? '',
                                width: 60,
                                height: 60,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book),
                                ),
                              ),
                            ),
                            title: Text(
                              course['course']['title'] ?? 'Untitled Course',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Instructor: ${course['course']['tutorId']['tutorname'] ?? 'Unknown'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              '\$${(course['price'] ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}