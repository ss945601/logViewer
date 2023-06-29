import 'dart:convert';
import 'dart:io';

import 'package:arb_flutter/model/arb_model.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rxdart/rxdart.dart';

class FileBrowserBloc {
  BehaviorSubject<String> _hintSubject = BehaviorSubject<String>.seeded("");
  Stream<String> get hintStream => _hintSubject.stream;

  final BehaviorSubject<String> _selectFolderSubject =
      BehaviorSubject<String>.seeded("");
  Stream<String> get selectFolderStream => _selectFolderSubject.stream;

  final PublishSubject<Map<String, Map<String, String>>> _arbJsonSubject =
      PublishSubject<Map<String, Map<String, String>>>();
  Stream<Map<String, Map<String, String>>> get arbJsonStream =>
      _arbJsonSubject.stream;
  String _path = "";
  Map<String, Map<String, String>> currentLang = {};
  FileBrowserBloc() {
    _arbJsonSubject.stream.listen((event) {
      currentLang = event;
    });
  }

  void setHint(String hint) {
    _hintSubject.sink.add(hint);
  }

  Future<void> selectFolder() async {
    String? selectedDirectory =
        await FilePicker.platform.getDirectoryPath() ?? "";
    _selectFolderSubject.sink.add(selectedDirectory);
    _path = selectedDirectory;
    if (selectedDirectory != "") {
      readJsonFiles(selectedDirectory);
    }
  }

  Future<Map<String, Map<String, String>>> readJsonFiles(
      String folderPath) async {
    Directory directory = Directory(folderPath);
    List<File> jsonFiles = await directory
        .list()
        .where((file) => file.path.endsWith('.arb'))
        .map((file) => File(file.path))
        .toList();
    if (jsonFiles.length > 0) {
      Map<String, Map<String, String>> jsonDataList = {};

      for (File jsonFile in jsonFiles) {
        String jsonString = await jsonFile.readAsString();
        Map<String, String> jsonData = arbModelFromJson(jsonString);
        jsonDataList[jsonFile.path.split("/").last] = jsonData;
      }
      _arbJsonSubject.sink.add(transposeMap(jsonDataList));
      return jsonDataList;
    }
    return {};
  }

  Map<String, Map<String, String>> transposeMap(
      Map<String, Map<String, String>> data) {
    Map<String, Map<String, String>> transposedData = {};

    // Iterate over the original data
    data.forEach((key, values) {
      // Iterate over the values of each key in the original data
      values.forEach((innerKey, value) {
        // Create a new map for the transposed data, if not already present
        transposedData[innerKey] ??= {};

        // Assign the value to the corresponding transposed key and inner key
        transposedData[innerKey]![key] = value;
      });
    });

    return transposedData;
  }

  Future<void> add(String key, String value) async {
    var langs = currentLang;
    var columnKeys = langs.values.first.keys.toList();
    langs[key] = {};
    for (var col in columnKeys) {
      langs[key]![col] = value;
    }
    _arbJsonSubject.sink.add((langs));
  }

  Future<void> update(Map<String, Map<String, String>> lang) async {
    _arbJsonSubject.sink.add((lang));
    var newLang = transposeMap(lang);
    var titles = newLang.keys.toList();
    String? selectedDirectory =
        await FilePicker.platform.getDirectoryPath() ?? "";
    if (selectedDirectory != "") {
      for (var title in titles) {
        final file = await File('$selectedDirectory/$title');
        var text = arbModelToJson(newLang[title]!).replaceAll(",\"", ",\n  \"");
        text = text.substring(1, text.length - 1);
        text = "{\n" + "  " + text + "\n}";
        file.writeAsString(text);
      }
    }
  }

  Future<void> openCsv() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    String path = result?.files.single.path ?? "";
    if (path != "") {
      // Load CSV file
      File csvFile = File(path);
      String csvData = await csvFile.readAsString();

      // Parse CSV
      List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);

      // Create Map
      Map<String, Map<String, String>> parsedData = {};

      // Iterate through CSV rows and create nested maps
      for (int i = 0; i < csvTable.length; i++) {
        List<dynamic> row = csvTable[i];
        if (i == 0) {
          // Header row, extract keys
          List<String> keys = row.map((cell) => cell.toString()).toList();
          keys.removeAt(0); // Remove the first empty cell if present
          for (String key in keys) {
            parsedData[key] = {};
          }
        } else {
          // Data row, extract values
          String mainKey = row[0].toString();
          for (int j = 1; j < row.length; j++) {
            parsedData.keys.elementAt(j - 1); // Retrieve the corresponding key
            parsedData[parsedData.keys.elementAt(j - 1)]![mainKey] =
                row[j].toString();
          }
        }
      }
      _arbJsonSubject.sink.add((transposeMap(parsedData)));
      _selectFolderSubject.sink.add(path);
    }
  }

  Future<void> exportToCSV(Map<String, Map<String, String>> dataMap,
      {String fileName = "output.csv"}) async {
    String? selectedDirectory =
        await FilePicker.platform.getDirectoryPath() ?? "";
    if (selectedDirectory != "") {
      List<List<dynamic>> csvData = [];

      // Add CSV headers (first column)
      csvData.add(['InnerKey']);

      // Get the unique keys from the inner maps
      Set<String> keys =
          dataMap.values.expand((innerMap) => innerMap.keys).toSet();

      // Add the unique keys as columns
      csvData.first.addAll(keys);

      // Convert the data map to CSV rows
      dataMap.forEach((key, innerMap) {
        List<dynamic> row = [key];
        keys.forEach((innerKey) {
          if (innerMap.containsKey(innerKey)) {
            row.add(innerMap[innerKey]);
          } else {
            row.add('');
          }
        });
        csvData.add(row);
      });

      // Create a CSV converter
      final csvConverter = const ListToCsvConverter();

      // Convert CSV data to a string
      String csvString = csvConverter.convert(csvData);

      // Define the output file path
      String filePath = selectedDirectory + "/" + fileName;

      // Write the CSV string to a file
      File file = File(filePath);
      file.writeAsString(csvString);
    }
  }
}
