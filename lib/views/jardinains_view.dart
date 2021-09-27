import 'package:flutter/material.dart';
import 'package:jardinains/controller/jardinain_controller.dart';
import 'package:jardinains/controller/service_locator.dart';

class JardinainsView extends StatefulWidget {
  const JardinainsView({Key? key}) : super(key: key);

  @override
  _JardinainsViewState createState() => _JardinainsViewState();
}

class _JardinainsViewState extends State<JardinainsView> {
  final JardinainController _jardinainController = getIt<JardinainController>();

  @override
  void initState() {
    super.initState();

    _jardinainController.addListener(jardianListener);
  }

  @override
  void dispose() {
    super.dispose();

    _jardinainController.removeListener(jardianListener);
  }

  jardianListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: Center(
          child: Stack(
            children: _jardinainController.jardinains
                .map((jardinain) => Positioned(
                    top: jardinain.yPosition, left: jardinain.xPosition, width: _jardinainController.jardinainHeight, height: _jardinainController.jardinainHeight, child: jardinain.jardinain!))
                .toList(),
          ),
        ),
      );
    });
  }
}
