import 'package:baby_binder/providers/children_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

final laborTrackerDataProvider =
    ChangeNotifierProvider<LaborTrackerData>((ref) {
  final activeChild = ref.watch(activeChildProvider);
  return LaborTrackerData(activeChild?.document);
});

class LaborTrackerData extends ChangeNotifier {
  LaborTrackerData(DocumentReference<Map<String, dynamic>>? activeChildDocument)
      : _document = activeChildDocument {
    if (_document != null) {
      _document!.collection('labor').orderBy('time').snapshots().listen(
        (snapshot) {
          for (var docChange in snapshot.docChanges) {
            if (docChange.type == DocumentChangeType.added) {
              _addContraction(docChange.doc.id, docChange.doc.data() ?? {});
            } else if (docChange.type == DocumentChangeType.removed) {
              _removeContraction(docChange.doc.id);
            }
          }
          notifyListeners();
        },
      );
    }
  }

  List<Contraction> contractions = [];
  final DocumentReference<Map<String, dynamic>>? _document;

  void _removeContraction(String id) {
    contractions.removeWhere((c) => c.id == id);
  }

  void _addContraction(String id, Map<String, dynamic> data) {
    contractions.insert(0, Contraction.fromData(id, data));
  }

  void _createContraction(Contraction c) {
    // _events.insert(0, event);
    if (_document != null) {
      _document!.collection('labor').add(c.convertToMap());
    }
  }

  void addNewContraction(Contraction c) async {
    _createContraction(c);
  }
}

class Contraction {
  Contraction({DateTime? start}) {
    _start = start ?? DateTime.now();
  }

  Contraction.fromData(String id, Map<String, dynamic> data)
      : _start = (data['time'] as Timestamp).toDate(),
        id = id,
        duration = Duration(seconds: data['durationSeconds']);

  String? id;
  late DateTime _start;
  DateTime get start => _start;
  Duration? duration;

  Map<String, dynamic> convertToMap() => {
        'time': start,
        'durationSeconds': duration!.inSeconds,
      };
}

final oneHourLaborDataProvider = Provider((ref) {
  final contractions = ref.watch(laborTrackerDataProvider).contractions;
  List<Contraction> oneHourContractions = contractions
      .where((c) =>
          c.start.isAfter(DateTime.now().subtract(const Duration(hours: 1))))
      .toList();
  int durationTot = 0, intervalTot = 0, restTot = 0;
  int len = oneHourContractions.length;
  if (len == 0) {
    return OneHourLaborData(
      contractions: oneHourContractions,
      durationSeconds: -1,
      intervalSeconds: -1,
      restSeconds: -1,
    );
  }
  if (len > 1) {
    for (int i = 0; i < len; i++) {
      Contraction cur = oneHourContractions[i];
      durationTot += cur.duration!.inSeconds;
      if (i < len - 1) {
        Contraction prev = oneHourContractions[i + 1];
        intervalTot += cur.start.difference(prev.start).inSeconds;
        restTot +=
            cur.start.difference(prev.start.add(prev.duration!)).inSeconds;
      }
    }
  } else {
    durationTot = oneHourContractions[0].duration!.inSeconds;
    intervalTot = -1;
    restTot = -1;
  }
  int durationAvg = (durationTot / len).round();
  int intervalAvg = len > 1 ? (intervalTot / (len - 1)).round() : -1;
  int restAvg = len > 1 ? (restTot / (len - 1)).round() : -1;
  return OneHourLaborData(
    contractions: oneHourContractions,
    durationSeconds: durationAvg,
    intervalSeconds: intervalAvg,
    restSeconds: restAvg,
  );
});

class OneHourLaborData {
  OneHourLaborData({
    required this.durationSeconds,
    required this.intervalSeconds,
    required this.restSeconds,
    required this.contractions,
  });
  final int durationSeconds;
  final int intervalSeconds;
  final int restSeconds;
  final List<Contraction> contractions;
}
