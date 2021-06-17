import 'dart:html';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:typed_data';
import 'dashboard.dart';
import 'package:image/image.dart' as mimage;
import 'home.dart';

enum ACTIVE { DRAG, DOT, EDIT }
int mode = 1;

List<List<List<Offset>>> totalList = [[], []];
int imageIndex = 0;

class NextPage extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    Object argument = ModalRoute.of(context).settings.arguments;

    return MaterialApp(
      title: 'Flutter Demo',
      routes: {
        '/home': (context) => HomePage(),
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ui.Image> imagelist = [];
  bool isImageloaded = false;
  // GlobalKey _myCanvasKey = new GlobalKey();
  List<String> imglist = [];

  void initState() {
    super.initState();
    imglist.add("img/guide1.png");
    imglist.add('img/guide2.png');

    for (var l in imglist) {
      getUiImage(l, 400, 400); //height, width순
    }
  }

  // Future<Null> init() async {
  //   final ByteData data = await rootBundle.load('img/guide1.png');
  //   image = await loadImage(Uint8List.view(data.buffer));
  // }

  Future<Null> getUiImage(String imageAssetPath, int height, int width) async {
    //imagelist.add(null);
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    mimage.Image baseSizeImage =
        mimage.decodeImage(assetImageByteData.buffer.asUint8List());
    mimage.Image resizeImage =
        mimage.copyResize(baseSizeImage, height: height, width: width);

    ui.Codec codec = await ui.instantiateImageCodec(
        Uint8List.fromList(mimage.encodePng(resizeImage)));
    ui.FrameInfo frameInfo = await codec.getNextFrame();

    imagelist.add(frameInfo.image);
    //debugPrint("done");

    setState(() {
      isImageloaded = true;
    });
  }

  // Future<ui.Image> loadImage(List<int> img) async {
  //   final Completer<ui.Image> completer = Completer();
  //   ui.decodeImageFromList(img, (ui.Image img) {
  //     setState(() {
  //       isImageloaded = true;
  //     });
  //     return completer.complete(img);
  //   });
  //   return completer.future;
  // }
  Offset deletePosition;
  var ismove = false;
  int tx;
  int ty;
  double revise_width;
  double revise_height;
  ACTIVE _active = ACTIVE.DRAG;
  PageController _pageController = PageController();
  int controller = 0;
  // 마우스
  Widget _buildImage(GlobalKey myKey, ui.Image img, int mode, int index) {
    Size screenSize = MediaQuery.of(context).size;
    //print(screenSize);
    if (isImageloaded) {
      if (mode == 1) {
        //print(img.width);
        //print(img.height);
        ImageEditor editor = ImageEditor(image: img, imageIndex: index);
        return Container(
          width: img.width.toDouble() * 2 / 3,
          height: img.height.toDouble(),

          // padding: EdgeInsets.all(screenSize.width * 0.05),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          child: GestureDetector(
            onPanUpdate: (details) {
              if (ismove) {
                editor.pointslist[tx][ty] = details.localPosition;
                myKey.currentContext.findRenderObject().markNeedsPaint();
                //repaint?
              }
            },
            onPanStart: (details) {
              var mousepoint = details.localPosition;
              if (tx == null) {
                ismove = false;
                for (var j = 0; j < editor.pointslist.length; j++) {
                  for (var i = 0; i < editor.pointslist[j].length; i++) {
                    if (distance(mousepoint, editor.pointslist[j][i]) <= 5) {
                      tx = j;
                      ty = i;

                      ismove = true;
                      break;
                    }
                  }
                }
              }
              if (ismove) {
                editor.pointslist[tx][ty] = details.localPosition;
              } else {
                editor.update(details.localPosition);

                myKey.currentContext.findRenderObject().markNeedsPaint();
              }
            },
            onPanEnd: (dragEndDetails) {
              editor.currentrect();
              var a = editor.pointslist;
              //debugPrint("start : $a");
              myKey.currentContext.findRenderObject().markNeedsPaint();
              tx = null;
              ty = null;
            },
            child: CustomPaint(
                key: myKey,
                painter: editor,
                size: Size(img.width.toDouble(), img.height.toDouble())),
//                  size: Size(img.width.toDouble(), revise_heightimg.height.toDouble())),
          ),
        );
      } else if (mode == 2) {
        RectanglePainter editor =
            RectanglePainter(image: img, imageIndex: index);
        return Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          child: GestureDetector(
            onPanStart: (details) {
              //print("OnStart");
              editor.start(details.localPosition);

              myKey.currentContext.findRenderObject().markNeedsPaint();
            },
            onPanUpdate: (details) {
              //print("Update");
              editor.update(details.localPosition);
              myKey.currentContext.findRenderObject().markNeedsPaint();
            },
            onPanEnd: (DragEndDetails) {
              //print("End");
              editor.end();
              myKey.currentContext.findRenderObject().markNeedsPaint();
            },
            child: CustomPaint(
              key: myKey,
              painter: editor,
              size: Size(img.width.toDouble(), img.height.toDouble()),
            ),
          ),
        );
      } else if (mode == 3) {
        BoxEditor editor = BoxEditor(image: img, imageIndex: index);
        return Container(
          // padding: EdgeInsets.all(screenSize.width * 0.05),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          child: GestureDetector(
            onPanStart: (details) {
              //print("OnStart");
              editor.myXY(details.localPosition);
              editor.mybox();

              myKey.currentContext.findRenderObject().markNeedsPaint();
            },
            onPanUpdate: (details) {
              //print("Update");
              editor.update(details.localPosition);

              myKey.currentContext.findRenderObject().markNeedsPaint();
            },
            onPanEnd: (DragEndDetails) {
              //print("End");
              editor.end();
              myKey.currentContext.findRenderObject().markNeedsPaint();
            },
            onDoubleTapDown: (details) {
              //print("DoubleTapDown");
              deletePosition = details.localPosition;
              myKey.currentContext.findRenderObject().markNeedsPaint();
            },
            onDoubleTap: () {
              //print("DoubleTap");
              editor.delete(deletePosition);
              myKey.currentContext.findRenderObject().markNeedsPaint();
              deletePosition = null;
            },
            child: CustomPaint(
              key: myKey,
              painter: editor,
              size: Size(img.width.toDouble(), img.height.toDouble()),
            ),
          ),
        );
      }
    } else {
      return Center(child: Text('loading'));
    }
  }

  double distance(Offset a, Offset b) {
    return sqrt(pow(a.dx - b.dx, 2) + pow(a.dy - b.dy, 2));
  }

  // TODO : resize image
  /* Image resize_image(Image origin_image) {
    List<int> temp_image;
    for (int i = 0; i < revise_height; i++) {
      for (int j = 0; j < revise_width; j++) {
        temp_image[i][j] = image.toString()[i][j];
      }
    }
    return origin_image[revise_height.toInt()][revise_width.toInt()];
  }*/
  int imageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("working"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: ScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                width: 400,
                height: 400,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Scrollbar(
                    controller: _pageController,
                    isAlwaysShown: true,
                    child: PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
                        itemCount: imagelist.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          imageIndex = index;
                          //resized_image = resize_image(imagelist[index]);
                          //return _buildImage(new GlobalKey(), resized_image, mode);
                          return _buildImage(new GlobalKey(), imagelist[index],
                              mode, imageIndex);
                        }),
                    // children: [
                    //   _buildImage(new GlobalKey(), imglist[0], 0),
                    //   _buildImage(new GlobalKey(), imglist[1], 1),
                    // ]),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_left),
                      iconSize: 48,
                      onPressed: () {
                        setState(() {
                          if (controller <= 0) {
                            controller = 0;
                            imageIndex = 0;
                          } else if (controller > 0) {
                            controller = controller - 1;
                            _pageController.previousPage(
                                duration: Duration(milliseconds: 50),
                                curve: Curves.easeInOut);

                            //totalList.clear();
                            imageIndex = imageIndex - 1;
                          }
                          print(controller);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_right),
                      iconSize: 48,
                      onPressed: () {
                        setState(() {
                          if (controller == imagelist.length - 1) {
                            controller = imagelist.length - 1;
                          } else if (controller >= 0) {
                            controller = controller + 1;
                            _pageController.nextPage(
                                duration: Duration(milliseconds: 50),
                                curve: Curves.easeInOut);

                            //totalList.clear();
                            imageIndex = imageIndex + 1;
                          }
                          print(controller);
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(children: [
                Flexible(
                    flex: 1,
                    child: Column(children: [
                      ListTile(
                        title: Text("점 모드"),
                        leading: Radio<ACTIVE>(
                          value: ACTIVE.DRAG,
                          groupValue: _active,
                          onChanged: (ACTIVE value) {
                            setState(() {
                              _active = value;
                              mode = 1;
                            });
                            //print("점");
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        title: Text("드래그 모드"),
                        leading: Radio<ACTIVE>(
                          value: ACTIVE.DOT,
                          groupValue: _active,
                          onChanged: (ACTIVE value) {
                            setState(() {
                              _active = value;
                              mode = 2;
                            });
                            //print("드래그");
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        title: Text("수정 모드"),
                        leading: Radio<ACTIVE>(
                          value: ACTIVE.EDIT,
                          groupValue: _active,
                          onChanged: (ACTIVE value) {
                            setState(() {
                              _active = value;
                              mode = 3;
                            });
                            //print("수정");
                          },
                        ),
                      ),
                    ])),
                Flexible(
                  flex: 1,
                  child: ConstrainedBox(
                    //padding: EdgeInsets.all(20.0),
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(8),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return ListTile(
                          //autofocus: true,

                          title: Text("$index"),
                          onTap: () {
                            print("$index");
                          },
                        );
                      },
                    ),
                  ),
                ),
              ]),
              Row(
                children: [
                  Flexible(
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (imageIndex > 0) {
                                  totalList[imageIndex] = [
                                    ...totalList[imageIndex - 1]
                                  ];
                                }
                              });
                            },
                            child: Text("이전 프레임 박스 정보 가져오기"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              textStyle: TextStyle(fontSize: 13),
                            ),
                          ))),
                  Flexible(
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text("이전 프레임 기반 자동 박스 생성"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              textStyle: TextStyle(fontSize: 13),
                            ),
                          ))),
                ],
              ),
              Row(
                children: [
                  Flexible(
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                totalList[imageIndex].clear();
                              });
                            },
                            child: Text("전체 삭제"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              textStyle: TextStyle(fontSize: 15),
                            ),
                          ))),
                  Flexible(
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text("제출"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black,
                              textStyle: TextStyle(fontSize: 15),
                            ),
                          ))),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        totalList.clear();
                        Navigator.pushNamed(context, '/home');
                        mode = 1;
                      },
                      child: Text("뒤로가기"),
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(180, 20),
                          textStyle: TextStyle(fontSize: 20),
                          primary: Colors.white,
                          onPrimary: Colors.black)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BoxEditor extends CustomPainter {
  ui.Image image;
  List<Offset> myBox = [];
  List<Offset> tempBox = [];
  Offset temp;
  Offset click;
  Offset updateXY;
  Offset changing1;
  Offset changing2;
  Offset changing3;
  Offset changing4;
  double changeX;
  double changeY;
  bool isChanging = false;
  int imageIndex = 0;
  BoxEditor({
    this.image,
    this.imageIndex,
  });
  final Paint datpainter = new Paint()
    ..color = Colors.blue[50]
    ..style = PaintingStyle.fill;
  final Paint linepainter = new Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  void myXY(Offset offset) {
    click = offset;
    //print("누른 좌표 = $click");
  }

  void mybox() {
    List<int> indexList = checkCrossLine(totalList[imageIndex], click);
    //print(indexList);

    int i = 0;
    if (indexList.length == 0) {
      return;
    } else if (indexList.length >= 1) {
      for (int index in indexList) {
        i = index;
        tempBox = totalList[imageIndex][i];
      }
    }
    return;
  }

  void update(Offset offset) {
    updateXY = offset;
    if (tempBox.length == 4) {
      isChanging = true;
      changeX = click.dx - updateXY.dx;
      changeY = click.dy - updateXY.dy;
      changing1 = Offset(tempBox[0].dx - changeX, tempBox[0].dy - changeY);
      changing2 = Offset(tempBox[1].dx - changeX, tempBox[1].dy - changeY);
      changing3 = Offset(tempBox[2].dx - changeX, tempBox[2].dy - changeY);
      changing4 = Offset(tempBox[3].dx - changeX, tempBox[3].dy - changeY);
    } else if (tempBox.length == 0) {
      return;
    }
  }

  void end() {
    if (tempBox.length == 4) {
      for (Offset point in tempBox) {
        temp = Offset(point.dx - changeX, point.dy - changeY);
        myBox.add(temp);
      }
      totalList[imageIndex].remove(tempBox);
      totalList[imageIndex].add(myBox);
      isChanging = false;

      changing1 = null;
      changing2 = null;
      changing3 = null;
      changing4 = null;
    }
    //print("박스 이동 결과 $myBox");
    changeX = 0;
    changeY = 0;
    tempBox = [];
    myBox = [];
  }

  void delete(Offset offset) {
    Offset click = offset;
    List<int> indexList = checkCrossLine(totalList[imageIndex], click);
    int i = 0;
    if (indexList.length == 0) {
      return;
    } else if (indexList.length >= 1) {
      for (int index in indexList) {
        i = index;
        tempBox = totalList[imageIndex][i];
      }
    }
    print("$tempBox");
    totalList[imageIndex].remove(tempBox);
  }

  List<int> checkCrossLine(List<List<Offset>> rectangles, Offset now) {
    int nowX = now.dx.toInt();
    int nowY = now.dy.toInt();
    List<int> indexList = [];
    for (List<Offset> rectangle in rectangles) {
      int x1 = rectangle[0].dx.toInt();
      int x2 = rectangle[1].dx.toInt();
      int x3 = rectangle[2].dx.toInt();
      int x4 = rectangle[3].dx.toInt();
      int y1 = rectangle[0].dy.toInt();
      int y2 = rectangle[1].dy.toInt();
      int y3 = rectangle[2].dy.toInt();
      int y4 = rectangle[3].dy.toInt();

      int check_score = 0;
      int XXX = 0;
      int YYY = 0;

      if (x1 < x4) {
        XXX = x1 - 10;
      } else {
        XXX = x4 - 10;
      }

      if (y1 < y2) {
        YYY = y1 - 10;
      } else {
        YYY = y2 - 10;
      }

      check_score += cross_check(x1, y1, x2, y2, XXX, YYY, nowX, nowY);
      check_score += cross_check(x2, y2, x3, y3, XXX, YYY, nowX, nowY);
      check_score += cross_check(x4, y4, x3, y3, XXX, YYY, nowX, nowY);
      check_score += cross_check(x1, y1, x4, y4, XXX, YYY, nowX, nowY);
      //print(check_score);

      if ((check_score % 2) == 1) {
        //print(rectangles.indexOf(rectangle));
        int index = rectangles.indexOf(rectangle);
        indexList.add(index);
      }
    }

    return indexList;
  }

  int cross_check(int x1, int y1, int x2, int y2, int dotX1, int dotY1,
      int dotX2, int dotY2) {
    int ccwValue = 0;
    int ccw1 = CounterClockWise(x1, y1, x2, y2, dotX1, dotY1);
    int ccw2 = CounterClockWise(x1, y1, x2, y2, dotX2, dotY2);
    int ccw3 = CounterClockWise(dotX1, dotY1, dotX2, dotY2, x1, y1);
    int ccw4 = CounterClockWise(dotX1, dotY1, dotX2, dotY2, x2, y2);
    if ((ccw1 == 0) || (ccw2 == 0) || (ccw3 == 0) || (ccw4 == 0)) {
      return 0;
    }

    if (ccw1 != ccw2) {
      ccwValue += 1;
    }
    if (ccw3 != ccw4) {
      ccwValue += 1;
    }
    ccwValue = (ccwValue / 2).toInt();

    return ccwValue;
  }

  int CounterClockWise(int x1, int y1, int x2, int y2, int x3, int y3) {
    int result = (x1 * y2 + x2 * y3 + x3 * y1) - (x2 * y1 + x3 * y2 + x1 * y3);

    if (result > 0)
      return 1;
    else if (result < 0)
      return -1;
    else
      return 0;
  }

// 선색, image resize
  @override
  void paint(Canvas canvas, Size size) {
    //Offset imageSize = Offset(image.width.toDouble(), image.height.toDouble());

    var scale = size.width / image.width;
    //debugPrint("$scale");
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());
    //print(totalList);
    for (List<Offset> point in totalList[imageIndex]) {
      //print("paint : $point");
      if (point == tempBox) {
        continue;
      }
      for (var i = 0; i < point.length; i++) {
        canvas.drawCircle(point[i], 5, datpainter);
        if (i != 0) {
          canvas.drawLine(point[i], point[i - 1], linepainter);
        }
        if (i == 3) {
          canvas.drawLine(point[0], point[i], linepainter);
        }
      }
    }

    if (isChanging == true) {
      canvas.drawCircle(changing1, 5, datpainter);
      canvas.drawCircle(changing2, 5, datpainter);
      canvas.drawCircle(changing3, 5, datpainter);
      canvas.drawCircle(changing4, 5, datpainter);

      canvas.drawLine(changing1, changing2, linepainter);
      canvas.drawLine(changing2, changing3, linepainter);
      canvas.drawLine(changing3, changing4, linepainter);
      canvas.drawLine(changing4, changing1, linepainter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool get wantKeepAlive => true;
}

class ImageEditor extends CustomPainter {
  ui.Image image;
  List<Offset> points = [];
  List<List<Offset>> pointslist = [];
  Offset start;
  Offset temp;
  int imageIndex;
  bool isupdate = false;
  ImageEditor({
    this.image,
    this.imageIndex,
  });

  List<Offset> Pointing = [];
  bool isPointing = false;

  final Paint datpainter = new Paint()
    ..color = Colors.blue[50]
    ..style = PaintingStyle.fill;
  final Paint linepainter = new Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  void update(Offset offset) {
    isPointing = true;
    Pointing.add(offset);
    if (pointslist.length == 0) {
      pointslist.add(points);
    } else if (points.length == 4) {
      points = [];
      pointslist.add(points);
    }
    points.add(offset);
  }

  void isup() {
    isupdate = !isupdate;
  }

  void currentrect() {
    for (List<Offset> point in pointslist)
      if (point.length == 4) {
        //debugPrint("$point");
        point.sort((a, b) {
          return a.dy > b.dy ? 1 : -1;
        });
        List<Offset> upstair = [point[0], point[1]];
        List<Offset> downstair = [point[2], point[3]];
        //debugPrint("$point");
        // debugPrint("$upstair");
        //debugPrint("$downstair");
        upstair.sort((a, b) {
          return a.dx > b.dx ? 1 : -1;
        });
        downstair.sort((a, b) {
          return a.dx > b.dx ? 1 : -1;
        });
        //debugPrint("$upstair");
        //debugPrint("$downstair");
        point.clear();
        point.add(upstair[0]);
        point.add(upstair[1]);
        point.add(downstair[1]);
        point.add(downstair[0]);
        totalList[imageIndex].add(point);
        pointslist.clear();
        points = [];
        isPointing = false;
        Pointing = [];
        //debugPrint("$point");
      }
  }

  @override
  void paint(Canvas canvas, Size size) {
    //Offset imageSize = Offset(image.width.toDouble(), image.height.toDouble());

    var scale = size.width / image.width;
    //debugPrint("$scale");
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());
    //print(totalList);
    for (List<Offset> point in totalList[imageIndex]) {
      //print("paint : $point");
      for (var i = 0; i < point.length; i++) {
        canvas.drawCircle(point[i], 5, datpainter);
        if (i != 0) {
          canvas.drawLine(point[i], point[i - 1], linepainter);
        }
        if (i == 3) {
          canvas.drawLine(point[0], point[i], linepainter);
        }
      }
    }

    if (isPointing == true) {
      for (var i = 0; i < Pointing.length; i++) {
        canvas.drawCircle(Pointing[i], 5, datpainter);
        if (i != 0) {
          canvas.drawLine(Pointing[i], Pointing[i - 1], linepainter);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool get wantKeepAlive => true;
}

class RectanglePainter extends CustomPainter {
  ui.Image image;
  int sizex;
  int sizey;
  bool ismove = false;
  int imageIndex;
  RectanglePainter({
    this.image,
    this.imageIndex,
  });
  List<Offset> points = [];
  List<List<Offset>> pointslist = [];

  Offset startPointing;
  Offset endPointing;
  Offset rightupPointing;
  Offset leftdownPointing;

  Offset startpoint;
  Offset temp;
  bool istemp = false;
  bool ispointing = false;

  final Paint datpainter = new Paint()
    ..color = Colors.blue[50]
    ..style = PaintingStyle.fill;
  final Paint linepainter = new Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  void update(Offset offset) {
    //update가 되더라도 5px이하면 endpoint에 기록이 안됨
    temp = offset;
    if (sqrt(pow(temp.dx - startpoint.dx, 2) +
            pow(temp.dy - startpoint.dy, 2)) >=
        5) {
      istemp = true;
    }
    endPointing = offset;
    rightupPointing = Offset(endPointing.dx, startPointing.dy);
    leftdownPointing = Offset(startPointing.dx, endPointing.dy);
  }

  void start(Offset offset) {
    ispointing = true;
    startpoint = offset;
    points = [];
    pointslist.add(points);
    points.add(offset);
    startPointing = offset;
    /*if (pointslist.length == 0) {
      pointslist.add(points);
    } 
    else if (points.length == 4) {
      points = [];
      pointslist.add(points);
    }
    points.add(offset);
    */
  }

  void end() {
    //print(istemp);
    //print(pointslist);
    if (istemp == false) {
      //print("점 1개 end");
      if (points.length == 1) {
        pointslist.remove(points);
      }

      //print(pointslist);
      istemp = false;
    } else {
      print("점 2개 end");
      if (istemp == true) {
        points.add(temp);
        //pointslist.add(points);
      }
      //print("pointslist : $pointslist");
      for (List<Offset> point in pointslist) {
        if (point.length == 2) {
          //print("if");
          Offset point1 = point[0];
          Offset point2 = point[1];
          Offset point3 = Offset(point[1].dx, point[0].dy);
          Offset point4 = Offset(point[0].dx, point[1].dy);
          List<Offset> points = [point1, point2, point3, point4];
          points.sort((a, b) {
            return a.dy > b.dy ? 1 : -1;
          });

          List<Offset> upstair = [points[0], points[1]];
          List<Offset> downstair = [points[2], points[3]];
          upstair.sort((a, b) {
            return a.dx > b.dx ? 1 : -1;
          });
          downstair.sort((a, b) {
            return a.dx > b.dx ? 1 : -1;
          });
          point.clear();
          point.add(upstair[0]);
          point.add(upstair[1]);
          point.add(downstair[1]);
          point.add(downstair[0]);
          totalList[imageIndex].add(point);
          pointslist.clear();
        }
      }
    }
    istemp = false;
    ispointing = false;
    startPointing = null;
    rightupPointing = null;
    leftdownPointing = null;
    endPointing = null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());

    //print(totalList);
    for (List<Offset> point in totalList[imageIndex]) {
      //print("pointslist :  $pointslist");
      //print("paint : $point");
      if (point.length == 4) {
        for (var i = 0; i < point.length; i++) {
          canvas.drawCircle(point[i], 5, datpainter);
          canvas.drawLine(point[0], point[1], linepainter);
          canvas.drawLine(point[1], point[2], linepainter);
          canvas.drawLine(point[2], point[3], linepainter);
          canvas.drawLine(point[0], point[3], linepainter);
        }
      }
    }
    if (ispointing == true) {
      canvas.drawCircle(startPointing, 5, datpainter);
      canvas.drawLine(startPointing, rightupPointing, linepainter);
      canvas.drawLine(startPointing, leftdownPointing, linepainter);
      canvas.drawLine(leftdownPointing, endPointing, linepainter);
      canvas.drawLine(rightupPointing, endPointing, linepainter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool get wantKeepAlive => true;
}
