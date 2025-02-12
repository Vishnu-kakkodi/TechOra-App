import 'package:flutter/material.dart';
import 'package:project/models/course_detail_model.dart';
import 'package:project/screens/module_player.dart';

class CourseModulesScreen extends StatelessWidget {
  final List<CourseModule> modules;
  final String courseTitle;
  final String courseId;
  final List<String> purchasedCourses;

  const CourseModulesScreen({
    super.key,
    required this.modules,
    required this.courseTitle,
    required this.courseId,
    required this.purchasedCourses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$courseTitle - Modules'),
        backgroundColor: Colors.teal[100],
      ),
      body: ListView.separated(
        itemCount: modules.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final module = modules[index];
          final bool isPurchased = purchasedCourses.contains(courseId);

          return ListTile(
            title: Text(
              module.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Duration: ${module.duration} minutes',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: Icon(
                isPurchased ? Icons.play_circle_fill : Icons.lock,
                color: isPurchased ? Colors.teal : Colors.red,
              ),
              iconSize: 40,
              onPressed: isPurchased
                  ? () {
                      // Navigate to module player if purchased
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModulePlayerScreen(
                            videoUrl: module.videoUrl,
                            moduleTitle: module.title,
                          ),
                        ),
                      );
                    }
                  : () {
                      // Show alert if not purchased
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You need to purchase this course to access the module.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: module.status == 'completed'
                    ? Colors.green[100]
                    : module.status == 'in_progress'
                        ? Colors.orange[100]
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: module.status == 'completed'
                        ? Colors.green
                        : module.status == 'in_progress'
                            ? Colors.orange
                            : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
