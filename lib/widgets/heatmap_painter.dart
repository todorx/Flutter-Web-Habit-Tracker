import 'package:flutter/material.dart';

class HeatmapPainter extends CustomPainter {
  final Set<String> completedDates;
  final Color activeColor;
  final Color inactiveColor;
  final Function(String date)? onTap;
  String? hoveredDate;
  Offset? hoverPosition;

  HeatmapPainter({
    required this.completedDates,
    required this.activeColor,
    required this.inactiveColor,
    this.onTap,
    this.hoveredDate,
    this.hoverPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = (size.width - (52 * 4)) / 53;
    final cellHeight = (size.height - (6 * 4)) / 7;
    final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;
    final padding = 4.0;

    final paint = Paint()..style = PaintingStyle.fill;
    
    final now = DateTime.now();
    // Offset so today is at the very bottom right if possible, 
    // or just walk back 365 days and fill a 53x7 grid.
    
    // Day 0 is today. We want it at col 52, row = now.weekday - 1 (Monday=0, Sunday=6)
    int currentWeekday = now.weekday - 1; // 0=Mon, 6=Sun
    
    for (int i = 0; i < 365; i++) {
      final d = now.subtract(Duration(days: i));
      final dStr = d.toIso8601String().split('T')[0];
      
      // calculate position
      int totalDaysFromEnd = i;
      int colIndex = 52 - ((totalDaysFromEnd + (6 - currentWeekday)) ~/ 7);
      int rowIndex = (currentWeekday - (totalDaysFromEnd % 7)) % 7;
      if (rowIndex < 0) rowIndex += 7;

      if (colIndex < 0) continue; // Out of bounds for 53 weeks

      final x = colIndex * (cellSize + padding);
      final y = rowIndex * (cellSize + padding);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, cellSize, cellSize),
        const Radius.circular(4.0),
      );

      if (completedDates.contains(dStr)) {
        paint.color = activeColor;
      } else {
        paint.color = inactiveColor;
      }

      canvas.drawRRect(rect, paint);
      
      // Draw hover tooltip pseudo-logic (just border if hovered)
      if (hoveredDate == dStr) {
        final borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white
          ..strokeWidth = 2.0;
        canvas.drawRRect(rect, borderPaint);
      }
    }
  }

  @override
  bool hitTest(Offset position) {
    // Gestures are handled by GestureDetector wrapping CustomPaint
    return true; 
  }

  @override
  bool shouldRepaint(covariant HeatmapPainter oldDelegate) {
    return true;
  }
}
