import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as qUtil;
import 'package:latticework/bloc/log_analysis_bloc.dart';

class LogAnalysisPage extends StatefulWidget {
  const LogAnalysisPage({super.key});

  @override
  State<LogAnalysisPage> createState() => _LogAnalysisPageState();
}

class _LogAnalysisPageState extends State<LogAnalysisPage> {
  final LogAnalysisBloc _logAnalysisBloc = LogAnalysisBloc();
  late qUtil.QuillController _controller = qUtil.QuillController.basic();
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
          qUtil.QuillToolbar.basic(
              controller: _controller),
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
          ToolBar(context),
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
            _logAnalysisBloc.selectFile().then((content) {
              setState(() {
                _controller = qUtil.QuillController(
                    document: qUtil.Document()..insert(0, content),
                    selection: const TextSelection.collapsed(offset: 0));
              });
            });
          },
          label: Text("Open file"))
    ]);
  }
}
