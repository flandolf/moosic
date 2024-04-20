import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String filePath;

  const AudioPlayerScreen({super.key, required this.filePath});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  bool _isPlaying = false;
  late final player = Player();
  Tag? tag;

  @override
  void initState() {
    super.initState();
    begin();
  }

  void begin() async {
    tag = await AudioTags.read(widget.filePath);
    setState(() {
      _isPlaying = true;
    });
    player.open(Media("file://${widget.filePath}"));
    player.play();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours != "00") {
      return "$hours:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 32,
            ),
            if (tag!.pictures.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: Image(
                  image: MemoryImage(tag!.pictures[0].bytes),
                ),
              ),
            const SizedBox(
              height: 8,
            ),
            Text(
              tag?.title ?? "Unknown Title",
              style: const TextStyle(fontSize: 36),
            ),
            Text(
              tag?.trackArtist ?? "Unknown Artist",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton.filledTonal(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_previous, size: 42)),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton.filled(
                      onPressed: () {
                        setState(() {
                          if (_isPlaying) {
                            player.pause();
                          } else {
                            player.play();
                          }
                          _isPlaying = !_isPlaying;
                        });
                      },
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 56)),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton.filledTonal(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_next, size: 42)),
                ),
              ],
            ),
            StreamBuilder(
                stream: player.stream.position,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }

                  Duration position = snapshot.data ?? Duration.zero;

                  position = Duration(
                      milliseconds: position.inMilliseconds
                          .clamp(0, player.state.duration.inMilliseconds));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Slider(
                        value: position.inMilliseconds.toDouble(),
                        max: player.state.duration.inMilliseconds.toDouble(),
                        onChanged: (value) {},
                        onChangeEnd: (value) {
                          player.seek(Duration(milliseconds: value.toInt()));
                          setState(() {});
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                            "${formatDuration(position)} / ${formatDuration(player.state.duration)}"),
                      )
                    ],
                  );
                })
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
