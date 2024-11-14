import 'package:flutter/material.dart';

class HomeItem extends StatelessWidget {
  HomeItem({super.key});
  final List<String> items = ["1", "2", "3"];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            alignment: Alignment.centerLeft,
            height: 100,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade600,
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0.5, 0.5),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    spreadRadius: 7,
                    blurRadius: 3,
                    offset: Offset(-0.5, -0.5),
                  ),
                ],
                color: Color.fromARGB(255, 245, 245, 245),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                const SizedBox(width: 20),
                Text(items[index]),
              ],
            ),
          ),
        );
      },
    );
  }
}
