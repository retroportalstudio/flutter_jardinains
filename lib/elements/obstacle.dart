import 'package:flutter/material.dart';

class Obstacle {
  int id;
  double xPosition;
  double yPosition;
  Widget obstacle = _ObstacleWidget();


  Obstacle({required this.id, required this.xPosition, required this.yPosition});
}

class _ObstacleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        "assets/images/flower_pot.png",
      ),
    );
  }
}
