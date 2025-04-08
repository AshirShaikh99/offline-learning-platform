import 'package:flutter/material.dart';

import '../../domain/entities/match_connection.dart';

/// A custom painter that draws connection lines between matching items
class ConnectionPainter extends CustomPainter {
  /// The list of connections to draw
  final List<MatchConnection> connections;

  /// Whether a drag is in progress
  final bool isDragging;

  /// The start point of the current drag
  final Offset? dragStart;

  /// The end point of the current drag
  final Offset? dragEnd;

  /// Constructor
  ConnectionPainter({
    required this.connections,
    this.isDragging = false,
    this.dragStart,
    this.dragEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all existing connections
    for (final connection in connections) {
      final paint =
          Paint()
            ..color =
                connection.isCorrect
                    ? Colors.green.shade600
                    : Colors.red.shade600
            ..strokeWidth = 5.0
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

      // Draw a curved line
      final path = Path();
      path.moveTo(connection.startPoint.dx, connection.startPoint.dy);

      // Calculate control points for a bezier curve
      final controlPoint1 = Offset(
        connection.startPoint.dx +
            (connection.endPoint.dx - connection.startPoint.dx) / 2,
        connection.startPoint.dy,
      );
      final controlPoint2 = Offset(
        connection.startPoint.dx +
            (connection.endPoint.dx - connection.startPoint.dx) / 2,
        connection.endPoint.dy,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        connection.endPoint.dx,
        connection.endPoint.dy,
      );

      canvas.drawPath(path, paint);

      // Draw dots at the start and end points with a larger size
      canvas.drawCircle(
        connection.startPoint,
        8.0,
        Paint()
          ..color =
              connection.isCorrect
                  ? Colors.green.shade600
                  : Colors.red.shade600,
      );
      canvas.drawCircle(
        connection.endPoint,
        8.0,
        Paint()
          ..color =
              connection.isCorrect
                  ? Colors.green.shade600
                  : Colors.red.shade600,
      );
    }

    // Draw the current drag line if dragging
    if (isDragging && dragStart != null && dragEnd != null) {
      final paint =
          Paint()
            ..color = Colors.blue.shade500
            ..strokeWidth = 5.0
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

      // Draw a curved line
      final path = Path();
      path.moveTo(dragStart!.dx, dragStart!.dy);

      // Calculate control points for a bezier curve
      final controlPoint1 = Offset(
        dragStart!.dx + (dragEnd!.dx - dragStart!.dx) / 2,
        dragStart!.dy,
      );
      final controlPoint2 = Offset(
        dragStart!.dx + (dragEnd!.dx - dragStart!.dx) / 2,
        dragEnd!.dy,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        dragEnd!.dx,
        dragEnd!.dy,
      );

      canvas.drawPath(path, paint);

      // Draw dots at the start and end points with a larger size and glow effect
      // Draw glow effect
      canvas.drawCircle(
        dragStart!,
        12.0,
        Paint()..color = const Color.fromRGBO(33, 150, 243, 0.3),
      );
      canvas.drawCircle(
        dragEnd!,
        12.0,
        Paint()..color = const Color.fromRGBO(33, 150, 243, 0.3),
      );

      // Draw the actual dots
      canvas.drawCircle(dragStart!, 8.0, Paint()..color = Colors.blue.shade500);
      canvas.drawCircle(dragEnd!, 8.0, Paint()..color = Colors.blue.shade500);
    }
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return oldDelegate.connections != connections ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.dragStart != dragStart ||
        oldDelegate.dragEnd != dragEnd;
  }
}
