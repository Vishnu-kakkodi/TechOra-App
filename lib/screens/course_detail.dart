import 'package:flutter/material.dart';
import 'package:project/screens/chat_screen.dart';
import 'package:project/screens/course_module.dart';
import 'package:provider/provider.dart';
import 'package:project/providers/course_detail_provider.dart';
import 'package:project/models/course_detail_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseDetailScreen extends StatefulWidget {
  final String id;

  const CourseDetailScreen({super.key, required this.id});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  String? accessToken;
  String? userId;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseDetailProvider>(context, listen: false)
          .fetchCourseDetail(widget.id);
    });
  }

  /// Fetch token & userId from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken");
      userId =
          prefs.getString("userId"); // Ensure you stored `userId` during login
    });

    print("Token: $accessToken");
    print("User ID: $userId");
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseDetailProvider>(context);

    if (courseProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // if (courseProvider.errorMessage != null) {
    //   return Scaffold(
    //     body: Center(child: Text(courseProvider.errorMessage!)),
    //   );
    // }

    if (courseProvider.courseDetail == null) {
      return const Scaffold(
        body: Center(child: Text("Course not found")),
      );
    }

    final CourseInfo course = courseProvider.courseDetail!.course;
    final List<String> purchasedCourses =
        courseProvider.courseDetail!.purchasedCourses;
    bool isPurchased = purchasedCourses.contains(course.id);
    final TutorDetails tutor = course.tutor;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: Colors.teal[100],
        actions: [
          // Show chat icon only if the course is purchased
          if (isPurchased)
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.black),
              onPressed: () {
                if (accessToken != null && userId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        tutorname: tutor.name,
                        token: accessToken!,
                        senderId: userId!,
                        receiverId: tutor.id,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User data is not loaded yet!")),
                  );
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (course.thumbnail.isNotEmpty)
                Image.network(
                  course.thumbnail,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              const SizedBox(height: 16),
              Text(
                course.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Instructor: ${tutor.name}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '${course.averageRating.toStringAsFixed(1)} (${course.totalReviews} reviews)',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(course.description),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text('Duration: ${course.duration}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.people, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text('${course.enrolledStudents} students enrolled'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Price: \$${course.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Course Modules',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...course.modules.map((module) => ListTile(
                    title: Text(module.title),
                    subtitle: Text('Duration: ${module.duration} minutes'),
                    trailing: Text(module.status),
                  )),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseModulesScreen(
                        modules: course.modules,
                        courseTitle: course.title,
                        courseId: course.id,
                        purchasedCourses: purchasedCourses,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[100],
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'View Course Modules',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
