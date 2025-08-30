import 'package:flutter/material.dart';
import 'package:music_player/constants/style.dart';
import 'package:music_player/providers/songs.dart';
import 'package:music_player/utils/duration_formatter.dart';
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
            onTap: () => Navigator.pushNamed(context, "songs",
                arguments: snapshot.songs[index]),
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
                        blurRadius: 0,
                        offset: const Offset(0.5, 0.5),
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.secondary,
                        spreadRadius: 3,
                        blurRadius: 0,
                        offset: const Offset(-0.5, -0.5),
                      ),
                    ],
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${index + 1}- ${snapshot.songs[index].songName}",
                        style: MyStyles.appTextStyle,
                      ),
                      snapshot.songs[index].duration != null
                          ? Text(
                              DurationFormatter.formatDuration(
                                  snapshot.songs[index].duration),
                              style: MyStyles.appTextStyle,
                            )
                          : const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
