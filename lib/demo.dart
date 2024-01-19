import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';


void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<img.Image> mylist = [];
  List<img.Image> mylist1 = [];
  List temp = List.filled(9, true);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImageFileFromAssets("img/images.png").then((value) {
      final image = img.decodePng(value.readAsBytesSync());
      mylist = splitImage(image!, 3, 3);
      mylist.shuffle();

      print(mylist);
    });

    setState(() {});
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  List<img.Image> splitImage(
      img.Image inputImage, int horizontalPieceCount, int verticalPieceCount) {
    img.Image image = inputImage;

    final pieceWidth = (image.width / horizontalPieceCount).round();
    final pieceHeight = (image.height / verticalPieceCount).round();
    final pieceList = List<img.Image>.empty(growable: true);

    for (var y = 0; y < image.height; y += pieceHeight) {
      for (var x = 0; x < image.width; x += pieceWidth) {
        pieceList.add(img.copyCrop(image,
            x: x, y: y, width: pieceWidth, height: pieceHeight));
      }
    }

    return pieceList;
  }

  @override
  Widget build(BuildContext context) {
    double tot_width = MediaQuery.of(context).size.width;
    double con_width = (tot_width - 20) / 3;
    print("tot:$tot_width");
    print("container:$con_width");

    return Scaffold(
        appBar: AppBar(title: Text("Photo puzzels")),
        body: GridView.builder(
          itemCount: mylist.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),

          itemBuilder: (context, index) {
            Uint8List testImg = img.encodePng(mylist[index]);
            return (temp[index])
                ? Draggable(
              onDraggableCanceled: (velocity, offset) {
                print("test");
                temp = List.filled(9, true);
                setState(() {});
              },
              data: index,
              onDragStarted: () {
                temp = List.filled(9, false);
                temp[index] = true;
                setState(() {});
              },
              child: Container(

                height: con_width,
                width: con_width,

                decoration: BoxDecoration(image: DecorationImage(image: MemoryImage(testImg),fit: BoxFit.fill)),
                alignment: Alignment.center,
              ),
              feedback: Container(

                height: con_width,
                width: con_width,
                decoration: BoxDecoration(image: DecorationImage(image: MemoryImage(testImg),fit: BoxFit.fill)),
                alignment: Alignment.center,
              ),
            )
                : DragTarget(
              onAccept: (data) {
                print(data);
                temp = List.filled(9, true);
                var c = mylist[data as  int];
                mylist[data as int] = mylist[index];
                mylist[index] = c;
                if (listEquals(mylist, mylist1)) {
                  print("You are win");
                }
                setState(() {});
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: con_width,
                  width: con_width,

                  decoration: BoxDecoration(image: DecorationImage(image: MemoryImage(testImg),fit: BoxFit.fill)),
                  alignment: Alignment.center,
                );
              },
            );
          },
        ));
  }
}