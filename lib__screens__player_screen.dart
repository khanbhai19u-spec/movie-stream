import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../models.dart';
import '../theme.dart';

class PlayerScreen extends StatefulWidget {
  final String title;
  final StreamLink link;

  const PlayerScreen({super.key, required this.title, required this.link});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final VideoPlayerController _controller;
  bool _showControls = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.link.url),
      httpHeaders: widget.link.headers,
    )..addListener(() {
        if (mounted) setState(() {});
      });

    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.play();
      setState(() {});
    }).catchError((Object e) {
      if (mounted) setState(() => _error = '$e');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final v = _controller.value;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: _error != null
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Playback failed (${widget.link.kind.toUpperCase()}).\n$_error',
                        textAlign: TextAlign.center,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: FX.textDim),
                      ),
                    )
                  : v.isInitialized
                      ? AspectRatio(
                          aspectRatio: v.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : const CircularProgressIndicator(color: FX.cyan),
            ),
            if (v.isBuffering && v.isInitialized)
              const Center(child: CircularProgressIndicator(color: FX.cyan)),
            AnimatedOpacity(
              opacity: _showControls ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: _controls(v),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls(VideoPlayerValue v) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC000000), Colors.transparent, Color(0xCC000000)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (v.isInitialized)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.replay_10_rounded),
                    onPressed: () => _controller
                        .seekTo(v.position - const Duration(seconds: 10)),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    iconSize: 64,
                    icon: Icon(v.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded),
                    onPressed: () =>
                        v.isPlaying ? _controller.pause() : _controller.play(),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.forward_10_rounded),
                    onPressed: () => _controller
                        .seekTo(v.position + const Duration(seconds: 10)),
                  ),
                ],
              ),
            const Spacer(),
            if (v.isInitialized)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(_fmt(v.position),
                        style: const TextStyle(fontSize: 12, color: FX.textDim)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: FX.cyan,
                          thumbColor: FX.cyan,
                          inactiveTrackColor: Colors.white24,
                          trackHeight: 3,
                        ),
                        child: Slider(
                          min: 0,
                          max: v.duration.inMilliseconds < 1
                              ? 1.0
                              : v.duration.inMilliseconds.toDouble(),
                          value: v.position.inMilliseconds
                              .clamp(0, v.duration.inMilliseconds < 1 ? 1 : v.duration.inMilliseconds)
                              .toDouble(),
                          onChanged: (x) => _controller
                              .seekTo(Duration(milliseconds: x.toInt())),
                        ),
                      ),
                    ),
                    Text(_fmt(v.duration),
                        style: const TextStyle(fontSize: 12, color: FX.textDim)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
