import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import 'poster_card.dart';

class SectionRow extends StatelessWidget {
  final HomeSection section;

  const SectionRow({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final items = section.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: FX.gradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 128 * 1.5 + 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => PosterCard(
              item: items[i],
              rank: section.ranked ? i + 1 : null,
            ),
          ),
        ),
      ],
    );
  }
}
