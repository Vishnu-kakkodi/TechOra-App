// import 'package:flutter/material.dart';
// import 'package:project/providers/course_list_provider.dart';
// import 'package:project/widgets/course_card.dart';
// import 'package:provider/provider.dart';

// class CourseScreen extends StatefulWidget {
//   const CourseScreen({super.key});

//   @override
//   State<CourseScreen> createState() => _CourseScreenState();
// }

// class _CourseScreenState extends State<CourseScreen> {

//     @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<CourseListProvider>(context, listen: false).fetchCourseData();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//         final courseProvider = Provider.of<CourseListProvider>(context);

//     if (courseProvider.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     return Scaffold(
//   appBar: AppBar(
//     title: const Text("Course Page",
//     style: TextStyle(
//             color: Colors.brown,
//             fontSize: 25,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 2,
//           )
//     ),
//     centerTitle: true,
//     backgroundColor: Colors.teal[100],
//   ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           // Implement refresh functionality
//           // Typically would fetch new data from your backend
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: GridView.builder(
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2, // Show 2 cards per row
//               childAspectRatio: 0.5, // Adjust this value to control card height
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//             ),
//             itemCount: courseProvider.courseData.length,
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: () {
//                   // Navigate to course detail page
//                   // Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //     builder: (context) => CourseDetailScreen(course: dummyCourses[index]),
//                   //   ),
//                   // );
//                 },
//                 child: CourseCard(course: courseProvider.courseData[index]),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:project/providers/course_list_provider.dart';
import 'package:project/screens/course_detail.dart';
import 'package:project/utils/debouncer.dart';
import 'package:project/widgets/course_card.dart';
import 'package:provider/provider.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final Debouncer _debouncer = Debouncer(delay: Duration(seconds: 3));

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Sort and filter variables
  String _selectedSort = 'newest';
  String _selectedFilter = 'all';

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
      Provider.of<CourseListProvider>(context, listen: false).fetchCourseData(
          _searchController.text, _selectedSort, _selectedFilter);
    });
  }

  // Sort bottom sheet
  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Newest'),
              onTap: () {
                setState(() {
                  _selectedSort = 'newest';
                });
                _fetchFilteredCourses();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Oldest'),
              onTap: () {
                setState(() {
                  _selectedSort = 'oldest';
                });
                _fetchFilteredCourses();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              onTap: () {
                setState(() {
                  _selectedFilter = '';
                });
                _fetchFilteredCourses();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Electrical'),
              onTap: () {
                setState(() {
                  _selectedFilter = 'Electrical';
                });
                _fetchFilteredCourses();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Computer Science'),
              onTap: () {
                setState(() {
                  _selectedFilter = 'Computer Science';
                });
                _fetchFilteredCourses();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseListProvider>(context);

    if (courseProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Course Page",
          style: TextStyle(
            color: Colors.brown,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
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
                            builder: (context) =>
                                CourseDetailScreen(id: "6777712ef8763cba1a3b1336",),
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
