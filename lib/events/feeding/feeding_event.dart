import 'package:baby_binder/events/event_dialog.dart';
import 'package:baby_binder/events/story_events.dart';
import 'package:flutter/material.dart';
import 'bottle_tab.dart';
import 'nursing_tab.dart';
import 'solids_tab.dart';

enum FeedingType {
  nursing,
  bottle,
  solids,
}

const kNursingFeedingKey = 'nursing';
const kBottleFeedingKey = 'bottle';
const kSolidsFeedingKey = 'solids';

FeedingType getFeedingType(String key) {
  switch (key) {
    case kNursingFeedingKey:
      return FeedingType.nursing;
    case kBottleFeedingKey:
      return FeedingType.bottle;
    case kSolidsFeedingKey:
      return FeedingType.solids;
    default:
      return FeedingType.nursing;
  }
}

extension on FeedingType {
  String get key {
    switch (this) {
      case FeedingType.nursing:
        return kNursingFeedingKey;
      case FeedingType.bottle:
        return kBottleFeedingKey;
      case FeedingType.solids:
        return kSolidsFeedingKey;
    }
  }
}

class FeedingEvent extends StoryEvent {
  FeedingType type = FeedingType.nursing;
  // nursing data
  bool left = true;
  int leftTime = 10;
  bool right = true;
  int rightTime = 10;

  // bottle data
  bool isOunces = true;
  double volume = 4;

  // solids data
  List<String> solidFoods = [];

  @override
  late Widget Function(BuildContext context, {bool isEdit})? buildDialog =
      (context, {isEdit = false}) => EventDialog(
            title: EventType.feeding.title,
            isEdit: isEdit,
            event: this,
            content: (Function(Function()) updateEventData) =>
                FeedingDialogContent(
              event: this,
              updateEventData: updateEventData,
            ),
          );

  FeedingEvent()
      : super(
          eventType: EventType.feeding,
          eventTime: DateTime.now(),
        );

  FeedingEvent.fromData(Map<String, dynamic> data, String? id)
      : type = getFeedingType(data['feedType']),
        left = data['left'] ?? true,
        leftTime = data['leftTime'] ?? 10,
        right = data['right'] ?? true,
        rightTime = data['rightTime'] ?? 10,
        isOunces = data['isOunces'] ?? true,
        volume = data['volume'] ?? 4,
        solidFoods = data['solidFoods'] != null
            ? List<String>.from(data['solidFoods'])
            : <String>[],
        super(
          eventType: EventType.feeding,
          eventTime: castDate(data['time']),
          id: id,
        );

  FeedingEvent.withTime({
    required eventTime,
  }) : super(
          eventType: EventType.feeding,
          eventTime: eventTime,
        );

  @override
  Map<String, dynamic> convertToMap() {
    Map<String, dynamic> others;
    switch (type) {
      case FeedingType.nursing:
        others = {
          'left': left,
          'leftTime': leftTime,
          'right': right,
          'rightTime': rightTime,
        };
        break;
      case FeedingType.bottle:
        others = {
          'isOunces': isOunces,
          'volume': volume,
        };
        break;
      case FeedingType.solids:
        others = {
          'solidFoods': solidFoods,
        };
        break;
    }
    return {
      ...super.convertToMap(),
      'feedType': type.key,
      ...others,
    };
  }

  @override
  String getTimelineDescription() {
    if (type == FeedingType.nursing) {
      return 'Left: ${leftTime}min, Right: ${rightTime}min';
    } else if (type == FeedingType.bottle) {
      return '$volume${isOunces ? 'oz' : 'mL'}';
    } else if (type == FeedingType.solids) {
      return solidFoods.join(', ');
    }
    return 'Feeding';
  }
}

class FeedingDialogContent extends StatefulWidget {
  const FeedingDialogContent({
    // TODO: fix styling now that content is in expanded
    super.key,
    required this.event,
    required this.updateEventData,
  });

  final FeedingEvent event;
  final Function(Function()) updateEventData;

  @override
  State<FeedingDialogContent> createState() => _FeedingDialogContentState();
}

class _FeedingDialogContentState extends State<FeedingDialogContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  void _handleTabSelection() {
    switch (_tabController.index) {
      case 0:
        widget.updateEventData(() => widget.event.type = FeedingType.nursing);
        break;
      case 1:
        widget.updateEventData(() => widget.event.type = FeedingType.bottle);
        break;
      case 2:
        widget.updateEventData(() => widget.event.type = FeedingType.solids);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, initialIndex: 0, length: 3);

    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Nursing'),
              Tab(text: 'Bottle'),
              Tab(text: 'Solids')
            ],
            controller: _tabController,
            indicatorColor: Colors.teal.shade200,
            labelColor: Colors.teal,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                NursingTab(
                  event: widget.event,
                  updateEventData: widget.updateEventData,
                ),
                BottleTab(
                  event: widget.event,
                  updateEventData: widget.updateEventData,
                ),
                SolidTab(
                  event: widget.event,
                  updateEventData: widget.updateEventData,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
