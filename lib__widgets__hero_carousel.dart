import 'dart:async';

import 'package:flutter/material.dart';

import '../models.dart';
import '../screens/detail_screen.dart';
import '../theme.dart';
import 'net_image.dart';

class HeroCarousel extends StatefulWidget {
  final List<MediaItem> items;

  const HeroCarousel({super.key, required this.items});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_controller.hasClients || widget.items.length < 2) return;
      final next = (_index + 1) % widget.items.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.52;
    return SizedBox(
      height: height.clamp(380.0, 560.0).toDouble(),
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _HeroSlide(item: widget.items[i]),
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.items.length, (i) {
                final on = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: on ? 22 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: on ? FX.gradient : null,
                    color: on ? null : Colors.white24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  final MediaItem item;

  const _HeroSlide({required this.item});

  @override
  Widget build(BuildContext context) {
    void open() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
        );

    final meta = [
      if (item.year.isNotEmpty) item.year,
      if (item.durationLabel.isNotEmpty) item.durationLabel,
      if (item.genres.isNotEmpty) item.genres.take(2).join(' / '),
    ].join('  ·  ');

    return GestureDetector(
      onTap: open,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(item.wideImage),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35, 0.75, 1.0],
                colors: [
                  Color(0xCC070B14),
                  Color(0x00070B14),
                  Color(0xB3070B14),
                  FX.bg,
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(meta,
                    style: const TextStyle(fontSize: 13, color: FX.textDim)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _GradientButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Watch',
                      onTap: open,
                    ),
                    const SizedBox(width: 10),
                    _GlassButton(
                      icon: Icons.info_outline_rounded,
                      label: 'Details',
                      onTap: open,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GradientButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: FX.gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: FX.blue.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GlassButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
