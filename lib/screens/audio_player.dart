import 'dart:async';

import 'package:audiotags/audiotags.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:moosic/widgets/player_buttons.dart';

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
  final TextEditingController _controller = TextEditingController();
  bool _sleepTimerActive = false;
  int _sleepTimerDurationMin = 0;

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

  void setSleepTimer(BuildContext context, int minutes) {
    _sleepTimerActive = true;
    Timer(Duration(minutes: minutes), () {
      player.pause();
      setState(() {
        _isPlaying = false;
        _sleepTimerActive = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag?.title ?? "Unknown Title",
                      style: const TextStyle(fontSize: 36),
                    ),
                    Text(
                      tag?.trackArtist ?? "Unknown Artist",
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                _sleepButtonDialog()
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            playerButtons(context, player, _isPlaying, _togglePlayback),
            StreamBuilder<Duration>(
              stream: player.stream.position,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                final position = snapshot.data ?? Duration.zero;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Slider(
                      value: position.inMilliseconds.toDouble(),
                      max: player.state.duration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        // Avoid setting state on every change
                      },
                      onChangeEnd: (value) {
                        player.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        "${formatDuration(position)} / ${formatDuration(player.state.duration)}",
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.repeat),
                ),
                IconButton(
                  onPressed: () {
                    double speed = 1.0;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Text("Speed"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Slider(
                                    value: speed,
                                    min: 0.5,
                                    // minimum speed
                                    max: 2.0,
                                    // maximum speed
                                    divisions: 15,
                                    // number of divisions
                                    label: speed.toStringAsFixed(1),
                                    onChanged: (val) {
                                      setState(() {
                                        speed = val;
                                      });
                                    },
                                    onChangeEnd: (val) {
                                      player.setRate(
                                          val); // Update playback speed
                                    },
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildSpeedButton(0.5),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        _buildSpeedButton(0.75),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        _buildSpeedButton(1.0),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        _buildSpeedButton(1.25),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        _buildSpeedButton(1.5),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        _buildSpeedButton(2.0),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Ok"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.speed),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shuffle),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedButton(double speed) {
    return ElevatedButton(
      onPressed: () {
        player.setRate(speed); // Apply the selected speed
        Navigator.of(context).pop(); // Close the dialog
      },
      child: Text(
        speed.toString(),
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  Widget _sleepButtonDialog() {
    if (_sleepTimerActive) {
      return FilledButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Set Sleep Timer'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                            'Set the sleep timer duration (in minutes):'),
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Enter minutes',
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSleepButton(15),
                              const SizedBox(
                                width: 3,
                              ),
                              _buildSleepButton(30),
                              const SizedBox(
                                width: 3,
                              ),
                              _buildSleepButton(60),
                              const SizedBox(
                                width: 3,
                              ),
                              _buildSleepButton(120),
                              const SizedBox(
                                width: 3,
                              ),
                              _buildSleepButton(150),
                            ],
                          ),
                        )
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          int selectedTime =
                              int.tryParse(_controller.text) ?? 0;
                          if (selectedTime > 0) {
                            setState(() {
                              _sleepTimerDurationMin = selectedTime;
                            });
                            setSleepTimer(context, selectedTime);
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('Set Timer'),
                      ),
                    ],
                  );
                });
          },
          child: Row(
            children: [
              Text(formatDuration(Duration(minutes: _sleepTimerDurationMin))),
              const Icon(Icons.mode_night)
            ],
          ));
    } else {
      return IconButton.filled(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Set Sleep Timer'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                            'Set the sleep timer duration (in minutes):'),
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Enter minutes',
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSleepButton(15),
                              const SizedBox(
                                width: 3,
                              ),
                              _buildSleepButton(30),
                              const SizedBox(
                                width: 3,
                              ),
                              _buildSleepButton(60),
                              const SizedBox(
                                width: 3,
                              ),
                              _buildSleepButton(120),
                              const SizedBox(
                                width: 3,
                              ),
                              _buildSleepButton(150),
                            ],
                          ),
                        )
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          int selectedTime =
                              int.tryParse(_controller.text) ?? 0;
                          if (selectedTime > 0) {
                            setSleepTimer(context, selectedTime);
                          }
                          Navigator.of(context).pop();
                        },
                        child: const Text('Set Timer'),
                      ),
                    ],
                  );
                });
          },
          icon: const Icon(Icons.mode_night));
    }
  }

  Widget _buildSleepButton(int mins) {
    return ElevatedButton(
      onPressed: () {
        _controller.text = mins.toString();
      },
      child: Text(
        mins.toString(),
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      if (_isPlaying) {
        player.pause();
      } else {
        player.play();
      }
      _isPlaying = !_isPlaying;
    });
  }
}
