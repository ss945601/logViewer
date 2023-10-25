import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Error { noPassword, none }

class VirtualAmberBloc {
  var shell = Shell();
  var _password = "";
  PublishSubject<bool> _isConnectServerSubject = PublishSubject<bool>();
  Stream<bool> get isConnectServerStream => _isConnectServerSubject.stream;
  Future<String> getPath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return  directory.path + "/virtualAmberLink.command";
  }

  Future<void> setPwd(String pwd) async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _password = pwd;
    await prefs.setString('pwd', _password);
  }

  Future<Error> connectServer() async {
    var path = await getPath();
    final File file = File(path);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? pwd = prefs.getString('pwd');
    if (pwd != null) {
      _password = pwd;
      await file.writeAsString("sshpass -p ${_password} ssh earth");
      await shell.run('''
        chmod +x ${path}
        open ${path}
      ''').then((value) {});
      return Error.none;
    } else {
      return Error.noPassword;
    }
  }
}
