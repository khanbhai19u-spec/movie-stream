import 'package:flutter/material.dart';

import '../models.dart';
import '../screens/detail_screen.dart';
import '../theme.dart';
import 'net_image.dart';

class RatingPill extends StatelessWidget {
  final String rating;

  const RatingPill(this.rating, {super.key});

  @override
  Widget build(BuildContext context) {
    if (rating.isEmpty || rating == '0' || rating == '0.0') {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: FX.star),
          const SizedBox(width: 3),
          Text(rating,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class PosterCard extends StatelessWidget {
  final MediaItem item;
  final double width;
  final int? rank;

  const PosterCard({super.key, required this.item, this.width = 128, this.rank});

  void _open(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(item.cover.isNotEmpty ? item.cover : item.backdrop,
                      radius: BorderRadius.circular(16)),
                  Positioned(
                      top: 8, right: 8, child: RatingPill(item.rating)),
                  if (rank != null)
                    Positioned(
                      left: 8,
                      bottom: 4,
                      child: ShaderMask(
                        shaderCallback: (r) => FX.gradient.createShader(r),
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 12, color: Colors.black)],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              [item.year, if (item.isSeries) 'Series'].where((e) => e.isNotEmpty).join(' · '),
              style: const TextStyle(fontSize: 11, color: FX.textDim),
            ),
          ],
        ),
      ),
    );
  }
}
