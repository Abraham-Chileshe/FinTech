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
          final isMini = widget.size < 50;
          final extraBox = isMini ? 12.0 : 80.0;
          final extraContainer = isMini ? 6.0 : 60.0;
          final blur1 = isMini ? 6.0 * glowVal : 45.0 * glowVal;
          final spread1 = isMini ? 1.0 * glowVal : 10.0 * glowVal;
          final blur2 = isMini ? 10.0 * glowVal : 70.0 * glowVal;
          final spread2 = isMini ? 2.0 * glowVal : 15.0 * glowVal;

          return SizedBox(
            width: currentSize + extraBox,
            height: currentSize + extraBox,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ambient aura glow (Emerald Green & Neon Mint)
                Container(
                  width: currentSize + extraContainer,
                  height: currentSize + extraContainer,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.35 * glowVal),
                        blurRadius: blur1,
                        spreadRadius: spread1,
                      ),
                      BoxShadow(
                        color: const Color(0xFF34D399).withValues(alpha: 0.25 * glowVal),
                        blurRadius: blur2,
                        spreadRadius: spread2,
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
                        color: const Color(0xFF00E676).withValues(alpha: 0.45 * (1 - _controller.value)),
                        width: 2,
                      ),
                    ),
                  ),

                // The 3D Sphere Orb in Fintech Emerald & Electric Mint
                Container(
                  width: currentSize,
                  height: currentSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      center: Alignment(-0.25, -0.3),
                      radius: 0.85,
                      colors: [
                        Color(0xFFE8FFF3), // Specular white-mint core highlight
                        Color(0xFF69F0AE), // Bright mint glow
                        Color(0xFF00E676), // Vivid neon emerald
                        Color(0xFF00C853), // Signature Fintech Green
                        Color(0xFF0B6623), // Rich pine mid-tone
                        Color(0xFF042B14), // Deep forest rim depth
                      ],
                      stops: [0.0, 0.22, 0.46, 0.70, 0.88, 1.0],
                    ),
                    boxShadow: [
                      // Inner rim highlight
                      BoxShadow(
                        color: const Color(0xFF00FF88).withValues(alpha: 0.8),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                      // Soft Emerald Green outer glow
                      BoxShadow(
                        color: const Color(0xFF00C853).withValues(alpha: 0.55),
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
