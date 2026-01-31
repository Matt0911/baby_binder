import 'dart:math';

import 'package:baby_binder/constants.dart';
import 'package:baby_binder/events/feeding/feeding_event.dart';
import 'package:flutter/material.dart';

const double minOz = .1;
const double maxOz = 10;
const double minML = 1;
const double maxML = 100;

class BottleTab extends StatelessWidget {
  const BottleTab(
      {super.key, required this.event, required this.updateEventData});
  final FeedingEvent event;
  final Function(Function()) updateEventData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${event.volume}', style: kLargeNumberTextStyle),
            const SizedBox(width: 20),
            ToggleButtons(
              isSelected: [event.isOunces, !event.isOunces],
              borderRadius: BorderRadius.circular(10),
              onPressed: (selected) {
                bool changingToOunces = selected == 0;
                if (changingToOunces != event.isOunces) {
                  double convertedVolume;
                  if (changingToOunces) {
                    convertedVolume = max(
                        double.parse(
                            (event.volume / 29.5735).toStringAsFixed(1)),
                        minOz);
                  } else {
                    convertedVolume =
                        min((event.volume * 29.5735).floorToDouble(), maxML);
                  }
                  updateEventData(() {
                    event.isOunces = changingToOunces;
                    event.volume = convertedVolume;
                  });
                }
              },
              children: const [Text('oz'), Text('mL')],
            ),
          ],
        ),
        Slider(
          value: event.volume,
          min: event.isOunces ? minOz : minML,
          max: event.isOunces ? maxOz : maxML,
          onChanged: (volume) => updateEventData(
            () => event.volume =
                double.parse(volume.toStringAsFixed(event.isOunces ? 1 : 0)),
          ),
        )
      ],
    );
  }
}
