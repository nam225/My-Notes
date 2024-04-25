import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Delete",
    content: "Are u sure u want to delete this item ?",
    optionsBuilder: () => {
      'Cancel': false,
      'Yes' : true,
    },
  ).then((value) => value ?? false);
}
