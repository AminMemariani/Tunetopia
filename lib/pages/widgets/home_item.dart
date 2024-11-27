import 'package:flutter/material.dart';
import 'package:music_player/constants/style.dart';
import 'package:music_player/providers/songs.dart';
import 'package:provider/provider.dart';

class HomeItem extends StatelessWidget {
  const HomeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Songs>(builder: (context, snapshot, _) {
      return ListView.builder(
        itemCount: snapshot.songs.length,
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
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0.5, 0.5),
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.secondary,
                        spreadRadius: 5,
                        blurRadius: 2,
                        offset: const Offset(-0.5, -0.5),
                      ),
                    ],
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Text(
                  "${index + 1}- ${snapshot.songs[index]?.songName}",
                  style: MyStyles.appTextStyle,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
