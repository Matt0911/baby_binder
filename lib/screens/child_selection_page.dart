import 'package:baby_binder/providers/children_data.dart';
import 'package:baby_binder/widgets/baby_binder_drawer.dart';
import 'package:baby_binder/widgets/child_card.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChildSelectionPage extends ConsumerWidget {
  static const String routeName = '/child-selection-page';

  const ChildSelectionPage({super.key});

  Future<void> _showAddChildDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Child'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Child\'s name',
            label: Text('Name'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _createChild(nameController.text, ref);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createChild(String name, WidgetRef ref) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final firestore = FirebaseFirestore.instance;

      // Create new child document
      final newChildRef = await firestore.collection('children').add({
        'name': name,
        'image': 'assets/icons/default_child.png',
      });

      // Add child ID to user's children list
      await firestore.collection('users').doc(user.uid).update({
        'children': FieldValue.arrayUnion([newChildRef.id]),
      });

      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Added $name!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Error adding child: $e')),
      );
    }
  }

  @override
  Widget build(context, ref) {
    final children = ref.watch(childrenListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children'),
      ),
      drawer: const BabyBinderDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: children.isEmpty
                  ? const Center(
                      child: Text(
                          'No children yet. Tap "Add Child" to get started!'),
                    )
                  : CarouselSlider(
                      options: CarouselOptions(
                        aspectRatio: 3 / 4,
                        enableInfiniteScroll: false,
                      ),
                      items: children.map((child) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: ChildCard(
                                childData: child,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: () => _showAddChildDialog(context, ref),
                label: const Text('Add Child'),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
