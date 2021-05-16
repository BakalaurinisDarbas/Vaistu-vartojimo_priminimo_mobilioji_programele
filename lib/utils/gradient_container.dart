import 'package:flutter/material.dart';
import 'package:medicine/utils/variables.dart';

class GradientContainer extends StatelessWidget {
  GradientContainer({this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Variables.color.withOpacity(0),
            const Color.fromRGBO(255, 255, 255, 1).withOpacity(1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, 1],
        ),
      ),
      child: child,
    );
  }
}
