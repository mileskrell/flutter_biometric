import 'dart:convert';

import 'package:biometric_test/master_password_dialog.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart';
import 'package:local_auth/local_auth.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final localAuth = LocalAuthentication();
  bool authenticated = false;
  String masterPasswordInput = "";

  void _showSimpleSnackBar(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSecret(BuildContext context) async {
    if (authenticated) {
      _showSimpleSnackBar(context, "Already authenticated");
      return;
    }

    bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      bool authSuccessful = await showDialog(context: context, builder: (context) => MasterPasswordDialog("Cannot check biometrics"));
      if (authSuccessful) {
        setState(() {
          authenticated = true;
        });
      } else {
        _showSimpleSnackBar(context, "Incorrect master password");
      }
    } else {
      try {
        bool authSuccessful = await localAuth.authenticateWithBiometrics(localizedReason: "Authenticate to view secret data", useErrorDialogs: true);
        if (authSuccessful) {
          setState(() {
            authenticated = true;
          });
        } else {
            _showSimpleSnackBar(context, "Authentication failure");
        }
      } on PlatformException catch (e) {
        String reason;
        switch (e.code) {
          case passcodeNotSet:
            reason = "PIN/pattern/password not set; can't use biometric auth";
            break;
          case notEnrolled:
            reason = "No fingerprints enrolled";
            break;
          case notAvailable:
            reason = "No fingerprint scanner available";
            break;
          case otherOperatingSystem:
            reason = "Operating system isn't iOS or Android; can't use biometric auth";
            break;
          case lockedOut:
            reason = "Biometric auth locked out due to too many attempts";
            break;
          case permanentlyLockedOut:
            reason = "Biometric auth locked out due to too many attempts. Strong authentication like PIN/pattern/password is required to unlock.";
            break;
        }
        bool authSuccessful = await showDialog(context: context, builder: (context) => MasterPasswordDialog(reason));
        if (authSuccessful) {
          setState(() {
            authenticated = true;
          });
        } else {
          _showSimpleSnackBar(context, "Incorrect master password");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Biometric auth test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              authenticated ? "Epstein didn't kill himself" : "CLASSIFIED (authenticate to view)",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          onPressed: () => _showSecret(context),
          tooltip: 'Show secret data',
          child: Icon(Icons.vpn_key),
        );
      },),
    );
  }
}
