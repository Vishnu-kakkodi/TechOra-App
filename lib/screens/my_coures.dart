

import 'package:flutter/material.dart';
import 'package:project/providers/my_course_provider.dart';
import 'package:project/screens/course_detail.dart';
import 'package:project/utils/debouncer.dart';
import 'package:project/widgets/course_card.dart';
import 'package:provider/provider.dart';


class MyCourse extends StatefulWidget {
  const MyCourse({super.key});

  @override
  State<MyCourse> createState() => _MyCourseState();
}

class _MyCourseState extends State<MyCourse> {
  final Debouncer _debouncer = Debouncer(delay: Duration(seconds: 1));

  // Search controller
  final TextEditingController _searchController = TextEditingController();



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFilteredCourses();
    });
  }

  // Method to fetch courses with current sort and filter
  void _fetchFilteredCourses() {
    _debouncer.run(() {
      Provider.of<MyCourseListProvider>(context, listen: false).fetchMyCourseData(
          _searchController.text);
    });
  }


  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<MyCourseListProvider>(context);

    if (courseProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Course Page",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchFilteredCourses();
                  },
                ),
              ),
              onChanged: (_) => _fetchFilteredCourses(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _fetchFilteredCourses();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: courseProvider.courseData.length,
                  itemBuilder: (context, index) {
                    final course = courseProvider.courseData[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailScreen(id: course['courseId']),
                          ),
                        );
                      },
                      child: CourseCard(course: course),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
