// Not Exactly a Vector, Just to keep the x and y values
import 'package:flutter/material.dart';

class PVector {
  double x, y;

  PVector(this.x, this.y);
}

class PlayBall {
  PVector position = PVector(0.0, 0.0);
  PVector velocity = PVector(0.0, 0.0);
  double radius = 10;
  double jumpFactor = -1.0;
  Color color = Colors.green;
}

class Brick {
  Rect rect;

  Brick({this.rect = Rect.zero});
}