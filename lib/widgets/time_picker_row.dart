import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat _timeFormatter = DateFormat('hh:mm a');

class TimePickerRow extends StatelessWidget {
  const TimePickerRow({
    super.key,
    this.fontSize = 18,
    required this.settingName,
    required this.settingValue,
    required this.updateValue,
  });

  final double fontSize;
  final String settingName;
  final DateTime settingValue;
  final Function(DateTime?) updateValue;

  @override
  Widget build(context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Text(
            settingName,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        MaterialButton(
          visualDensity: VisualDensity.compact,
          onPressed: () async {
            final selected = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(settingValue),
            );
            print('selected $selected');
            if (selected == null) return;
            updateValue(DateTime(settingValue.year, settingValue.month,
                settingValue.day, selected.hour, selected.minute));
          },
          child: Text(
            _timeFormatter.format(settingValue),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }
}
