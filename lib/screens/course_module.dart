import 'package:flutter/material.dart';
import 'package:project/models/course_detail_model.dart';
import 'package:project/screens/module_player.dart';

class CourseModulesScreen extends StatelessWidget {
  final List<CourseModule> modules;
  final String courseTitle;

  const CourseModulesScreen({
    super.key, 
    required this.modules, 
    required this.courseTitle
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
              icon: const Icon(Icons.play_circle_fill, color: Colors.teal),
              iconSize: 40,
              onPressed: () {
                // Navigate to module player screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModulePlayerScreen(
                      module: module,
                      courseTitle: courseTitle,
                    ),
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