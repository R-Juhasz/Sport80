import 'dart:math' as math; // Importing math library
import 'package:flutter/widgets.dart';

class Responsive {
  late double _width, _height, _diagonal;
  late bool isTablet, isPhone;

  Responsive(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    _width = mediaQuery.size.width;
    _height = mediaQuery.size.height;
    // Calculate the diagonal size of the screen using Pythagoras theorem
    _diagonal = math.sqrt(mediaQuery.size.width * mediaQuery.size.width + mediaQuery.size.height * mediaQuery.size.height);
    // Determine device type
    var diagonalInches = _diagonal / mediaQuery.devicePixelRatio;
    isTablet = diagonalInches > 7;  // A typical tablet screen is larger than 7 inches diagonally
    isPhone = diagonalInches <= 7; // A typical phone screen is smaller than or equal to 7 inches diagonally
  }

  // Getters to access screen dimensions proportionally
  double wp(double percent) => _width * percent / 100;
  double hp(double percent) => _height * percent / 100;
  double dp(double percent) => _diagonal * percent / 100;

  // Example to scale text size accordingly
  double sp(double fontSize) => fontSize * (_width / 1) / 125;
}

// Example usage inside a widget:
// Responsive responsive = Responsive(context);
// double width20 = responsive.wp(20); // get 20% of screen width
// double height10 = responsive.hp(10); // get 10% of screen height
// double textScaled = responsive.sp(12); // get scaled text size
