import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jardinains/controller/service_locator.dart';
import 'package:jardinains/views/game_view.dart';
import 'package:jardinains/views/jardinains_view.dart';
import 'package:window_size/window_size.dart';

// MAKING SEPARATE DEVICE FUNCTIONS JUST CUZ.... BETTER CREATE A DIFFERENT CLASS
isDesktop() {
  try {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  } catch (e) {}
  return false;
}

isWeb() {
  try {
    var isWindows = Platform.isWindows;
    return false;
  } catch (e) {
    return true;
  }
}

void main() {
  initiateSL();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    WidgetsFlutterBinding.ensureInitialized();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jardinains Flutter!',
      theme: ThemeData(
        textTheme: GoogleFonts.grandstanderTextTheme(),
        primarySwatch: Colors.blue,
      ),
      home: GameController(),
    );
  }
}

class GameController extends StatefulWidget {
  const GameController({Key? key}) : super(key: key);

  @override
  _GameControllerState createState() => _GameControllerState();
}

class _GameControllerState extends State<GameController> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    if (isDesktop()) {
      setWindowTitle("Flutter Jardinains - RetroPortal Studio");
      setWindowMinSize(Size(1280, 720));
      getWindowInfo().then((value) {
        double width = value.screen!.frame.width;
        double height = value.screen!.frame.height;
        setWindowMaxSize(Size(width, height));
        setWindowFrame(Rect.fromLTRB(0, 0, width, height));
        setState(() {});
      });
    }
    if(!isWeb()){
      Future.delayed(Duration(milliseconds: 2000), () {
        setState(() {
          loading = false;
        });
      });
    }
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      if(isWeb()){
        await webDialog();
        setState(() {
          loading = false;
        });
      }
    });
  }

  webDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("WEB WARNING! - Just for Demonstration",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
            content: Container(
              child: Text("Although this Game can run pretty well Desktop Web, Web is not an optimal platform to run this Game (Especially not on Mobile Devices)"),
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text("I Understand!"))
            ],
          );
        },);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(image: DecorationImage(image: Image.asset("assets/images/app_background.jpg").image, fit: BoxFit.cover)),
          child: Center(
            child: loading
                ? CircularProgressIndicator()
                : Stack(
                    children: [
                      Image.asset(
                        "assets/images/background.png",
                        fit: BoxFit.cover,
                        height: constraints.maxHeight,
                        width: constraints.maxWidth,
                      ),
                      Center(child: JardinainsView()),
                      Center(child: GameView())
                    ],
                  ),
          ),
        );
      }),
    ));
  }
}
