import 'package:flutter/material.dart';
import 'package:safe_app/styles/colors.dart';

class PatternLockWidget extends StatefulWidget {
  final int dotCount; // 每行/列的点数，通常为3x3
  final double size; // 整个图案锁的大小
  final Color selectedColor; // 选中点的颜色
  final Color notSelectedColor; // 未选中点的颜色
  final Color errorColor; // 错误状态下的颜色
  final Color errorDotColor; // 错误状态下小圆点的颜色
  final Color selectedBgColor; // 选中状态的背景色
  final Color selectedBorderColor; // 选中状态的边框色
  final double lineWidth; // 连接线的宽度
  final double dotSize; // 点的大小
  final Function(List<int>) onCompleted; // 完成图案绘制的回调
  final bool showInput; // 是否显示输入的图案
  final bool isError; // 是否为错误状态

  const PatternLockWidget({
    Key? key,
    this.dotCount = 3,
    this.size = 300,
    this.selectedColor = Colors.blue,
    this.notSelectedColor = Colors.grey,
    this.errorColor = const Color(0xFFFF3B30),
    this.errorDotColor = const Color(0xFFFF3B30),
    this.selectedBgColor = const Color(0xFFFCEAEA),
    this.selectedBorderColor = const Color(0xFFFFDDDD),
    this.lineWidth = 5,
    this.dotSize = 60,
    required this.onCompleted,
    this.showInput = true,
    this.isError = false,
  }) : super(key: key);

  @override
  State<PatternLockWidget> createState() => _PatternLockWidgetState();
}

class _PatternLockWidgetState extends State<PatternLockWidget> {
  List<int> _pattern = [];
  List<Offset> _points = [];
  Offset? _currentPoint;

  @override
  void initState() {
    super.initState();
    _calculatePoints();
  }

  void _calculatePoints() {
    _points = [];
    final spacing = widget.size / widget.dotCount;
    for (int i = 0; i < widget.dotCount; i++) {
      for (int j = 0; j < widget.dotCount; j++) {
        final x = spacing / 2 + j * spacing;
        final y = spacing / 2 + i * spacing;
        _points.add(Offset(x, y));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onPanStart: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.globalPosition);
          _checkPoint(localPosition);
        },
        onPanUpdate: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(details.globalPosition);
          setState(() {
            _currentPoint = localPosition;
          });
          _checkPoint(localPosition);
        },
        onPanEnd: (details) {
          if (_pattern.isNotEmpty) {
            widget.onCompleted(_pattern);
          }
          setState(() {
            _currentPoint = null;
            if (!widget.showInput) {
              _pattern = [];
            }
          });
        },
        child: CustomPaint(
          painter: _PatternPainter(
            points: _points,
            pattern: _pattern,
            currentPoint: _currentPoint,
            dotSize: widget.dotSize,
            lineWidth: widget.lineWidth,
            selectedColor: widget.isError ? widget.errorColor : widget.selectedColor,
            notSelectedColor: widget.notSelectedColor,
            errorColor: widget.errorColor,
            errorDotColor: widget.errorDotColor,
            selectedBgColor: widget.selectedBgColor,
            selectedBorderColor: widget.selectedBorderColor,
            isError: widget.isError,
          ),
        ),
      ),
    );
  }

  void _checkPoint(Offset localPosition) {
    for (int i = 0; i < _points.length; i++) {
      if (_pattern.contains(i)) continue;
      
      final point = _points[i];
      final dx = point.dx - localPosition.dx;
      final dy = point.dy - localPosition.dy;
      final distance = dx * dx + dy * dy;
      
      if (distance < (widget.dotSize / 2) * (widget.dotSize / 2)) {
        setState(() {
          _pattern.add(i);
        });
        break;
      }
    }
  }
}

class _PatternPainter extends CustomPainter {
  final List<Offset> points;
  final List<int> pattern;
  final Offset? currentPoint;
  final double dotSize;
  final double lineWidth;
  final Color selectedColor;
  final Color notSelectedColor;
  final Color errorColor;
  final Color errorDotColor;
  final Color selectedBgColor;
  final Color selectedBorderColor;
  final bool isError;

  _PatternPainter({
    required this.points,
    required this.pattern,
    this.currentPoint,
    required this.dotSize,
    required this.lineWidth,
    required this.selectedColor,
    required this.notSelectedColor,
    required this.errorColor,
    required this.errorDotColor,
    required this.selectedBgColor,
    required this.selectedBorderColor,
    required this.isError,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制所有点
    for (int i = 0; i < points.length; i++) {
      final bool isSelected = pattern.contains(i);
      
      // 绘制外圈
      final outlinePaint = Paint()
        ..color = isSelected 
          ? (isError ? errorColor : selectedBorderColor)
          : notSelectedColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      // 绘制背景
      final bgPaint = Paint()
        ..color = isSelected 
          ? (isError ? selectedBgColor : selectedBgColor)
          : Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(points[i], dotSize / 2, bgPaint);
      canvas.drawCircle(points[i], dotSize / 2, outlinePaint);
      
      // 如果是错误状态且被选中，绘制小圆点
      if (isError && isSelected) {
        final dotPaint = Paint()
          ..color = errorDotColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(points[i], dotSize / 6, dotPaint);
      }
    }
    
    // 连接选中的点
    if (pattern.isNotEmpty) {
      final linePaint = Paint()
        ..color = isError ? errorColor : selectedColor
        ..strokeWidth = lineWidth
        ..strokeCap = StrokeCap.round;
      
      for (int i = 0; i < pattern.length - 1; i++) {
        canvas.drawLine(points[pattern[i]], points[pattern[i + 1]], linePaint);
      }
      
      // 绘制从最后一个点到当前位置的线
      if (currentPoint != null && pattern.isNotEmpty) {
        canvas.drawLine(points[pattern.last], currentPoint!, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 