import 'package:baby_binder/providers/app_state.dart';
import 'package:baby_binder/providers/children_data.dart';
import 'package:baby_binder/screens/child_settings_page.dart';
import 'package:baby_binder/screens/child_story_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'child_avatar.dart';

class ChildCard extends ConsumerWidget {
  const ChildCard({super.key, required this.childData});
  final Child childData;

  @override
  Widget build(context, ref) {
    final setActiveChild = ref.watch(childrenDataProvider).setActiveChild;
    final appState = ref.watch(appStateProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ChildAvatar(
                childImage: childData.image,
                childName: childData.name,
                maxRadius: MediaQuery.of(context).size.width / 3,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setActiveChild(id: childData.id);
                appState.navigateToPage(context, ChildStoryPage.routeName);
              },
              child: const Text('View Story'),
            ),
            OutlinedButton(
              onPressed: () {
                setActiveChild(id: childData.id);
                appState.navigateToPage(context, ChildSettingsPage.routeName);
              },
              child: const Text('Settings'),
            )
          ],
        ),
      ),
    );
  }
}
