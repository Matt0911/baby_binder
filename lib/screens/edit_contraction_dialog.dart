import 'package:baby_binder/providers/labor_tracker.dart';
import 'package:baby_binder/widgets/date_picker_row.dart';
import 'package:baby_binder/widgets/time_picker_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditContractionDialog extends StatefulWidget {
  final Contraction contraction;

  const EditContractionDialog({super.key, required this.contraction});

  @override
  State<EditContractionDialog> createState() => _EditContractionDialogState();
}

class _EditContractionDialogState extends State<EditContractionDialog> {
  late DateTime _startTime;
  late int _durationMinutes;
  late int _durationSeconds;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _startTime = widget.contraction.start;
    _durationMinutes = widget.contraction.duration?.inMinutes ?? 0;
    _durationSeconds = (widget.contraction.duration?.inSeconds ?? 0) % 60;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Contraction'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DatePickerRow(
              settingName: 'Date',
              settingValue: _startTime,
              updateValue: (date) {
                if (date != null) {
                  setState(() {
                    _startTime = DateTime(date.year, date.month, date.day,
                        _startTime.hour, _startTime.minute);
                  });
                }
              },
            ),
            TimePickerRow(
              settingName: 'Time',
              settingValue: _startTime,
              updateValue: (time) {
                if (time != null) {
                  setState(() {
                    _startTime = time;
                  });
                }
              },
            ),
            Row(
              children: [
                const Text('Duration'),
                const Spacer(),
                SizedBox(
                  width: 50,
                  child: TextFormField(
                    initialValue: _durationMinutes.toString(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Mins'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '...';
                      return null;
                    },
                    onSaved: (value) {
                      _durationMinutes = int.tryParse(value ?? '') ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 50,
                  child: TextFormField(
                    initialValue: _durationSeconds.toString(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Secs'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '...';
                      if ((int.tryParse(value) ?? 0) > 59) {
                        return '>59';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _durationSeconds = int.tryParse(value ?? '') ?? 0;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final updatedContraction = widget.contraction.copyWith(
                start: _startTime,
                duration: Duration(
                  minutes: _durationMinutes,
                  seconds: _durationSeconds,
                ),
              );
              Navigator.of(context).pop(updatedContraction);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
