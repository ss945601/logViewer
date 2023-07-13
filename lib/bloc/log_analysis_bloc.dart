import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';

class LogAnalysisBloc {
  final BehaviorSubject<String> _selectFolderSubject =
      BehaviorSubject<String>.seeded("");

  final List<String> printTags = [];
  List<String> withoutFilterContent = [];
  Stream<String> get selectFolderStream => _selectFolderSubject.stream;

  BehaviorSubject<String> _showHintDialogSubject = BehaviorSubject<String>();
  Stream<String> get showHintDialogStream => _showHintDialogSubject.stream;

  String originalContent() {
    return withoutFilterContent.join("\n");
  }

  String addFilter(List<String> filterStr) {
    print(filterStr);
    var content = [...withoutFilterContent];
    content.removeWhere((line) {
      for (var filter in filterStr) {
        if (line.contains(filter)) {
          return false;
        }
      }
      return true;
    });
    var result = content.join("\n");
    return result;
  }

  Future<String> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (kIsWeb) {
      Uint8List? fileBytes = result?.files.first.bytes;
      String content = Utf8Decoder().convert(fileBytes!);
      withoutFilterContent = content.split("\n");
      _selectFolderSubject.add("web not supported path");
      return content;
    } else {
      String path = result?.files.single.path ?? "";
      if (path != "") {
        try {
          _selectFolderSubject.add(path);
          var content = await readFile(path);
          return content;
        } catch (ex) {
          _showHintDialogSubject.add("Not support!");
        }
      }
      return "";
      // NOT running on the web! You can check for additional platforms here.
    }
  }

  Future<String> readFile(String path) async {
    try {
      File file = File(path);
      List<String> contents = await file.readAsLines();
      withoutFilterContent = contents;
      var result = contents.join("\n");
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
