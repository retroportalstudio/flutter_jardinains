import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Jardinain {
  int id;
  double xPosition;
  double yPosition;
  Widget jardinain;
  Jardinain({required this.id,required this.xPosition,required this.yPosition,required this.jardinain});
}

class JardinainWidget extends StatefulWidget {
  final Function launchObstacle;

  const JardinainWidget({Key? key,required this.launchObstacle}) : super(key: key);

  @override
  _JardinainWidgetState createState() => _JardinainWidgetState();
}

class _JardinainWidgetState extends State<JardinainWidget> {
  final RiveAnimationController _controller = SimpleAnimation('idle');
  final Random random = Random();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 4000), (timer) {
      if(random.nextBool()){

      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RiveAnimation.asset(
        "assets/rive/jardinain.riv",
        animations: ["idle"],
        controllers: [_controller],
      ),
    );
  }
}
