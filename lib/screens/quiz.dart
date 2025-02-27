import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int counter = 0;

  void increment (){
    setState(() {
      counter++;
    });
  } 


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: (){
          increment();
        }, child: Text(counter.toString())),
      ),
    );
  }
} 