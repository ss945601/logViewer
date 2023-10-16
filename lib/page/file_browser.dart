import 'package:latticework/bloc/file_browser_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

FileBrowserBloc _fileBrowserBloc = FileBrowserBloc();

class FileBrowserPage extends StatefulWidget {
  const FileBrowserPage({super.key});

  @override
  State<FileBrowserPage> createState() => _FileBrowserPageState();
}

class _FileBrowserPageState extends State<FileBrowserPage> {
  int currentIdx = 0;
  int dataSize = 0;
  final int shift = 50;
  Map<String, Map<String, String>> tmpLang = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fileBrowserBloc.arbJsonStream.listen((langs) {
      setState(() {
        dataSize = langs.keys.toList().length;
        tmpLang = langs;
        currentIdx = (dataSize / shift).toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: _fileBrowserBloc.selectFolderStream,
        builder: (context, selectFolderSnapshot) {
          var path = selectFolderSnapshot.data.toString();
          return Container(
            child: Column(
              children: [
                SelectPathBar(path),
                TableView(),
                HintSection(),
                if (dataSize > 0) PageNumButton(),
                SizedBox(height: 12),
              ],
            ),
          );
        });
  }

  Wrap PageNumButton() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < dataSize / shift; i++)
          TextButton(
              style: currentIdx == i * shift
                  ? TextButton.styleFrom(
                      backgroundColor: Colors.blueAccent.withAlpha(50))
                  : TextButton.styleFrom(),
              onPressed: () {
                setState(() {
                  currentIdx = i * shift;
                });
              },
              child: Text((i + 1).toString())),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Row ToolBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
            icon: Icon(Icons.open_in_browser),
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white),
            onPressed: () {
              _fileBrowserBloc.selectFolder();
            },
            label: Text("Open arb folder")),
        if (dataSize > 0)
          TextButton.icon(
              icon: Icon(Icons.add),
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => KeyValueDialog(),
                );
              },
              label: Text("Add Data")),
        if (dataSize > 0)
          TextButton.icon(
              icon: Icon(Icons.save),
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white),
              onPressed: () {
                _fileBrowserBloc.update(tmpLang);
              },
              label: Text("Save Data")),
        TextButton.icon(
            icon: Icon(Icons.import_export),
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white),
            onPressed: () {
              _fileBrowserBloc.openCsv();
            },
            label: Text("Open csv")),
        if (dataSize > 0)
          TextButton.icon(
              icon: Icon(Icons.import_export),
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white),
              onPressed: () {
                _fileBrowserBloc.exportToCSV(tmpLang);
              },
              label: Text("Export csv"))
      ],
    );
  }

  Expanded HintSection() {
    return Expanded(
      flex: 2,
      child: IntrinsicWidth(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: StreamBuilder<String>(
              stream: _fileBrowserBloc.hintStream,
              builder: (context, snapshot) {
                if (snapshot.data != null && snapshot.data != "") {
                  var colAndRow = snapshot.data!.split(":")[0];
                  var value = snapshot.data!.split(":")[1];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: RichText(
                        text: TextSpan(
                            text: colAndRow,
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 20,
                            ),
                            children: [
                          TextSpan(
                              text: value,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ))
                        ])),
                  );
                }
                return SizedBox.shrink();
              }),
        ),
      ),
    );
  }

  Expanded TableView() {
    return Expanded(
        flex: 16,
        child: StreamBuilder<Map<String, Map<String, String>>>(
            stream: _fileBrowserBloc.arbJsonStream,
            builder: (context, arbJsonSnapshot) {
              if (arbJsonSnapshot.data != null &&
                  arbJsonSnapshot.data!.isNotEmpty) {
                return Center(child: I10nTable(arbJsonSnapshot.data!));
              } else {
                return SizedBox.shrink();
              }
            }));
  }

  Container SelectPathBar(String path) {
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
                  child: Text(path)),
            ),
          ),
        ],
      ),
    );
  }

  void updateCellValue(Map<String, Map<String, String>> langs, String rowKey,
      String columnKey, String newValue) {
    langs[rowKey]![columnKey] = newValue;
    tmpLang = langs;
  }

  void updateData() {
    _fileBrowserBloc.update(tmpLang);
  }

  LayoutBuilder I10nTable(Map<String, Map<String, String>> langs) {
    List<String> rowKeys = [];
    List<String> columnKeys = [];
    rowKeys = langs.keys.toList().sublist(
        currentIdx,
        currentIdx + shift <= langs.keys.toList().length
            ? currentIdx + shift
            : langs.keys.toList().length);
    columnKeys = langs.values.first.keys.toList();
    return LayoutBuilder(builder: (context, constraints) {
      var rowCount = 0;
      return Container(
        width: Get.width,
        height: Get.height,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 0,
              columns: [
                DataColumn(label: Text('')),
                ...columnKeys.map((columnKey) {
                  return DataColumn(label: Text(columnKey));
                }).toList(),
              ],
              rows: rowKeys.toList().map((rowKey) {
                return DataRow(
                  cells: [
                    DataCell(SizedBox(width: 250, child: Text(rowKey))),
                    ...columnKeys.map((columnKey) {
                      rowCount += 1;
                      return DataCell(
                        Container(
                          color: rowCount % 2 == 1
                              ? Color.fromARGB(255, 207, 221, 227)
                              : Color.fromARGB(255, 235, 221, 221),
                          width: Get.width / (columnKeys.length),
                          child: InkWell(
                            onTap: () {},
                            onHover: (value) {
                              if (value) {
                                _fileBrowserBloc.setHint(columnKey +
                                    " | " +
                                    rowKey +
                                    " : " +
                                    langs[rowKey]![columnKey]!);
                              } else {
                                _fileBrowserBloc.setHint("");
                              }
                            },
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: columnKey,
                              ),
                              key: UniqueKey(),
                              initialValue: langs[rowKey]![columnKey],
                              onChanged: (newValue) => updateCellValue(
                                  langs, rowKey, columnKey, newValue),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    });
  }
}

class KeyValueDialog extends StatefulWidget {
  @override
  _KeyValueDialogState createState() => _KeyValueDialogState();
}

class _KeyValueDialogState extends State<KeyValueDialog> {
  late TextEditingController keyController;
  late TextEditingController valueController;

  @override
  void initState() {
    super.initState();
    keyController = TextEditingController();
    valueController = TextEditingController();
  }

  @override
  void dispose() {
    keyController.dispose();
    valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add new string'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Key:', style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: keyController,
          ),
          SizedBox(height: 10),
          Text('Value:', style: TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: valueController,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            final key = keyController.text;
            final value = valueController.text;
            // Perform any desired action with the key-value pair
            _fileBrowserBloc.add(key, value);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
