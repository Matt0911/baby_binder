import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
// import 'package:google_fonts/google_fonts.dart';

final userDataProvider = ChangeNotifierProvider<UserData>((ref) => UserData());
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class UserData extends ChangeNotifier {
  UserData() {
    init();
  }

  BuildContext? context;
  Future<void> init() async {
    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null) {
        _initializeData(user);
      } else {
        _resetData();
      }
    });
  }

  bool isLoaded = false;

  String? name;
  String? uid;
  String? email;
  List<String> children = [];

  void _initializeData(User user) {
    firestore.collection('users').doc(user.uid).snapshots().listen((event) {
      final data = event.data() ?? {};
      name = data['name'];
      uid = user.uid;
      email = data['email'];
      children =
          (data['children'] as List).map((child) => child as String).toList();
      isLoaded = true;
      notifyListeners();
    });
  }

  void _resetData() {
    name = null;
    uid = null;
    email = null;
    children = [];
    isLoaded = false;
    notifyListeners();
  }
}
