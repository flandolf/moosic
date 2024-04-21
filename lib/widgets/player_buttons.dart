import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
Widget playerButtons(BuildContext context, Player player, bool isPlaying, VoidCallback togglePlayback) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton.filledTonal(
            onPressed: () {
              player.previous();
            },
            icon: const Icon(Icons.skip_previous, size: 42)),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.05,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton.filled(
            onPressed: togglePlayback,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                size: 64)),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.05,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton.filledTonal(
            onPressed: () {},
            icon: const Icon(Icons.skip_next, size: 42)),
      ),
    ],
  );
}
