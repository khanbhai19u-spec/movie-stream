import 'package:flutter/material.dart';

import '../theme.dart';

class NetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final BorderRadius? radius;

  const NetImage(this.url, {super.key, this.fit = BoxFit.cover, this.radius});

  Widget get _placeholder => Container(
        color: FX.surfaceHi,
        alignment: Alignment.center,
        child: const Icon(Icons.movie_outlined, color: FX.textDim, size: 28),
      );

  @override
  Widget build(BuildContext context) {
    final child = url.isEmpty
        ? _placeholder
        : Image.network(
            url,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _placeholder,
            frameBuilder: (context, child, frame, sync) => sync
                ? child
                : AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 350),
                    child: child,
                  ),
          );
    return radius == null
        ? ColoredBox(color: FX.surfaceHi, child: child)
        : ClipRRect(
            borderRadius: radius!,
            child: ColoredBox(color: FX.surfaceHi, child: child),
          );
  }
}
