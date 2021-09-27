import 'package:get_it/get_it.dart';
import 'package:jardinains/controller/jardinain_controller.dart';

GetIt getIt = GetIt.instance;

initiateSL(){
  getIt.registerSingleton(JardinainController());
}
