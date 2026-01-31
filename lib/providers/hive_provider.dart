import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final hiveProvider = FutureProvider<HiveDB>((_) => HiveDB.create());

class HiveDB {
  var _generalBox;

  HiveDB._create();

  static Future<HiveDB> create() async {
    final component = HiveDB._create();
    await component._init();
    return component;
  }

  Future<void> _init() async {
    _generalBox = await Hive.openBox('general');
  }

  void updateLastPage(String page) {
    _generalBox.put('lastPage', page);
  }

  String getLastPage() {
    return _generalBox.get('lastPage') ?? '';
  }
}
