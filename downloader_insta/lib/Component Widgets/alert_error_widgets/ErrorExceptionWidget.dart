
import 'package:flutter/material.dart';

class ErrorExceptionWidget extends StatelessWidget {
  String title;
  String content;
  ErrorExceptionWidget(this.title, this.content,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title.toUpperCase()),
      content: Text(
        content,
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle:
            Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
