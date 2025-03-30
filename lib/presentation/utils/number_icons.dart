import 'package:flutter/material.dart';

IconData getNumberIcon(int number) {
  switch (number) {
    case 1:
      return Icons.looks_one;
    case 2:
      return Icons.looks_two;
    case 3:
      return Icons.looks_3;
    case 4:
      return Icons.looks_4;
    case 5:
      return Icons.looks_5;
    case 6:
      return Icons.looks_6;
    default:
      return Icons.format_list_numbered;
  }
}
