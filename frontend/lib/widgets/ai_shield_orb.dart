import 'dart:math' as math;
import 'package:flutter/material.dart';

class AiShieldOrb extends StatefulWidget {
  final double size;
  final bool isAnalyzing;
  final VoidCallback? onTap;

  const AiShieldOrb({
    super.key,
    this.size = 140,
    this.isAnalyzing = false,
    this.onTap,
  });

  @override
  State<AiShieldOrb> createState() => _AiShieldOrbState();
}

class _AiShieldOrbState extends State<AiShieldOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse = widget.isAnalyzing ? 1.0 + 0.08 * math.sin(_controller.value * math.pi * 4) : _pulseAnimation.value;
          final glowVal = _glowAnimation.value;
          final currentSize = widget.size * pulse;

          return SizedBox(
            width: currentSize + 80,
            height: currentSize + 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ambient aura glow (Absa Red & Sunset Coral)
                Container(
                  width: currentSize + 60,
                  height: currentSize + 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC0032).withValues(alpha: 0.3 * glowVal),
                        blurRadius: 45 * glowVal,
                        spreadRadius: 10 * glowVal,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF385C).withValues(alpha: 0.22 * glowVal),
                        blurRadius: 70 * glowVal,
                        spreadRadius: 15 * glowVal,
                      ),
                    ],
                  ),
                ),

                // Ripple rings if analyzing or idle pulse
                if (widget.isAnalyzing)
                  Container(
                    width: currentSize + 40,
                    height: currentSize + 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFDC0032).withValues(alpha: 0.45 * (1 - _controller.value)),
                        width: 2,
                      ),
                    ),
                  ),

                // The 3D Sphere Orb in Absa Ruby & Passionate Red
                Container(
                  width: currentSize,
                  height: currentSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.25, -0.3),
                      radius: 0.85,
                      colors: [
                        Color(0xFFFFF0F2), // Specular white-rose core highlight
                        Color(0xFFFF6B85), // Warm coral-pink
                        Color(0xFFFF1744), // Vivid Absa neon crimson
                        Color(0xFFDC0032), // Signature Absa Passion Red
                        Color(0xFF9E0024), // Rich imperial burgundy mid-tone
                        Color(0xFF4A0010), // Deep wine rim depth
                      ],
                      stops: [0.0, 0.22, 0.46, 0.70, 0.88, 1.0],
                    ),
                    boxShadow: [
                      // Inner rim highlight
                      BoxShadow(
                        color: const Color(0xFFFF4066).withValues(alpha: 0.8),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                      // Soft Absa Red outer glow
                      BoxShadow(
                        color: const Color(0xFFDC0032).withValues(alpha: 0.55),
                        blurRadius: 40,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),

                // Specular reflection glint on top-left
                Positioned(
                  top: currentSize * 0.22,
                  left: currentSize * 0.24,
                  child: Container(
                    width: currentSize * 0.22,
                    height: currentSize * 0.16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
