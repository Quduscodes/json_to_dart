import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_to_dart/json_parser.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            color: Colors.transparent,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MyHomePage(),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final jsonTextController = TextEditingController();
  final objectTitleController = TextEditingController();
  String dartObj = '';
  bool makeRequired = false;
  String invalidJson = "invalid json format";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                children: <Widget>[
                  Center(
                    child: Text(
                      "Json To Dart",
                      style: TextStyle(
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Center(
                    child: Text(
                      "Paste your JSON String in the textarea below to convert to a Dart class",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12.0.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black38),
                    ),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Text(
                    "JSON",
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  TextField(
                    controller: jsonTextController,
                    minLines: 10,
                    maxLines: 20,
                    decoration: InputDecoration(
                        hintText: '{"key":"value"}',
                        hintStyle: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.w400)),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  TextField(
                      controller: objectTitleController,
                      decoration: InputDecoration(
                          hintText: "Enter name of Dart class")),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: dartObj));
                        },
                        child: Text(
                          dartObj,
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: dartObj == invalidJson
                                  ? Colors.red
                                  : Colors.black),
                        )),
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: makeRequired,
                          onChanged: (bool? val) {
                            setState(() {
                              makeRequired = val!;
                            });
                          }),
                      const Text("Make Fields required?")
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        if (jsonTextController.text.isNotEmpty ||
                            objectTitleController.text.isNotEmpty) {
                          final parser = JsonParser(jsonTextController.text,
                              objectTitleController.text, makeRequired);
                          setState(() {
                            dartObj = parser.convertToDartObject();
                          });
                        } else {
                          setState(() {
                            dartObj = invalidJson;
                          });
                        }
                      },
                      icon: const Icon(Icons.add))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
