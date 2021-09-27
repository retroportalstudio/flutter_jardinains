import 'package:flutter/foundation.dart';
import 'package:jardinains/elements/jardinain.dart';

class JardinainController extends ChangeNotifier {
  double _jardinainHeight = 0;
  List<Jardinain> _jardinains = [];

  void setJardinains(List<Jardinain> jards) {
    this._jardinains = jards;
    notifyListeners();
  }

  List<Jardinain> get jardinains => this._jardinains;

  set jardinainHeight(double height) => this._jardinainHeight = height;

  double get jardinainHeight => this._jardinainHeight;

  removeJardinain(int id){
    _jardinains.removeWhere((element) => element.id == id);
    notifyListeners();
  }


}