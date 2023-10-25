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

  Future<void> connectServer() async {
    var err = await bloc.connectServer();
    if (err == Error.noPassword) {
      showDialog(
        context: context,
        builder: (context) => InputPasswordDialog(bloc),
      ).then((value) {
        connectServer();
      });
    } else {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            color: Colors.red.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ToolBar(),
            ),
          ),
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
              connectServer();
            },
            label: Text("Connecting Virtual Server")),
        TextButton.icon(
            icon: Icon(Icons.password),
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => InputPasswordDialog(bloc),
              );
            },
            label: Text("reset password")),
      ],
    );
  }
}

class InputPasswordDialog extends StatefulWidget {
  InputPasswordDialog(this.bloc);
  final VirtualAmberBloc bloc;
  @override
  _InputPasswordDialogState createState() => _InputPasswordDialogState();
}

class _InputPasswordDialogState extends State<InputPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Password'),
      content: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(hintText: 'Password'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // TODO: Validate the password and do something with it.
            widget.bloc.setPwd(_passwordController.text.toString());
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
