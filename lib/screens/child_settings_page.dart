import 'package:baby_binder/providers/children_data.dart';
import 'package:baby_binder/widgets/baby_binder_drawer.dart';
import 'package:baby_binder/widgets/child_avatar.dart';
import 'package:baby_binder/widgets/date_picker_row.dart';
import 'package:baby_binder/widgets/time_picker_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChildSettingsPage extends ConsumerWidget {
  static const String routeName = '/child-settings-page';

  const ChildSettingsPage({super.key});

  @override
  Widget build(context, ref) {
    final activeChild = ref.watch(activeChildProvider);
    return activeChild == null
        ? const CircularProgressIndicator()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Baby Binder'),
            ),
            drawer: const BabyBinderDrawer(),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChildAvatar(
                      childImage: activeChild.image,
                      childName: activeChild.name,
                      updateName: activeChild.updateName,
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          DatePickerRow(
                            settingName: 'Birth Date',
                            settingValue: activeChild.birthdate,
                            updateValue: activeChild.updateBirthDate,
                          ),
                          activeChild.birthdate != null &&
                                  DateTime(
                                        activeChild.birthdate!.year,
                                        activeChild.birthdate!.month,
                                        activeChild.birthdate!.day,
                                      ).compareTo(DateTime.now()) <=
                                      0
                              ? TimePickerRow(
                                  settingName: 'Birth Time',
                                  settingValue: activeChild.birthdate!,
                                  updateValue: activeChild.updateBirthDate,
                                )
                              : const SizedBox(),
                        ],
                      )),
                  // OutlinedButton(
                  //   child: Text(
                  //     'View Story',
                  //     style: TextStyle(fontSize: 20),
                  //   ),
                  //   onPressed: () =>
                  //       Navigator.pushNamed(context, ChildStoryPage.routeName),
                  // ),
                ],
              ),
            ),
          );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    super.key,
    required this.fontSize,
    required this.settingName,
    required this.settingValue,
  });

  final double fontSize;
  final String settingName;
  final String settingValue;

  @override
  Widget build(context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                settingName,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              child: Text(
                settingValue,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ));
  }
}
