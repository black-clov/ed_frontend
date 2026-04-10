import 'dart:io' show Platform;

class Env {
  static String get apiUrl {
    // Production backend on Render
    return 'https://ed-backend-o1dv.onrender.com/api';
  }
}