import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Log out",
    content: "Are u sure u want to log out ?",
    optionsBuilder: () => {
      "Cancel" : false,
      "Log out" : true,
    },
  ).then((value) => value ?? false);
}
