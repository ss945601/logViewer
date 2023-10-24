import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latticework/bloc/virtual_amber_bloc.dart';

class VirtualAmberPage extends StatefulWidget {
  VirtualAmberPage({super.key});
  @override
  State<VirtualAmberPage> createState() => _VirtualAmberPageState();
}

class _VirtualAmberPageState extends State<VirtualAmberPage> {
  var bloc = VirtualAmberBloc();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ToolBar(),
        ],
      ),
    );
  }

  Row ToolBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
              bloc.connectServer();
              Clipboard.setData(ClipboardData(text: "lw-virt"));
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                    title: const Text('Hint'),
                    content: const Text("Copy 'lw-virt' to clipboard."),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                  });
            },
            label: Text("Connecting Virtual Server")),
      ],
    );
  }
}
