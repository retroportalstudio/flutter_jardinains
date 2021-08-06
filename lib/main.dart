import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

// Not Exactly a Vector, Just to keep the x and y values
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

const MODES = [
  [5, "Easy"],
  [7, "Medium"],
  [8, "Hard"]
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jardinains Flutter!',
      theme: ThemeData(
        textTheme: GoogleFonts.grandstanderTextTheme(),
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Random random = Random();
  final GlobalKey _globalKey = GlobalKey();
  final fps = 1 / 60; // Frame Rate of 60 Frames per second
  final PlayBall playBall = PlayBall();
  Size screenSize = Size.zero, brickWallSize = Size.zero, platformSize = Size(200, 50), brickSize = Size(70, 25);
  Offset pointer = Offset.zero;
  List<Brick> bricks = [];
  Timer? timer;
  bool launched = false, finishing = false, reviving = false, firstGame = true;
  int mode = 5, health = 3, score = 0, prevScore = 0, singleShotKills = 0;
  bool isMobile = false;

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    isMobile = Platform.isAndroid || Platform.isIOS;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      setupGame();
    });
  }

  setupGame() {
    RenderBox? renderBox = _globalKey.currentContext!.findRenderObject() as RenderBox?;
    screenSize = renderBox!.size;
    brickWallSize = Size(screenSize.width, screenSize.height * 0.50);
    double platformWidth = screenSize.width * 0.15;
    platformSize = Size(platformWidth, platformWidth / 4);
    playBall.radius = platformWidth * 0.05;
    playBall.color = Colors.black;
    createBrickWall();
    gameDialog();
  }

  reset() {
    if (timer != null) {
      timer!.cancel();
    }
    setState(() {
      firstGame = false;
      finishing = false;
      launched = false;
      reviving = false;
      health = 3;
      score = 0;
      singleShotKills = 0;
    });
    setupGame();
  }

  frameBuilder(dynamic timestamp) {
    if (!launched) {
      return;
    }

    // Calculating Position Change
    playBall.position.x += playBall.velocity.x * fps * 100;
    playBall.position.y += playBall.velocity.y * fps * 100;

    // Calculating Position and Velocity Changes after Wall Collision
    collision(playBall);
    brickFilter();
    if (bricks.isEmpty) {
      launched = false;
      finishing = true;
      prevScore = score;
      Future.delayed(Duration(milliseconds: 4000), () {
        reset();
      });
    }
    setState(() {});
  }

  // To detect brick collision, deflect the ball and remove the brick which caused collision
  brickFilter() {
    for (int x = 0; x < bricks.length; x++) {
      Brick brick = bricks[x];
      if (brick.rect.contains(Offset(playBall.position.x, playBall.position.y))) {
        if (singleShotKills < 5 || playBall.velocity.y.isNegative) {
          playBall.velocity.y *= playBall.jumpFactor;
        }
        bricks.removeAt(x);
        score += 50;
        if (singleShotKills > 0) {
          score += 10;
        }
        singleShotKills++;
        break;
      }
    }
  }

  collision(PlayBall pt) {
    // Collision with Right of the Box Wall
    if (pt.position.x >= screenSize.width - pt.radius) {
      pt.velocity.x *= pt.jumpFactor;
      pt.position.x = screenSize.width - pt.radius;
    }

    // Collision with Left of the Box Wall
    if (pt.position.x <= pt.radius) {
      pt.velocity.x *= pt.jumpFactor;
      pt.position.x = pt.radius;
    }

    if (pt.position.y <= pt.radius) {
      pt.velocity.y *= pt.jumpFactor;
    }

    if (pt.position.y > (screenSize.height - platformSize.height - pt.radius) &&
        pt.position.x > (pointer.dx - platformSize.width / 2 - pt.radius) &&
        pt.position.x < (pointer.dx + platformSize.width / 2 + pt.radius)) {
      if (pt.position.y < screenSize.height) {
        int nextVelocity = random.nextInt(mode);
        playBall.velocity.x = nextVelocity.toDouble();
        if (random.nextBool()) {
          playBall.velocity.x *= -1;
        }
        pt.velocity.y *= -1.0;
        pt.position.y = screenSize.height - pt.radius - platformSize.height;
        singleShotKills = 0;
      }
    }
    if (pt.position.y > screenSize.height) {
      launched = false;
      if (health > 0) {
        --health;
        reviving = true;
        singleShotKills = 0;
        timer!.cancel();
        Future.delayed(Duration(milliseconds: 2000), () {
          setState(() {
            reviving = false;
          });
        });
      } else {
        finishing = true;
        prevScore = score;
        Future.delayed(Duration(milliseconds: 2000), () {
          reset();
        });
      }
    }
  }

  gameDialog() async {
    final borderRadius = BorderRadius.circular(20.0);
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final jardianSize = (isMobile ? 70.0 : 150.0);
          return Dialog(
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              child: StatefulBuilder(
                builder: (context, updateState) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                          top: -jardianSize,
                          left: 0,
                          child: Center(
                              child: Image.asset(
                            "assets/images/jardinain.png",
                            height: jardianSize,
                          ))),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Jardinains!",
                                style: TextStyle(
                                    fontSize: isMobile ? 45 : 74, fontWeight: FontWeight.bold, color: Colors.green, shadows: [BoxShadow(color: Colors.black, blurRadius: 1, spreadRadius: 5)]),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: MODES
                                      .map((e) => InkWell(
                                            onTap: () {
                                              updateState(() {
                                                mode = e[0] as int;
                                              });
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.all(5),
                                              width: 100,
                                              decoration: BoxDecoration(color: e[0] == mode ? Colors.green : Colors.grey, borderRadius: borderRadius),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Center(
                                                    child: Text(
                                                  "${e[1]}",
                                                  style: TextStyle(
                                                    fontSize: isMobile ? 15 : 20,
                                                    color: Colors.white,
                                                  ),
                                                )),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!firstGame) ...[
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Previous Score",
                                          style: TextStyle(fontSize: isMobile ? 20 : 40, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                        Text(
                                          "$prevScore",
                                          style: TextStyle(fontSize: isMobile ? 20 : 40, fontWeight: FontWeight.bold, color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ],
                                  SizedBox(
                                    width: 20,
                                  ),
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(borderRadius: borderRadius),
                                    color: Colors.orange,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        firstGame ? "Start Game" : "Restart",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isMobile ? 20 : 25),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ));
        });
  }

  // Creates a random brick wall based on the size of window at that moment
  createBrickWall() {
    bricks = [];
    int maxColumnCount = (brickWallSize.width / brickSize.width).floor();
    int maxRowCount = (brickWallSize.height / brickSize.height).floor();
    bool prevOdd = true; // Offset the Alignment of Bricks to mimic a real wall
    for (int x = 0; x < maxRowCount; x++) {
      Random random = Random();
      int currentColumnCount = max(4, random.nextInt(maxColumnCount));
      if (prevOdd && currentColumnCount.isOdd) {
        currentColumnCount += 1;
      } else if (!prevOdd && currentColumnCount.isEven) {
        currentColumnCount += 1;
      }
      prevOdd = currentColumnCount.isOdd;

      double leftOffset = ((screenSize.width - (currentColumnCount * brickSize.width)) / 2);
      for (int y = 0; y < currentColumnCount; y++) {
        Rect rect = Rect.fromLTWH(leftOffset + (y.toDouble() * brickSize.width), x * brickSize.height, brickSize.width, brickSize.height);
        bricks.add(Brick(rect: rect));
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(image: DecorationImage(image: Image.asset("assets/images/app_background.jpg").image, fit: BoxFit.cover)),
          child: GestureDetector(
            onTap: () {
              if (!launched && !finishing) {
                launched = true;
                playBall.position = PVector(pointer.dx, screenSize.height - platformSize.height - playBall.radius);
                playBall.velocity = PVector(-mode.toDouble(), -mode.toDouble());
                // Refreshing State at Rate of 60/Sec
                timer = Timer.periodic(Duration(milliseconds: (fps * 1000).floor()), frameBuilder);
              }
            },
            onPanUpdate: (panDetails) {
              if (Platform.isAndroid) {
                setState(() {
                  this.pointer = panDetails.localPosition;
                });
              }
            },
            child: Center(
              child: Container(
                key: _globalKey,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                constraints: BoxConstraints(maxWidth: 1280, maxHeight: 720),
                child: MouseRegion(
                  onHover: (pointer) {
                    if (pointer.position != Offset.zero) {
                      setState(() {
                        this.pointer = pointer.localPosition;
                      });
                    }
                  },
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/background.png",
                        fit: BoxFit.cover,
                        height: screenSize.height,
                        width: screenSize.width,
                      ),
                      ...bricks
                          .map((brick) => Positioned(
                                left: brick.rect.left,
                                top: brick.rect.top,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                    color: Colors.black,
                                  )),
                                  width: brickSize.width,
                                  height: brickSize.height,
                                  child: Image.asset(
                                    "assets/images/brick.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ))
                          .toList(),
                      if (!finishing) ...[
                        launched
                            ? Positioned(
                                top: playBall.position.y,
                                left: playBall.position.x,
                                child: Image.asset(
                                  "assets/images/cannon_ball.png",
                                  width: playBall.radius * 2,
                                  height: playBall.radius * 2,
                                ))
                            : Positioned(
                                bottom: platformSize.height,
                                left: pointer.dx,
                                child: Image.asset(
                                  "assets/images/cannon_ball.png",
                                  width: playBall.radius * 2,
                                  height: playBall.radius * 2,
                                )),
                      ],
                      Positioned(
                        left: pointer.dx - (platformSize.width / 2),
                        bottom: 0,
                        child: Image.asset("assets/images/grass_platform.png", width: platformSize.width, height: platformSize.height, fit: BoxFit.fill),
                      ),
                      Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(10.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Score:",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                  ),
                                  Text(
                                    "$score",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                        health,
                                        (index) => Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                              size: 30,
                                            )),
                                  )
                                ],
                              ),
                            ),
                          )),
                      if (finishing) ...[
                        Center(
                          child: bricks.isEmpty ? Image.asset("assets/images/up_high.gif") : Image.asset("assets/images/laughing.gif"),
                        )
                      ],
                      if (reviving) ...[
                        Center(
                          child: TweenAnimationBuilder(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 200),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value as double,
                                child: child,
                              );
                            },
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: screenSize.width * 0.25,
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      })),
    );
  }
}
