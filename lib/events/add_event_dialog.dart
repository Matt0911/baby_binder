import 'package:flutter/material.dart';

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({Key? key, required this.title, required this.content})
      : super(key: key);

  final String title;
  final Widget Function(Map, Function) content;

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  Map eventData = {};

  _updateEventData(Map data) {
    setState(() {
      eventData.addAll(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.title,
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        SizedBox(height: 20),
        widget.content(eventData, _updateEventData),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, [false]),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, [true, eventData]),
              child: const Text('Add'),
            ),
          ],
        )
      ],
    );
  }
}