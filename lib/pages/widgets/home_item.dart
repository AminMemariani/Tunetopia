import 'package:flutter/material.dart';
import 'package:music_player/constants/style.dart';

class HomeItem extends StatelessWidget {
  HomeItem({super.key});
  final List<String> items = ["11111", "222222", "3333333"];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, "songs"),
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
            child: Container(
              alignment: Alignment.centerLeft,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 12),
              height: 50,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.secondary,
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0.5, 0.5),
                    ),
                    BoxShadow(
                      color: Theme.of(context).colorScheme.secondary,
                      spreadRadius: 7,
                      blurRadius: 3,
                      offset: const Offset(-0.5, -0.5),
                    ),
                  ],
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Text(
                "${index + 1}- ${items[index]}",
                style: MyStyles.appTextStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}
