import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart' as qUtil;
import 'package:get/get.dart';
import 'package:latticework/bloc/app_bloc.dart';
import 'package:latticework/bloc/log_analysis_bloc.dart';
import 'package:badges/badges.dart' as badges;

class LogAnalysisPage extends StatefulWidget {
  const LogAnalysisPage({super.key});

  @override
  State<LogAnalysisPage> createState() => _LogAnalysisPageState();
}

class _LogAnalysisPageState extends State<LogAnalysisPage> {
  final LogAnalysisBloc _logAnalysisBloc = LogAnalysisBloc();
  late qUtil.QuillController _controller = qUtil.QuillController.basic();
  bool isReadOnly = false;
  bool isApplyFilter = false;
  StreamController<String> lineCtr = StreamController();
  final ScrollController lineCountScrollCtr = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    lineCtr.add("1.");
    super.initState();
    _controller.document.changes.listen((event) {
      resetLineCount();
    });

    _logAnalysisBloc.showHintDialogStream.listen((msg) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Hint'),
                content: Text('$msg'),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      // Perform an action here
                      Navigator.of(context).pop();
                    },
                  )
                ]);
          });
    });
  }

  void resetLineCount() {
    var lineNum = _controller.plainTextEditingValue.text.split("\n").length;
    var lineStr = "";
    for (var i = 1; i < lineNum; i++) {
      lineStr = lineStr + i.toString() + ".\n";
    }
    lineCtr.add(lineStr);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SelectPathBar(),
          Divider(),
          qUtil.QuillToolbar.basic(controller: _controller),
          Divider(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    padding: EdgeInsets.only(top: 21, left: 5, right: 5),
                    color: Colors.amber.withAlpha(50),
                    child: StreamBuilder<Object>(
                        stream: lineCtr.stream,
                        builder: (context, snapshot) {
                          return ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context)
                                .copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              controller: lineCountScrollCtr,
                              physics: NeverScrollableScrollPhysics(),
                              child: Text("${snapshot.data}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      height: 1.19,
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 139, 65, 61))),
                            ),
                          );
                        })),
                Expanded(
                  child: Container(
                      color: isReadOnly
                          ? Colors.grey.withOpacity(0.1)
                          : Colors.white,
                      padding: EdgeInsets.all(20),
                      child: NotificationListener<ScrollUpdateNotification>(
                        onNotification:
                            (ScrollUpdateNotification notification) {
                          lineCountScrollCtr.jumpTo(
                              lineCountScrollCtr.position.pixels +
                                  notification.scrollDelta!);
                          return true;
                        },
                        child: qUtil.QuillEditor.basic(
                          controller: _controller,
                          readOnly: isReadOnly, // true for view only mode
                        ),
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container SelectPathBar() {
    return Container(
      color: Colors.pink.withOpacity(0.1),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: ToolBar(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: StreamBuilder<String>(
                      stream: _logAnalysisBloc.selectFolderStream,
                      builder: (context, snapshot) {
                        return Text(snapshot.data ?? "");
                      })),
            ),
          ),
        ],
      ),
    );
  }

  Row ToolBar(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      TextButton.icon(
          icon: Icon(Icons.open_in_browser),
          style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white),
          onPressed: () {
            EasyLoading.show(status: 'loading...');
            _logAnalysisBloc.selectFile().then((content) {
              setState(() {
                _controller.document.delete(0, _controller.document.length);
                _controller.document.insert(0, content);
                EasyLoading.dismiss();
                isApplyFilter = false;
                resetLineCount();
              });
            }).onError((error, stackTrace) {
              EasyLoading.dismiss();
              isApplyFilter = false;
            });
          },
          label: Text("Open file")),
      TextButton.icon(
          icon: Icon(Icons.open_in_browser),
          style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              backgroundColor: Color.fromARGB(255, 92, 158, 94),
              foregroundColor: Colors.white),
          onPressed: () {
            EasyLoading.show(status: 'loading...');
            setState(() {
              appBloc
                  .saveFile(_controller.plainTextEditingValue.text, context)
                  .then((value) {
                EasyLoading.dismiss();
              });
            });
          },
          label: Text("Save file")),
      Visibility(
        visible: false,
        child: TextButton.icon(
            icon: Icon(Icons.open_in_browser),
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Color.fromARGB(255, 201, 169, 114),
                foregroundColor: Colors.white),
            onPressed: () {
              EasyLoading.show(status: 'loading...');
              setState(() {
                _logAnalysisBloc
                    .askAI(_controller.plainTextEditingValue.text)
                    .then((res) {
                  print(res);
                  EasyLoading.dismiss();
                });
              });
            },
            label: Text("Ask chatGPT")),
      ),
      badges.Badge(
        badgeAnimation: badges.BadgeAnimation.rotation(
          animationDuration: Duration(seconds: 2),
          colorChangeAnimationDuration: Duration(seconds: 2),
          loopAnimation: false,
          curve: Curves.fastOutSlowIn,
          colorChangeAnimationCurve: Curves.easeInCubic,
        ),
        badgeStyle: badges.BadgeStyle(
            badgeColor: isApplyFilter ? Colors.green : Colors.red),
        badgeContent: Text(
          FilterContent.filterItems.length.toString(),
          style: TextStyle(color: Colors.white),
        ),
        child: TextButton.icon(
            icon: Icon(Icons.add_box),
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Color.fromARGB(255, 154, 177, 218),
                foregroundColor: Colors.white),
            onPressed: () {
              _showFilterDialog().then((value) {
                if (value.length > 0) {
                  var newContent = _logAnalysisBloc.addFilter(
                      value, _controller.plainTextEditingValue.text,
                      caseIgnore: FilterContent.caseIgnore);
                  _controller.document.close();
                  _controller.document = qUtil.Document()
                    ..insert(0, newContent);
                  setState(() {
                    isApplyFilter = true;
                    isReadOnly = true;
                    resetLineCount();
                  });
                } else {
                  var newContent = _logAnalysisBloc.originalContent();
                  _controller.document.delete(0, _controller.document.length);
                  _controller.document.insert(
                      0, newContent.substring(0, newContent.length - 1));
                  _controller.document.changes.listen((event) {
                    resetLineCount();
                  });

                  setState(() {
                    isApplyFilter = true;
                    _logAnalysisBloc.isFilterMode = false;
                    isReadOnly = false;
                    resetLineCount();
                  });
                }
              });
            },
            label: Text("Find filters")),
      )
    ]);
  }

  Future<List<List<String>>> _showFilterDialog() async {
    var content = FilterContent();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            child: AlertDialog(
              title: Text('Add filters'),
              content: Container(width: Get.width / 2, child: content),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Case ignore"),
                    Checkbox(
                      value: FilterContent.caseIgnore,
                      onChanged: (value) {
                        setState(() {
                          FilterContent.caseIgnore = value!;
                        });
                      },
                    ),
                  ],
                ),
                TextButton(
                  child: Text('Apply'),
                  onPressed: () {
                    FilterContent.filterItems
                        .removeWhere((element) => element == "");
                    // Handle the apply action here
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
      },
    );
    return FilterContent.filterItems;
  }
}

class FilterContent extends StatefulWidget {
  static List<List<String>> filterItems = [];
  static bool caseIgnore = false;

  @override
  _FilterContentState createState() => _FilterContentState();
}

class _FilterContentState extends State<FilterContent> {
  void addTextField() {
    setState(() {
      FilterContent.filterItems.add([]);
      FilterContent.filterItems.last.add("");
    });
  }

  void removeTextField(int index) {
    setState(() {
      FilterContent.filterItems.removeAt(index);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display existing text fields
        for (int i = 0; i < FilterContent.filterItems.length; i++)
          Column(
            children: [
              Row(
                children: [
                  for (int j = 0; j < FilterContent.filterItems[i].length; j++)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                initialValue: FilterContent.filterItems[i][j],
                                onChanged: (value) {
                                  setState(() {
                                    FilterContent.filterItems[i][j] = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          if (j != FilterContent.filterItems[i].length - 1)
                            Text("&")
                        ],
                      ),
                    ),
                  if (FilterContent.filterItems[i].length == 0) Spacer(),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            FilterContent.filterItems[i].add("");
                          });
                        },
                        icon: Icon(Icons.add),
                        iconSize: 15,
                        splashRadius: 3,
                        color: Colors.green,
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              FilterContent.filterItems[i].removeLast();
                            });
                          },
                          icon: Icon(Icons.remove),
                          iconSize: 15,
                          splashRadius: 3,
                          color: Colors.red),
                    ],
                  )
                ],
              ),
              if (i != FilterContent.filterItems.length - 1)
                Text(
                  "or",
                  style: TextStyle(fontSize: 20),
                )
            ],
          ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              splashRadius: 20,
              icon: Icon(Icons.add),
              onPressed: addTextField,
            ),
            IconButton(
              splashRadius: 20,
              icon: Icon(Icons.remove),
              onPressed: FilterContent.filterItems.isNotEmpty
                  ? () => removeTextField(FilterContent.filterItems.length - 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
