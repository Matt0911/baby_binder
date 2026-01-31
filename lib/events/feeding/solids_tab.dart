import 'package:flutter/material.dart';

class SolidsTab extends StatefulWidget {
  final dynamic event;
  final dynamic updateEventData;

  const SolidsTab({
    super.key,
    required this.event,
    required this.updateEventData,
  });

  @override
  _SolidsTabState createState() => _SolidsTabState();
}

class _SolidsTabState extends State<SolidsTab> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Solids Tab'),
    );
  }
}

class SolidTab extends SolidsTab {
  const SolidTab({
    super.key,
    required super.event,
    required super.updateEventData,
  });
}
