import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:rxdart/rxdart.dart';

class VirtualAmberBloc {
  var shell = Shell(
    runInShell: true,
  );
  var password = "lL10127142";
  PublishSubject<bool> _isConnectServerSubject = PublishSubject<bool>();
  Stream<bool> get isConnectServerStream => _isConnectServerSubject.stream;
  Future<String> getPath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path + "/virtualAmberLink.command";
  }

  Future<void> connectServer() async {
    var path = await getPath();
    final File file = File(path);
    await file.writeAsString("sshpass -p lL10127142 ssh earth");
    await shell.run('''
        chmod +x ${path}
        open ${path}
      ''').then((value) {});
  }
}
