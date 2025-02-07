import 'dart:async';
import 'package:flutter/material.dart';


class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(seconds: 0)});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}