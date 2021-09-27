import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Jardinain {
  int id;
  double xPosition;
  double yPosition;
  Widget? jardinain;
  Function(double) launchObstacle;

  Jardinain({required this.id, required this.xPosition, required this.yPosition, required this.launchObstacle}) {
    this.jardinain = JardinainWidget(xPosition: this.xPosition, launchObstacle: this.launchObstacle);
  }
}

class JardinainWidget extends StatefulWidget {
  final double xPosition;
  final Function(double) launchObstacle;

  const JardinainWidget({Key? key, required this.xPosition, required this.launchObstacle}) : super(key: key);

  @override
  _JardinainWidgetState createState() => _JardinainWidgetState();
}

class _JardinainWidgetState extends State<JardinainWidget> {
  final RiveAnimationController _idleController = SimpleAnimation('idle',autoplay: false);
  final RiveAnimationController _laughController = SimpleAnimation('Laugh',autoplay: false);
  late Random random;
  late Timer timer;
  String animation = "idle";

  @override
  void initState() {
    super.initState();
    random = Random(widget.xPosition.toInt());
    timer = Timer.periodic(Duration(milliseconds: 4000), (timer) {
      if (random.nextInt(100).isEven) {
        _idleController.isActive = false;
        _laughController.isActive = true;

        widget.launchObstacle(widget.xPosition);
        Future.delayed(Duration(milliseconds: 4000), () {
          _idleController.isActive = true;
          _laughController.isActive = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    _idleController.dispose();
    _laughController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RiveAnimation.asset(
        "assets/rive/jardinain.riv",
        animations: ["idle"],
        controllers: [
          _idleController,
          _laughController,
        ],
      ),
    );
  }
}
