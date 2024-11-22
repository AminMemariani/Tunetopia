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
          child: Row(
            children: [
              Container(
                width: 15,
                height: 80,
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
                    color: Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
              ),
              Text(
                items[index],
                style: MyStyles.appTextStyle,
              ),
            ],
          ),
        );
      },
    );
  }
}
