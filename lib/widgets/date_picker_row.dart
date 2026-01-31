import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

class DatePickerRow extends StatelessWidget {
  const DatePickerRow({
    super.key,
    this.fontSize = 18,
    required this.settingName,
    required this.settingValue,
    required this.updateValue,
  });

  final double fontSize;
  final String settingName;
  final DateTime? settingValue;
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
            DateTime now = DateTime.now();
            final selected = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime.utc(2000),
              lastDate: now.add(const Duration(days: 280)),
            );
            if (selected == null) return;
            updateValue(selected);
          },
          child: Text(
            settingValue == null ? 'Set' : _dateFormatter.format(settingValue!),
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
