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

enum ACTIVE { DRAG, DOT, EDIT }
int mode = 1;

class NextPage extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    Object argument = ModalRoute.of(context).settings.arguments;

    return MaterialApp(
      title: 'Flutter Demo',
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
      getUiImage(l, 800, 1200);
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

  var ismove = false;
  int tx;
  int ty;
  ACTIVE _active = ACTIVE.DRAG;
  PageController _pageController = PageController();
  // 마우스
  Widget _buildImage(GlobalKey myKey, ui.Image img, int mode) {
    Size screenSize = MediaQuery.of(context).size;
    print(mode);
    if (isImageloaded) {
      if (mode == 1) {
        ImageEditor editor = ImageEditor(image: img);
        return Center(
          child: Container(
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
            ),
          ),
        );
      } else if (mode == 2) {
        RectanglePainter editor = RectanglePainter(image: img);
        return Center(
            child: Container(
          // padding: EdgeInsets.all(screenSize.width * 0.05),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          child: GestureDetector(
            onPanStart: (details) {
              print("OnStart");
              editor.start(details.localPosition);

              myKey.currentContext.findRenderObject().markNeedsPaint();
            },
            onPanUpdate: (details) {
              print("Update");
              editor.update(details.localPosition);
              myKey.currentContext.findRenderObject().markNeedsPaint();
            },
            onPanEnd: (DragEndDetails) {
              print("End");
              editor.end();
              myKey.currentContext.findRenderObject().markNeedsPaint();
            },
            child: CustomPaint(
              key: myKey,
              painter: editor,
              size: Size(img.width.toDouble(), img.height.toDouble()),
            ),
          ),
        ));
      }
    } else {
      return Center(child: Text('loading'));
    }
  }

  double distance(Offset a, Offset b) {
    return sqrt(pow(a.dx - b.dx, 2) + pow(a.dy - b.dy, 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        Expanded(
          flex: 2,
          child: Scrollbar(
            controller: _pageController,
            isAlwaysShown: true,
            child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.horizontal,
                itemCount: imagelist.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  print(mode);
                  return _buildImage(new GlobalKey(), imagelist[index], mode);
                }),
            // children: [
            //   _buildImage(new GlobalKey(), imglist[0], 0),
            //   _buildImage(new GlobalKey(), imglist[1], 1),
            // ]),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: ListView.builder(
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
            Expanded(
                flex: 2,
                child: Column(
                  children: [
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
                          print("점");
                        },
                      ),
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
                          print("드래그");
                        },
                      ),
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
                          print("수정");
                        },
                      ),
                    ),
                  ],
                )),
            Expanded(
              flex: 1,
              child: Padding(
                  padding: EdgeInsets.all(60.0),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints.tightFor(width: 100, height: 20),
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("뒤로가기"),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white, onPrimary: Colors.black)),
                  )),
            ),
          ]),
        ),
      ],
    ));
  }
}

class ImageEditor extends CustomPainter {
  ui.Image image;
  List<Offset> points = [];
  List<List<Offset>> pointslist = [];
  Offset start;
  Offset temp;
  bool isupdate = false;
  ImageEditor({
    this.image,
  });
  final Paint datpainter = new Paint()
    ..color = Colors.blue[50]
    ..style = PaintingStyle.fill;
  final Paint linepainter = new Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  void update(Offset offset) {
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
        //debugPrint("$point");
      }
  }

  @override
  void paint(Canvas canvas, Size size) {
    //Offset imageSize = Offset(image.width.toDouble(), image.height.toDouble());

    var scale = size.width / image.width;
    //debugPrint("$scale");
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());

    for (List<Offset> point in pointslist) {
      print("paint : $point");
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
  RectanglePainter({
    this.image,
  });
  List<Offset> points = [];
  List<List<Offset>> pointslist = [];
  Offset startpoint;
  Offset temp;
  bool istemp = false;

  final Paint datpainter = new Paint()
    ..color = Colors.blue[50]
    ..style = PaintingStyle.fill;
  final Paint linepainter = new Paint()
    ..color = Colors.black
    ..style = PaintingStyle.fill;

  var paint1 = Paint()
    ..color = Colors.blue[50]
    ..style = PaintingStyle.fill;

  void update(Offset offset) {
    //update가 되더라도 5px이하면 endpoint에 기록이 안됨
    temp = offset;
    if (sqrt(pow(temp.dx - startpoint.dx, 2) +
            pow(temp.dy - startpoint.dy, 2)) >=
        5) {
      istemp = true;
    }
  }

  void start(Offset offset) {
    startpoint = offset;
    points = [];
    pointslist.add(points);
    points.add(offset);
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
    print(istemp);
    print(pointslist);
    if (istemp == false) {
      print("점 1개 end");
      if (points.length == 1) {
        pointslist.remove(points);
      }

      print(pointslist);
      istemp = false;
    } else {
      print("점 2개 end");
      if (istemp == true) {
        points.add(temp);
        //pointslist.add(points);
      }
      print("pointslist : $pointslist");
      for (List<Offset> point in pointslist) {
        if (point.length == 2) {
          print("if");
          Offset start = point[0];
          Offset end = point[1];
          Offset rightUp = Offset(point[1].dx, point[0].dy);
          Offset leftDown = Offset(point[0].dx, point[1].dy);
          point.clear();
          point.add(start);
          point.add(rightUp);
          point.add(leftDown);
          point.add(end);
        }
      }
    }
    istemp = false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());

    for (List<Offset> point in pointslist) {
      //print("pointslist :  $pointslist");
      //print("paint : $point");
      if (point.length == 4) {
        for (var i = 0; i < point.length; i++) {
          canvas.drawCircle(point[i], 5, datpainter);
          canvas.drawLine(point[0], point[1], linepainter);
          canvas.drawLine(point[0], point[2], linepainter);
          canvas.drawLine(point[1], point[3], linepainter);
          canvas.drawLine(point[2], point[3], linepainter);
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
