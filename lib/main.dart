import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  runApp(const MyApp());
}

int calculateLargeOnTop(int count) {
  int sum = 0;
  for (int i = 0; i < count; i++) {
    sum++;
  }
  return sum;
}
