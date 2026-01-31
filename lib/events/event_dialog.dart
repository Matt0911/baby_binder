import 'package:baby_binder/events/story_events.dart';
import 'package:baby_binder/widgets/date_picker_row.dart';
import 'package:baby_binder/widgets/time_picker_row.dart';
import 'package:flutter/material.dart';

enum EventDialogResult {
  Cancel,
  Save,
  Delete,
}

class EventDialog extends StatefulWidget {
  const EventDialog({
    super.key,
    required this.title,
    required this.content,
    this.isEdit = false,
    required this.event,
  });

  final String title;
  final Widget Function(Function(Function())) content;
  final bool isEdit;
  final StoryEvent event;

  @override
  _EventDialogState createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  void _updateEventData(Function() updater) {
    setState(() {
      updater();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dateControls = widget.isEdit
        ? [
            DatePickerRow(
              settingName: 'Date',
              settingValue: widget.event.eventTime,
              updateValue: (date) => setState(() {
                widget.event.updateDate(date);
              }),
            ),
            TimePickerRow(
              settingName: 'Time',
              settingValue: widget.event.eventTime,
              updateValue: (date) => setState(() {
                widget.event.updateDate(date);
              }),
            )
          ]
        : [];
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Column(
            children: [
              widget.content(_updateEventData),
              ...dateControls,
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, EventDialogResult.Cancel),
              child: const Text('Cancel'),
            ),
            ...(widget.isEdit
                ? [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, EventDialogResult.Delete),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ]
                : []),
            TextButton(
              onPressed: () => Navigator.pop(context, EventDialogResult.Save),
              child: Text(widget.isEdit ? 'Save' : 'Add'),
            ),
          ],
        )
      ],
    );
  }
}
