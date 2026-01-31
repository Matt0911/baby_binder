import 'package:baby_binder/events/story_events.dart';
import 'package:baby_binder/providers/app_state.dart';
import 'package:baby_binder/providers/children_data.dart';
import 'package:baby_binder/providers/story_data.dart';
import 'package:baby_binder/screens/labor_tracker_page.dart';
import 'package:baby_binder/widgets/baby_binder_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class ChildStoryPage extends ConsumerWidget {
  static const routeName = '/child_story';

  const ChildStoryPage({super.key});

  @override
  Widget build(context, ref) {
    Child? activeChild = ref.watch(activeChildProvider);
    if (activeChild == null) return const CircularProgressIndicator();

    // Apply system nav bar color explicitly to ensure Android uses it.
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.teal[300],
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.teal[300],
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('${activeChild.name}\'s Story')),
        drawer: const BabyBinderDrawer(),
        body: const ChildStory(),
      ),
    );
  }
}

class EventButton extends StatelessWidget {
  const EventButton({
    super.key,
    required this.size,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });
  final double size;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      elevation: 3,
      constraints: BoxConstraints(minWidth: size + 8, minHeight: size + 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      fillColor: backgroundColor,
      onPressed: () => onPressed(),
      child: Icon(
        icon,
        size: size / 1.5,
        color: iconColor,
      ),
    );
  }
}

class ChildStory extends ConsumerWidget {
  const ChildStory({
    super.key,
  });

  @override
  Widget build(context, ref) {
    final story = ref.watch(storyDataProvider);
    final events = story.events;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: RefreshIndicator(
            onRefresh: story.refresh,
            child: events.isEmpty
                ? const Center(
                    child: Text('No events yet'),
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final eventIndex = events.length - 1 - index;
                      final event = events[eventIndex];

                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: event.eventType.backgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            event.eventType.icon,
                            color: event.eventType.iconColor,
                          ),
                        ),
                        title: Text(
                          event.getTimelineDescription(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(event.getFormattedTime()),
                        onLongPress: () => story.editEvent(event, context),
                      );
                    },
                  ),
          ),
        ),
        AddEventButtons(addEvent: story.addNewEvent),
      ],
    );
  }
}

class AddEventButtons extends ConsumerStatefulWidget {
  const AddEventButtons({super.key, required this.addEvent});
  final Function(EventType, BuildContext) addEvent;

  @override
  _AddEventButtonsState createState() => _AddEventButtonsState();
}

class _AddEventButtonsState extends ConsumerState<AddEventButtons> {
  bool clicked = false;
  List<Widget> getBornEvents(BuildContext context, StoryData story) => [
        EventButton(
          size: 60,
          backgroundColor: EventType.ended_sleeping.backgroundColor,
          icon: EventType.ended_sleeping.icon,
          iconColor: EventType.ended_sleeping.iconColor,
          onPressed: () => widget.addEvent(
            story.isSleeping
                ? EventType.ended_sleeping
                : EventType.started_sleeping,
            context,
          ),
        ),
        EventButton(
          size: 60,
          backgroundColor: EventType.diaper.backgroundColor,
          icon: EventType.diaper.icon,
          iconColor: EventType.diaper.iconColor,
          onPressed: () {
            setState(() {
              widget.addEvent(EventType.diaper, context);
              clicked = true;
            });
          },
        ),
        EventButton(
          size: 60,
          backgroundColor: EventType.feeding.backgroundColor,
          icon: EventType.feeding.icon,
          iconColor: EventType.feeding.iconColor,
          onPressed: () => widget.addEvent(EventType.feeding, context),
        ),
      ];

  List<Widget> getUnbornEvents(BuildContext context) => [
        EventButton(
          size: 60,
          backgroundColor: Colors.orange.shade50,
          icon: Icons.medical_services,
          iconColor: Colors.orange,
          onPressed: () => ref
              .read(appStateProvider)
              .navigateToPage(context, LaborTrackerPage.routeName),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final activeChild = ref.watch(activeChildProvider);
    final story = ref.watch(storyDataProvider);
    return SafeArea(
      bottom: true,
      child: Material(
        color: Colors.teal[300],
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 16.0 + MediaQuery.of(context).padding.bottom,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: activeChild!.isBorn
                ? getBornEvents(context, story)
                : getUnbornEvents(context),
          ),
        ),
      ),
    );
  }
}
