import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:rxdart/subjects.dart';

class LogAnalysisBloc {
  final BehaviorSubject<String> _selectFolderSubject =
      BehaviorSubject<String>.seeded("");

  final List<String> printTags = ["[DEBUG]", "[INFO]", "[ERROR]"];
  String withoutFilterContent = "";
  Stream<String> get selectFolderStream => _selectFolderSubject.stream;

  BehaviorSubject<String> _showHintDialogSubject = BehaviorSubject<String>();
  Stream<String> get showHintDialogStream => _showHintDialogSubject.stream;

  Future<String> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    String path = result?.files.single.path ?? "";
    if (path != "") {
      if (path.split('.').last == "log" || path.split('.').last == "txt") {
        _selectFolderSubject.add(path);
        var content = await readFile(path);
        return content;
      } else {
        _showHintDialogSubject.add("Not support!");
      }
    }
    return "";
  }

  Future<String> readFile(String path) async {
    try {
      File file = File(path);
      List<String> contents = await file.readAsLines();
      withoutFilterContent = contents.join("\n");
      var result = filterString(contents).join("\n");
      return result;
    } catch (e) {
      // Handle any errors that occur during file reading.
      print('Error reading file: $e');
      return "";
    }
  }

  List<String> filterString(List<String> contents) {
    contents.removeWhere((val) {
      for (var tag in printTags) {
        if (val.contains(tag)) return false;
      }
      return true;
    });
    return contents;
  }
}
