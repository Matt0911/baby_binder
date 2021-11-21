import 'package:baby_binder/models/child_data.dart';
import 'package:baby_binder/widgets/baby_binder_drawer.dart';
import 'package:baby_binder/widgets/child_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChildSettingsPage extends StatelessWidget {
  static final String routeName = '/child-settings-page';

  Widget _buildSettingRow(String name, String value) {
    const double fontSize = 18;

    return SettingRow(
      fontSize: fontSize,
      settingName: name,
      settingValue: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Binder'),
      ),
      drawer: BabyBinderDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<ChildData>(
          builder: (_, childData, __) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChildAvatar(
                  imageUrl: childData.activeChild!.image,
                  name: childData.activeChild!.name,
                ),
              ),
              ElevatedButton(
                  onPressed: () => childData.activeChild!.updateName('Testing'),
                  child: Text('Update Name')),
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    _buildSettingRow('setting name', 'values'),
                    _buildSettingRow('setting name 2', 'value 2')
                  ])),
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
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    Key? key,
    required this.fontSize,
    required this.settingName,
    required this.settingValue,
  }) : super(key: key);

  final double fontSize;
  final String settingName;
  final String settingValue;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
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
