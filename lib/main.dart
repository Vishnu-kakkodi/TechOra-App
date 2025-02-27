import 'package:flutter/material.dart';
import 'package:project/providers/cart_provider.dart';
import 'package:project/providers/course_detail_provider.dart';
import 'package:project/providers/course_list_provider.dart';
import 'package:project/providers/leader_board_provider.dart';
import 'package:project/providers/my_course_provider.dart';
import 'package:project/providers/order_datail_provider.dart';
import 'package:project/providers/order_list_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:project/providers/course_provider.dart';
import 'package:project/providers/winners_provider.dart';
import 'package:project/screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => WinnersProvider()),
        ChangeNotifierProvider(create: (context) => CourseProvider()),
        ChangeNotifierProvider(create: (context) => CourseListProvider()),
        ChangeNotifierProvider(create: (_) => CourseDetailProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (context) => MyCourseListProvider()),
        ChangeNotifierProvider(create: (context) => OrderListProvider()),
        ChangeNotifierProvider(create: (context) => OrderDetailProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Techora App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:project/providers/course_detail_provider.dart';
// import 'package:project/providers/course_list_provider.dart';
// import 'package:project/screens/home.dart';
// import 'package:provider/provider.dart';
// import 'package:project/providers/auth_provider.dart';
// import 'package:project/providers/course_provider.dart';
// import 'package:project/providers/winners_provider.dart';
// import 'package:project/screens/login.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//   bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => AuthProvider()),
//         ChangeNotifierProvider(create: (context) => WinnersProvider()),
//         ChangeNotifierProvider(create: (context) => CourseProvider()),
//         ChangeNotifierProvider(create: (context) => CourseListProvider()),
//         ChangeNotifierProvider(create: (_) => CourseDetailProvider()),
//       ],
//       child:  MyApp(isLoggedIn: isLoggedIn),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   final bool isLoggedIn;

//   const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Techora App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: isLoggedIn ? HomePage() : LoginPage(),
//     );
//   }
// }
