import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/providers/order_list_provider.dart';
import 'package:project/screens/order_detail.dart';
import 'package:project/utils/debouncer.dart';
import 'package:provider/provider.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final Debouncer _debouncer = Debouncer(delay: Duration(seconds: 1));
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchOrders() {
    _debouncer.run(() {
      Provider.of<OrderListProvider>(context, listen: false)
          .fetchOrderData(_searchController.text);
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _viewOrderDetails(String orderId) {
    print('$orderId,hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailPage(orderId: orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search orders...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchOrders();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (_) => _fetchOrders(),
            ),
          ),

          // Orders List
          Expanded(
            child: Consumer<OrderListProvider>(
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
                          onPressed: _fetchOrders,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (orderProvider.courseData.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => _fetchOrders(),
                  child: ListView.builder(
                    itemCount: orderProvider.courseData.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final order = orderProvider.courseData[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order ${order['orderId']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor('${order['status']}'), // Default status
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child:  Text(
                                      '${order['status']}', // Default status
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Payment: ${order['paymentMethod']}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(order['date']))}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Price: \₹${order['price'].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _viewOrderDetails(order['Id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('View Details'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}