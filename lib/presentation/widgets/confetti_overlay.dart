import 'dart:math';

import 'package:flutter/material.dart';

/// A widget that displays a confetti animation
class ConfettiOverlay extends StatefulWidget {
  /// Whether the confetti is active
  final bool isActive;

  /// Constructor
  const ConfettiOverlay({super.key, required this.isActive});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Confetti> _confetti;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        if (widget.isActive) {
          _createConfetti();
          _controller.forward();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _createConfetti();

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _createConfetti();
      _controller.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reset();
    }
  }

  void _createConfetti() {
    final size = MediaQuery.sizeOf(context);
    _confetti = List.generate(
      100,
      (index) => Confetti(
        color: _getRandomColor(),
        position: Offset(
          _random.nextDouble() * size.width,
          -50 - _random.nextDouble() * 300,
        ),
        size: 10 + _random.nextDouble() * 10,
        velocity: Offset(
          -2 + _random.nextDouble() * 4,
          3 + _random.nextDouble() * 2,
        ),
        rotationSpeed: _random.nextDouble() * 0.1,
      ),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var i = 0; i < _confetti.length; i++) {
          _confetti[i].update(_controller.value);
        }

        return CustomPaint(
          painter: ConfettiPainter(confetti: _confetti),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

/// A class representing a single confetti particle
class Confetti {
  /// The color of the confetti
  Color color;

  /// The position of the confetti
  Offset position;

  /// The size of the confetti
  double size;

  /// The velocity of the confetti
  Offset velocity;

  /// The rotation angle of the confetti
  double rotation = 0;

  /// The rotation speed of the confetti
  double rotationSpeed;

  /// Constructor
  Confetti({
    required this.color,
    required this.position,
    required this.size,
    required this.velocity,
    required this.rotationSpeed,
  });

  /// Update the confetti position based on the animation value
  void update(double animationValue) {
    position += velocity * 10;
    rotation += rotationSpeed;
  }
}

/// A custom painter that draws confetti particles
class ConfettiPainter extends CustomPainter {
  /// The list of confetti particles to draw
  final List<Confetti> confetti;

  /// Constructor
  ConfettiPainter({required this.confetti});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in confetti) {
      if (particle.position.dy < size.height) {
        canvas.save();
        canvas.translate(particle.position.dx, particle.position.dy);
        canvas.rotate(particle.rotation);

        final paint = Paint()..color = particle.color;
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
