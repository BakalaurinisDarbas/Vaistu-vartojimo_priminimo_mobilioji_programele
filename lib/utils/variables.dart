import 'package:flutter/material.dart';

class Variables {
  static final Color _color = Colors.cyan;

  static final Color color = _color;
  static final errorStyle = TextStyle(color: Colors.red);

  static const BorderRadius borderRadius =
      BorderRadius.all(Radius.circular(15));

  static const Radius radius = Radius.circular(32.0);
  static final borderSide = BorderSide(color: color, width: 1.0);
  static const fillColor = Colors.white;

  static const contentPadding =
      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0);
  static const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(radius),
  );
  static final enabledBorder = OutlineInputBorder(
    borderSide: borderSide,
    borderRadius: BorderRadius.all(radius),
  );
  static final focusedBorder = OutlineInputBorder(
    borderSide: borderSide,
    borderRadius: BorderRadius.all(radius),
  );
}
