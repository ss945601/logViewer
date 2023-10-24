import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

var appBloc = AppBloc();

class PageName {
  static const String arbPage = "arb";
  static const String logPage = "log";
  static const String virtualAmberPage = "amberVirtual";
}

class AppBloc {
  BehaviorSubject<String> _switchPageSubject = BehaviorSubject<String>();
  Stream<String> get switchPageStream => _switchPageSubject.stream;
  Sink<String> get switchPageSink => _switchPageSubject.sink;

  Future<void> saveFile(String content, BuildContext ctx) async {
    String filename = '';
    MimeType selectedFileType = MimeType.text;
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Text('Save File'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        filename = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Filename',
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButton(
                      value: selectedFileType,
                      items: MimeType.values
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFileType = value as MimeType;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Handle cancel button action
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Handle save button action
                      String path = await FileSaver.instance.saveFile(
                          name: filename,
                          bytes: Utf8Encoder().convert(content),
                          mimeType: selectedFileType);
                      Navigator.of(context).pop();
                    },
                    child: Text('Save'),
                  ),
                ],
              );
            },
          );
        });
  }
}
