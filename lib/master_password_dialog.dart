import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MasterPasswordDialog extends StatefulWidget {
  final String reason;

  MasterPasswordDialog(this.reason);

  @override
  State<StatefulWidget> createState() => MasterPasswordDialogState();
}

class MasterPasswordDialogState extends State<MasterPasswordDialog> {
  String masterPasswordInput;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reason),
      content: TextField(
        onChanged: (input) {
          setState(() {
            masterPasswordInput = input;
          });
        },
        decoration: InputDecoration.collapsed(hintText: "Enter master password"),
      ),
      actions: <Widget>[FlatButton(
        child: Text("Submit"),
        onPressed: () {
          final hashedInput = sha256.convert(utf8.encode(masterPasswordInput)).toString();
          if (hashedInput == "fc613b4dfd6736a7bd268c8a0e74ed0d1c04a959f59dd74ef2874983fd443fc9") {
            Navigator.pop(context, true);
          } else {
            Navigator.pop(context, false);
          }
        },
      )],
    );
  }
}