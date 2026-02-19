import 'dart:async';

import 'package:baby_binder/constants.dart';
import 'package:baby_binder/providers/labor_tracker.dart';
import 'package:baby_binder/widgets/baby_binder_drawer.dart';
import 'package:baby_binder/providers/children_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:baby_binder/screens/edit_contraction_dialog.dart';

String convertSecsToString(int valueInSecs) {
  final mins = valueInSecs ~/ 60;
  final secs = valueInSecs % 60;
  return '${mins > 0 ? '${mins}m ' : ''}${secs > 0 ? '${secs}s' : ''}';
}

class OneHourAveragesDisplay extends ConsumerWidget {
  const OneHourAveragesDisplay({super.key});

  @override
  Widget build(context, ref) {
    final oneHourData = ref.watch(oneHourLaborDataProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Text('Last Hour Averages',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: OneHourAverage(
                    title: 'Duration', valueInSec: oneHourData.durationSeconds),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OneHourAverage(
                    title: 'Interval', valueInSec: oneHourData.intervalSeconds),
              ),
              const SizedBox(width: 10),
            ],
          ),
        )
      ],
    );
  }
}

class OneHourAverage extends StatelessWidget {
  const OneHourAverage({
    super.key,
    required this.title,
    required this.valueInSec,
  });

  final String title;
  final int valueInSec;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.grey[200];
    String value = valueInSec > 0 ? convertSecsToString(valueInSec) : '--';
    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: kMedNumberTextStyle,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final DateFormat _formatter = DateFormat('EEE MMM d hh:mma');

class DataRow extends StatelessWidget {
  const DataRow({super.key, required this.items, this.isBold = false});
  final List<String?> items;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items
            .map((text) => Expanded(
                  child: Center(
                    child: text != null
                        ? Text(
                            text,
                            style: isBold
                                ? kDataRowBoldTextStyle
                                : kDataRowTextStyle,
                          )
                        : const SizedBox(),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class ContractionRow extends ConsumerWidget {
  const ContractionRow({
    super.key,
    required this.contraction,
    this.prevContraction,
    this.onLongPress,
  });
  final Contraction contraction;
  final Contraction? prevContraction;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oneHourContractions =
        ref.watch(oneHourLaborDataProvider).contractions;
    final isHighlighted = oneHourContractions.contains(contraction);

    return InkWell(
      onLongPress: onLongPress,
      child: Container(
        color: isHighlighted
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0), // Taller rows
              child: DataRow(items: [
                _formatter.format(contraction.start),
                contraction.duration != null
                    ? convertSecsToString(contraction.duration!.inSeconds)
                    : null,
                prevContraction == null
                    ? '--'
                    : convertSecsToString(contraction.start
                        .difference(prevContraction!.start)
                        .inSeconds),
              ]),
            ),
            const Divider(
                height: 1, thickness: 1, color: Colors.black12), // Divider
          ],
        ),
      ),
    );
  }
}

class TitleRow extends StatelessWidget {
  const TitleRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const DataRow(items: ['Time', 'Duration', 'Interval'], isBold: true);
  }
}

class ContractionTimerButton extends StatefulWidget {
  const ContractionTimerButton(
      {super.key, required this.stopwatch, required this.isRunning});
  final Stopwatch stopwatch;
  final bool isRunning;

  @override
  _ContractionTimerButtonState createState() => _ContractionTimerButtonState();
}

class _ContractionTimerButtonState extends State<ContractionTimerButton> {
  Timer? _timer;
  String _label = '0s';

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (widget.isRunning) {
          setState(() {
            _label = '${widget.stopwatch.elapsed.inSeconds}s';
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRunning && (_timer == null || !_timer!.isActive)) {
      startTimer();
    } else if (!widget.isRunning) {
      _timer?.cancel();
      _label = '0s';
    }
    return Text(widget.isRunning ? _label : 'Start');
  }
}

class LaborTrackerPage extends ConsumerStatefulWidget {
  static const routeName = '/labor-tracker';

  LaborTrackerPage({super.key});

  final Stopwatch stopwatch = Stopwatch();

  @override
  LaborTrackerPageState createState() => LaborTrackerPageState();
}

class LaborTrackerPageState extends ConsumerState<LaborTrackerPage> {
  Contraction? currentContraction;

  @override
  Widget build(BuildContext context) {
    final laborData = ref.watch(laborTrackerDataProvider);
    final activeChild = ref.watch(activeChildProvider);
    final isReadOnly = activeChild?.isBorn ?? false;
    const double bottomButtonHeight = 64.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Labor Tracker')),
      drawer: const BabyBinderDrawer(),
      body: Stack(
        children: [
          // Main scrollable content (header + list)
          ListView.builder(
            padding: EdgeInsets.only(
              left: 0,
              right: 0,
              top: 8.0,
              bottom: bottomButtonHeight +
                  MediaQuery.of(context).padding.bottom +
                  16.0,
            ),
            itemCount: laborData.contractions.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: OneHourAveragesDisplay(),
                );
              }
              if (index == 1) {
                return const TitleRow();
              }
              final i = index - 2;
              final contraction = laborData.contractions[i];
              return ContractionRow(
                contraction: contraction,
                prevContraction: i + 1 < laborData.contractions.length
                    ? laborData.contractions[i + 1]
                    : null,
                onLongPress: isReadOnly
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Wrap(
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(Icons.edit),
                                    title: const Text('Edit'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      final updatedContraction =
                                          await showDialog<Contraction>(
                                        context: context,
                                        builder: (context) =>
                                            EditContractionDialog(
                                                contraction: contraction),
                                      );
                                      if (updatedContraction != null) {
                                        ref
                                            .read(laborTrackerDataProvider)
                                            .updateContraction(
                                                updatedContraction);
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: const Text('Delete'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      ref
                                          .read(laborTrackerDataProvider)
                                          .deleteContraction(contraction);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
              );
            },
          ),

          // Bottom overlayed button
          Visibility(
            visible: !isReadOnly,
            child: Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: SizedBox(
                      height: bottomButtonHeight,
                      child: RawMaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        onPressed: isReadOnly
                            ? null
                            : () {
                                setState(() {
                                  if (currentContraction == null) {
                                    currentContraction = Contraction();
                                    widget.stopwatch.start();
                                    WakelockPlus.enable();
                                  } else {
                                    widget.stopwatch.stop();
                                    WakelockPlus.disable();
                                    currentContraction!.duration =
                                        widget.stopwatch.elapsed;
                                    laborData
                                        .addNewContraction(currentContraction!);
                                    widget.stopwatch.reset();
                                    currentContraction = null;
                                  }
                                });
                              },
                        fillColor: currentContraction == null
                            ? Colors.green
                            : Colors.red,
                        constraints: const BoxConstraints(minHeight: 48),
                        textStyle: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        child: ContractionTimerButton(
                          stopwatch: widget.stopwatch,
                          isRunning: currentContraction != null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
