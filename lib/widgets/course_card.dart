// import 'package:flutter/material.dart';

// class CourseCard extends StatelessWidget {
//   final Map<String, dynamic> course;

//   const CourseCard({Key? key, required this.course}) : super(key: key);

//   String _truncateText(String text, int wordLimit) {
//     List<String> words = text.split(' ');
//     if (words.length <= wordLimit) return text;
//     return '${words.take(wordLimit).join(' ')}...';
//   }

//     String _truncateTexts(String text, int wordLimit) {
//     List<String> words = text.split('');
//     if (words.length <= wordLimit) return text;
//     return '${words.take(wordLimit).join('')}...';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
      
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
        
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//             child: Image.network(
//               course['thumbnail'],
//               height: 100,
//               width: double.infinity,
//               fit: BoxFit.fill,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return const Center(child: CircularProgressIndicator());
//               },
//               errorBuilder: (context, error, stackTrace) => 
//                 const Icon(Icons.error_outline, size: 100),
//             ),
//           ),
          
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _truncateTexts(course['title'], 15),
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
                
//                 const SizedBox(height: 8),
//                 Text(
//                   'Tutor: ${course['tutorname']}',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
               
//                 const SizedBox(height: 8),
//                 Text(
//                   _truncateText(course['description'], 7),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.black87,
//                   ),
//                   textAlign: TextAlign.justify,
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.star, color: Colors.amber, size: 18),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${course['averageRating'].toStringAsFixed(1)} (${course['totalReviews']})',
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       '\$${course['price']}',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(onPressed: (){

//                     }, child: Text("Add To Cart"))
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:project/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseCard({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _truncateText(String text, int wordLimit) {
    List<String> words = text.split(' ');
    if (words.length <= wordLimit) return text;
    return '${words.take(wordLimit).join(' ')}...';
  }

  String _truncateTexts(String text, int wordLimit) {
    List<String> words = text.split('');
    if (words.length <= wordLimit) return text;
    return '${words.take(wordLimit).join('')}...';
  }

  void _showToast(String message, bool isSuccess) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _handleAddToCart(BuildContext context) async {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  
  setState(() => _isLoading = true);
  _animationController.forward();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');

  if (userId == null) {
    _showToast("User not logged in", false);
    return;
  }

  try {
    // ✅ Wait for response message
    final String responseMessage = await cartProvider.addCourseToCart(widget.course['courseId'], userId);

    _showToast(responseMessage, true);

    // Success animation
    await Future.delayed(const Duration(milliseconds: 300));
    _animationController.reverse();
  } catch (e) {
    _showToast('Failed to add course to cart. Please try again.', false);
  } finally {
    setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  widget.course['thumbnail'],
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.fill,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.error_outline, size: 100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _truncateTexts(widget.course['title'], 15),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tutor: ${widget.course['tutorname']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _truncateText(widget.course['description'], 7),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.course['averageRating'].toStringAsFixed(1)} (${widget.course['totalReviews']})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          '\$${widget.course['price']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleAddToCart(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              "Add To Cart",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}