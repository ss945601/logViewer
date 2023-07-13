import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart' as qUtil;
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
  bool isApplyFilter = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
            child: Container(
              child: qUtil.QuillEditor.basic(
                controller: _controller,
                readOnly: false, // true for view only mode
              ),
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
                _controller = qUtil.QuillController(
                    document: qUtil.Document()..insert(0, content),
                    selection: const TextSelection.collapsed(offset: 0));
                EasyLoading.dismiss();
                isApplyFilter = false;
              });
            });
          },
          label: Text("Open file")),
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
          DialogContent.textFields.length.toString(),
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
              _showDialog().then((value) {
                if (value.length > 0) {
                  var newContent = _logAnalysisBloc.addFilter(value);
                  setState(() {
                    _controller = qUtil.QuillController(
                        document: qUtil.Document()..insert(0, newContent),
                        selection: const TextSelection.collapsed(offset: 0));
                    isApplyFilter = true;
                  });
                }
              });
            },
            label: Text("Find filters")),
      )
    ]);
  }

  Future<List<String>> _showDialog() async {
    var content = DialogContent();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add filters'),
          content: content,
          actions: <Widget>[
            TextButton(
              child: Text('Apply'),
              onPressed: () {
                DialogContent.textFields.removeWhere((element) => element == "");
                // Handle the apply action here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return DialogContent.textFields;
  }
}

class DialogContent extends StatefulWidget {
  static List<String> textFields = [];
  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  void addTextField() {
    setState(() {
      DialogContent.textFields.add('');
    });
  }

  void removeTextField(int index) {
    setState(() {
      DialogContent.textFields.removeAt(index);
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
        for (int i = 0; i < DialogContent.textFields.length; i++)
          TextFormField(
            initialValue: DialogContent.textFields[i],
            onChanged: (value) {
              setState(() {
                DialogContent.textFields[i] = value;
              });
            },
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
              onPressed: DialogContent.textFields.isNotEmpty
                  ? () => removeTextField(DialogContent.textFields.length - 1)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
