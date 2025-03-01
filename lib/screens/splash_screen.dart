import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/screens/home.dart';
import 'package:project/screens/login.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _elementsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  late AnimationController _bookAnimationController;
  late Animation<double> _bookOpenAnimation;
  
  late AnimationController _courseElementsController;
  List<Animation<Offset>> _elementOffsetAnimations = [];
  final List<IconData> _courseIcons = [
    Icons.video_library,
    Icons.assignment,
    Icons.book,
    Icons.lightbulb,
    Icons.public,
    Icons.school,
  ];
  
  @override
  void initState() {
    super.initState();
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );
    
    _bookAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _bookOpenAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bookAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _courseElementsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    final List<Offset> startOffsets = [
      const Offset(-0.5, 0),  
      const Offset(0.5, 0),   
      const Offset(0, -0.5), 
      const Offset(0.5, 0.5), 
      const Offset(-0.5, 0.5),
      const Offset(0, 0.5),   
    ];
    
    for (int i = 0; i < _courseIcons.length; i++) {
      _elementOffsetAnimations.add(
        Tween<Offset>(
          begin: startOffsets[i],
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _courseElementsController,
            curve: Interval(
              0.2 + (i * 0.1),  
              0.7 + (i * 0.05),  
              curve: Curves.elasticOut,
            ),
          ),
        ),
      );
    }
    
    _elementsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _bookAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _courseElementsController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      _elementsAnimationController.forward();
    });
    
    _navigateToNextScreen();
  }
  
  @override
  void dispose() {
    _logoAnimationController.dispose();
    _bookAnimationController.dispose();
    _courseElementsController.dispose();
    _elementsAnimationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            isLoggedIn ? MainScreen() : LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.indigo.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(_courseIcons.length, (index) {
                      return AnimatedBuilder(
                        animation: _courseElementsController,
                        builder: (context, child) {
                          final angle = index * (math.pi * 2 / _courseIcons.length);
                          
                          return Positioned(
                            left: MediaQuery.of(context).size.width / 2 - 12 + 
                                  math.cos(angle) * 80 * _courseElementsController.value,
                            top: MediaQuery.of(context).size.height / 4 - 12 + 
                                 math.sin(angle) * 80 * _courseElementsController.value,
                            child: Opacity(
                              opacity: _courseElementsController.value,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: [
                                    Colors.blue.shade400,
                                    Colors.green.shade400,
                                    Colors.orange.shade400,
                                    Colors.purple.shade400,
                                    Colors.red.shade400,
                                    Colors.teal.shade400,
                                  ][index],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _courseIcons[index],
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    
                    AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _bookAnimationController,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: _bookOpenAnimation.value * math.pi * 0.5,
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: 60,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(4),
                                          bottomRight: Radius.circular(4),
                                        ),
                                        boxShadow: _bookOpenAnimation.value > 0.5 ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 2,
                                            offset: const Offset(1, 1),
                                          ),
                                        ] : [],
                                      ),
                                      child: Center(
                                        child: Opacity(
                                          opacity: _bookOpenAnimation.value,
                                          child: Icon(
                                            Icons.school,
                                            size: 24,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  Container(
                                    width: 60,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.menu_book,
                                        size: 24,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                AnimatedBuilder(
                  animation: _elementsAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _elementsAnimationController.value,
                      child: child,
                    );
                  },
                  child: const Text(
                    "TechOra",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                AnimatedBuilder(
                  animation: _elementsAnimationController,
                  builder: (context, child) {
                    final opacity = _elementsAnimationController.value > 0.3 ? 
                        math.min((_elementsAnimationController.value - 0.3) * 1.43, 1.0) : 0.0;
                    return Opacity(
                      opacity: opacity,
                      child: child,
                    );
                  },
                  child: Text(
                    "Learn. Grow. Succeed.",  
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                
                const SizedBox(height: 50),
                
                AnimatedBuilder(
                  animation: _elementsAnimationController,
                  builder: (context, child) {
                    final opacity = _elementsAnimationController.value > 0.6 ? 
                        math.min((_elementsAnimationController.value - 0.6) * 2.5, 1.0) : 0.0;
                    return Opacity(
                      opacity: opacity,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade400),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}