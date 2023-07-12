import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

class LogAnalysisBloc {
  final BehaviorSubject<String> _selectFolderSubject =
      BehaviorSubject<String>.seeded("");
  Stream<String> get selectFolderStream => _selectFolderSubject.stream;

  BehaviorSubject<String> _showHintDialogSubject = BehaviorSubject<String>();
  Stream<String> get showHintDialogStream => _showHintDialogSubject.stream;

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    String path = result?.files.single.path ?? "";
    if (path != "") {
      if (path.split('.').last == "log" || path.split('.').last == "txt") {
        _selectFolderSubject.add(path);
      } else {
        _showHintDialogSubject.add("Not support!");
      }
    }
  }
}
