import 'dart:async';

import 'package:baby_binder/providers/story_data.dart';
import 'package:baby_binder/providers/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:hive/hive.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

final childrenDataProvider = ChangeNotifierProvider<ChildrenData>(
    (ref) => ChildrenData(ref.watch(userDataProvider)));

class ChildrenData extends ChangeNotifier {
  ChildrenData(this.userData) {
    // firestore.clearPersistence();
    _init();
  }

  UserData userData;

  Future<void> _init() async {
    prefs = await Hive.openBox('childrenData');

    if (userData.isLoaded && userData.children.isNotEmpty) {
      final initialSavedChildId = prefs.get('activeChild');
      _childrenListSubscription = firestore
          .collection('children')
          .where(FieldPath.documentId, whereIn: userData.children)
          .snapshots()
          .listen(
        (snapshot) {
          for (var docChange in snapshot.docChanges) {
            String childId = docChange.doc.id;
            if (docChange.type == DocumentChangeType.added) {
              children.add(childId);
              _childrenDataMaps[childId] = docChange.doc.data();
              if (initialSavedChildId != null &&
                  initialSavedChildId == childId &&
                  activeChildId == null) {
                setActiveChild(id: initialSavedChildId);
              }
            } else if (docChange.type == DocumentChangeType.removed) {
              children.removeWhere((c) => c == childId);
              _childrenDataMaps.remove(childId);
            } else if (docChange.type == DocumentChangeType.modified) {
              print('modified $docChange');
              _childrenDataMaps[childId] = docChange.doc.data();
            }
          }
          notifyListeners();
        },
      );
    } else {
      children = [];
      activeChildId = null;
      _childrenListSubscription?.cancel();
      notifyListeners();
    }
  }

  Future<void> setActiveChild({required String id}) async {
    if (activeChildId == null || id != activeChildId) {
      activeChildId = id;
      prefs.put('activeChild', id);
      notifyListeners();
    }
  }

  late Box prefs;
  StreamSubscription<QuerySnapshot>? _childrenListSubscription;
  List<String> children = [];
  final Map<String, Map<String, dynamic>?> _childrenDataMaps = {};
  String? activeChildId;
}

final activeChildIdProvider = Provider((ref) {
  final childrenData = ref.watch(childrenDataProvider);
  return childrenData.activeChildId;
});

final activeChildDataProvider = Provider((ref) {
  final childrenData = ref.watch(childrenDataProvider);
  return childrenData._childrenDataMaps[childrenData.activeChildId];
});

final activeChildProvider = Provider((ref) {
  final activeChildId = ref.watch(activeChildIdProvider);
  final activeChildData = ref.watch(activeChildDataProvider);
  if (activeChildId == null) {
    return null;
  }
  return Child(activeChildId, activeChildData);
});

final childrenListProvider = Provider((ref) {
  final childrenData = ref.watch(childrenDataProvider);
  return childrenData.children
      .map((id) => Child(id, childrenData._childrenDataMaps[id]))
      .toList();
});

class Child {
  Child.manual({required String id, required this.name, required this.image})
      : _id = id,
        document = firestore.collection('children').doc(id);

  Child(String id, Map<String, dynamic>? data)
      : _id = id,
        document = firestore.collection('children').doc(id) {
    _updateData(data);
  }

  void _updateData(Map<String, dynamic>? data) {
    if (data != null) {
      rawData = data;
      name = data['name'];
      image = data['image'];
      Timestamp? t = data['birthdate'] as Timestamp?;
      if (t != null) {
        birthdate = t.toDate();
      }
    }
  }

  final String _id;
  String get id => _id;
  Map<String, dynamic>? rawData;

  DocumentReference<Map<String, dynamic>> document;

  late String name;
  late String image;

  DateTime? birthdate;
  bool get isBorn =>
      birthdate != null && birthdate!.compareTo(DateTime.now()) <= 0;

  StoryData? story;

  void updateName(String name) {
    document.update({'name': name});
  }

  void updateBirthDate(DateTime? birth) {
    print('updating birth: $birth');
    document.update({
      'birthdate':
          birth == null ? FieldValue.delete() : Timestamp.fromDate(birth)
    });
  }
}
