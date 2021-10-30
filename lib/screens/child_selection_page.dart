import 'package:baby_binder/models/child_data.dart';
import 'package:baby_binder/widgets/baby_binder_drawer.dart';
import 'package:baby_binder/widgets/child_avatar.dart';
import 'package:baby_binder/widgets/child_card.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

class ChildSelectionPage extends StatelessWidget {
  static final String routeName = '/child-selection-page';

  const ChildSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children'),
      ),
      drawer: BabyBinderDrawer(),
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 3 / 4,
                  enableInfiniteScroll: false,
                ),
                items: children.keys.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: ChildCard(
                          childData: ChildData(id: i),
                        ),
                      );
                    },
                  );
                }).toList()),
          ),
          Center(
            child: TextButton.icon(
                onPressed: () => print('pressed button'),
                label: Text('Add Child'),
                icon: Icon(Icons.add)),
          )
        ],
      ),
    );
  }
}
