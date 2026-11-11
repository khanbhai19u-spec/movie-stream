import 'package:flutter/material.dart';

import '../theme.dart';

/// Flixora logo mark + gradient wordmark.
class FlixoraLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const FlixoraLogo({super.key, this.size = 32, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/logo.png', width: size, height: size),
        if (showWordmark) ...[
          SizedBox(width: size * 0.28),
          ShaderMask(
            shaderCallback: (r) => FX.gradient.createShader(r),
            child: Text(
              'Flixora',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.78,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
