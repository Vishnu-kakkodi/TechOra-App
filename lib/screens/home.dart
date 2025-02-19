import 'package:flutter/material.dart';
import 'package:project/providers/course_provider.dart';
import 'package:project/providers/winners_provider.dart';
import 'package:project/screens/account.dart';
import 'package:project/widgets/winners_carousel.dart';
import 'package:project/widgets/course_card.dart';
import 'package:provider/provider.dart';
import 'package:project/screens/cart.dart';
import 'package:project/screens/course.dart';
import 'package:project/screens/profile.dart';
import 'package:project/screens/quiz.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const CourseScreen(),
    const QuizScreen(),
    const CartScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.teal[100],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber,
          unselectedItemColor: Colors.black,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.book_rounded, Icons.book_outlined, 'Courses', 1),
            _buildNavItem(Icons.quiz_rounded, Icons.quiz_outlined, 'Quiz', 2),
            _buildNavItem(Icons.shopping_cart_rounded, Icons.shopping_cart_outlined, 'Cart', 3),
            _buildNavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Account', 4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData selectedIcon,
    IconData unselectedIcon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          _selectedIndex == index ? selectedIcon : unselectedIcon,
          key: ValueKey<bool>(_selectedIndex == index),
          size: _selectedIndex == index ? 28 : 24,
        ),
      ),
      label: label,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WinnersProvider>(context, listen: false).fetchWinnersData();
      Provider.of<CourseProvider>(context, listen: false).fetchWinnersData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final winnersProvider = Provider.of<WinnersProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);

    if (winnersProvider.isLoading || courseProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
  appBar: AppBar(
    title: const Text("Home Page",
    style: TextStyle(
            color: Colors.brown,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          )
    ), 
    centerTitle: true, 
    backgroundColor: Colors.teal[100],
  ),
  body: ListView(
    children: [
      // Static Images Section
      Container(
        height: 200,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: PageView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/home/Carosal2.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/home/Carosal1.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/home/Carosal3.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Winners Carousel
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: WinnersCarousel(winners: winnersProvider.winners),
      ),
      
      // Available Courses Text
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Latest Courses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Course Cards
      GestureDetector(
        onHorizontalDragUpdate: (details) {
          // This enables manual dragging/swiping
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: courseProvider.courseData.map((course) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 250, 
                  child: CourseCard(course: course),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      
      // Start Quiz Section
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Quiz Banner Image
                Image.asset(
                  'assets/home/Quiz.jpg',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Gradient Overlay
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Start Quiz Button
                Positioned(
                  bottom: 10,
                  left: 100,
                  right: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your quiz start logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Start Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
  }
}