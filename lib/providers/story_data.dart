import 'dart:async';

import 'package:baby_binder/events/event_dialog.dart';
import 'package:baby_binder/events/sleep_events.dart';
import 'package:baby_binder/events/story_events.dart';
import 'package:baby_binder/providers/children_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

final storyDataProvider = ChangeNotifierProvider<StoryData>((ref) {
  final activeChild = ref.watch(activeChildProvider);
  return StoryData(activeChild?.document);
});

class StoryData extends ChangeNotifier {
  StoryData(DocumentReference<Map<String, dynamic>>? document)
      : _document = document {
    if (_document != null) {
      _initListener();
    }
  }

  List<StoryEvent> events = [];
  bool get isSleeping =>
      events.reversed
          .firstWhere(
            (e) =>
                e.eventType == EventType.started_sleeping ||
                e.eventType == EventType.ended_sleeping,
            orElse: () => EndSleepEvent(),
          )
          .eventType ==
      EventType.started_sleeping;
  final DocumentReference<Map<String, dynamic>>? _document;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? listener;

  void _initListener() {
    listener = _document!
        .collection('events')
        .orderBy('time')
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          events.add(createEventFromData(
            docChange.doc.data() ?? {},
            docChange.doc.id,
          ));
        } else if (docChange.type == DocumentChangeType.removed) {
          events.removeWhere((c) => c.id == docChange.doc.id);
        } else if (docChange.type == DocumentChangeType.modified) {
          var data = docChange.doc.data();
          if (data != null) {
            int i = events.indexWhere((e) => e.id == docChange.doc.id);

            StoryEvent orig = events[i];
            StoryEvent updated = createEventFromData(data, docChange.doc.id);

            events[i] = updated;
            if (!orig.eventTime.isAtSameMomentAs(updated.eventTime)) {
              events.sort((a, b) => a.eventTime.compareTo(b.eventTime));
            }
          }
        }
        notifyListeners();
      }
    });
  }

  Future<void> refresh() async {
    events = [];
    await listener?.cancel();
    _initListener();
  }

  void _addEvent(StoryEvent event) {
    // _events.insert(0, event);
    if (_document != null) {
      _document!.collection('events').add(event.convertToMap());
    }
  }

  void addNewEvent(EventType eventType, BuildContext context) async {
    StoryEvent event = createEventFromType(eventType);
    if (event.buildDialog != null) {
      EventDialogResult? result = await showModalBottomSheet(
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
              height: 400,
              child: event.buildDialog!(context),
            ),
          ),
        ),
      );
      if (result == EventDialogResult.Save) {
        _addEvent(event);
      }
    } else {
      _addEvent(event);
    }
  }

  void _editEvent(StoryEvent event) {
    if (_document != null) {
      _document!
          .collection('events')
          .doc(event.id)
          .update(event.convertToMap());
    }
  }

  void _deleteEvent(StoryEvent event) {
    if (_document != null) {
      _document!.collection('events').doc(event.id).delete();
    }
  }

  void editEvent(StoryEvent event, BuildContext context) async {
    StoryEvent clone = cloneEvent(event);
    bool eventHasCustomDialog = clone.buildDialog != null;
    EventDialogResult? result = await showModalBottomSheet(
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
            height: eventHasCustomDialog ? 400 : 200,
            child: eventHasCustomDialog
                ? clone.buildDialog!(context, isEdit: true)
                : EventDialog(
                    title: clone.eventType.title,
                    content: (Function(Function()) blank) => const SizedBox(),
                    isEdit: true,
                    event: clone,
                  ),
          ),
        ),
      ),
    );
    if (result == EventDialogResult.Save) {
      _editEvent(clone);
    } else if (result == EventDialogResult.Delete) {
      _deleteEvent(clone);
    }
  }
}
