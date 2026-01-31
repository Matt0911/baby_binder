import 'package:flutter/material.dart';

class TextFieldEditResults {
  TextFieldEditResults({required this.didSave, this.value});
  final bool didSave;
  final String? value;
}

class TextFieldEditor extends StatefulWidget {
  const TextFieldEditor({
    super.key,
    required this.name,
    this.initialValue,
  });

  final String name;
  final String? initialValue;

  @override
  _TextFieldEditorState createState() => _TextFieldEditorState();
}

class _TextFieldEditorState extends State<TextFieldEditor> {
  late TextEditingController _controller;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('${widget.name}:'),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                onSubmitted: ((value) => Navigator.pop(
                      context,
                      TextFieldEditResults(didSave: true, value: value),
                    )),
              ),
            ),
          ],
        ),
        const Expanded(child: SizedBox()),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, TextFieldEditResults(didSave: false)),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                TextFieldEditResults(didSave: true, value: _controller.text),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}

final showTextFieldBottomSheet = (
  BuildContext context,
  String fieldName,
  String? initialValue,
) =>
    showModalBottomSheet<TextFieldEditResults>(
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      context: context,
      builder: (BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10)
              .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: TextFieldEditor(
              name: fieldName,
              initialValue: initialValue,
            ),
          ),
        ),
      ),
    );
