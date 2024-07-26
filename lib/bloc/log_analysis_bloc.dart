import 'dart:convert';
import 'dart:io';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
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
  final OpenAI _openAI = OpenAI.instance.build(
      token: "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",
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);

  bool isFilterMode = false;

  String originalContent() {
    return withoutFilterContent.join("\n");
  }

  String addFilter(List<List<String>> filterStr, String currentString,
      {bool caseIgnore = false}) {
    print(filterStr);
    if (!isFilterMode) {
      withoutFilterContent = currentString.split("\n");
    }
    isFilterMode = filterStr.length > 0 ? true : false;
    var content = [...withoutFilterContent];
    content.removeWhere((line) {
      var collectNeedRemove = [];
      for (var filterAnd in filterStr) {
        var isNeedRemove = false;
        for (var filter in filterAnd) {
          if (!caseIgnore) {
            if (!line.contains(filter)) {
              isNeedRemove = true;
            }
          } else {
            if (!line.toLowerCase().contains(filter.toLowerCase())) {
              isNeedRemove = true;
            }
          }
        }
        collectNeedRemove.add(isNeedRemove);
      }
      for (var ret in collectNeedRemove) {
        if (!ret) return false;
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

  Future<String> askAI(String req) async {
    final request =
        CompleteText(prompt: req, maxTokens: 100, model: ModelFromValue(model: 'gemini-pro'));

    final response = await _openAI.onCompletion(request: request);
    String content = "";
    for (var element in response!.choices) {
      content += element.text;
    }
    return content;
  }
}
