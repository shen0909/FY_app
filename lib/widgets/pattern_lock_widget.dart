import 'package:flutter/material.dart';
import 'package:safe_app/styles/colors.dart';

class PatternLockWidget extends StatefulWidget {
  final int dotCount; // 每行/列的点数，通常为3x3
  final double size; // 整个图案锁的大小
  final Color selectedColor; // 选中点的颜色
  final Color notSelectedColor; // 未选中点的颜色
  final Color errorColor; // 错误状态下的颜色
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
    this.errorColor = Colors.red,
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
  bool _isLayoutReady = false;

  @override
  void initState() {
    super.initState();
    // 不在initState中计算点位置，改为在布局完成后计算
  }

  void _calculatePoints() {
    if (!_isLayoutReady) return;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        // 使用LayoutBuilder确保在布局完成后计算点的位置
        final actualSize = constraints.maxWidth < widget.size
            ? constraints.maxWidth
            : widget.size;

        // 确保布局准备好后计算点的位置
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isLayoutReady || _points.isEmpty) {
            setState(() {
              _isLayoutReady = true;
              _points = [];
              final spacing = actualSize / widget.dotCount;
              for (int i = 0; i < widget.dotCount; i++) {
                for (int j = 0; j < widget.dotCount; j++) {
                  final x = spacing / 2 + j * spacing;
                  final y = spacing / 2 + i * spacing;
                  _points.add(Offset(x, y));
                }
              }
            });
          }
        });

        return SizedBox(
          width: actualSize,
          height: actualSize,
          child: GestureDetector(
            onPanStart: (details) {
              if (!_isLayoutReady || _points.isEmpty) return;

              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              _pattern = []; // 清空之前的图案
              _checkPoint(localPosition);
            },
            onPanUpdate: (details) {
              if (!_isLayoutReady || _points.isEmpty) return;

              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              setState(() {
                _currentPoint = localPosition;
              });
              _checkPoint(localPosition);
            },
            onPanEnd: (details) {
              if (!_isLayoutReady || _points.isEmpty) return;

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
                selectedColor: widget.selectedColor,
                notSelectedColor: widget.notSelectedColor,
                errorColor: widget.errorColor,
                isError: _pattern.isEmpty && widget.isError,
              ),
            ),
          ),
        );
      },
    );
  }

  void _checkPoint(Offset localPosition) {
    for (int i = 0; i < _points.length; i++) {
      // 移除跳过已选择点的限制，允许连接已经选中的点
      // if (_pattern.contains(i)) continue;
      
      final point = _points[i];
      final dx = point.dx - localPosition.dx;
      final dy = point.dy - localPosition.dy;
      final distance = dx * dx + dy * dy;
      
      if (distance < (widget.dotSize / 2) * (widget.dotSize / 2)) {
        // 如果该点已经在图案中，不重复添加
        if (_pattern.contains(i)) continue;
        
        // 如果存在上一个点，检查两点之间是否有需要自动连接的中间点
        if (_pattern.isNotEmpty) {
          _connectMiddlePoints(_pattern.last, i);
        }
        
        setState(() {
          _pattern.add(i);
        });
        break;
      }
    }
  }

  // 连接两点间的中间点
  void _connectMiddlePoints(int lastPoint, int currentPoint) {
    // 获取两点坐标
    final lastRow = lastPoint ~/ widget.dotCount;
    final lastCol = lastPoint % widget.dotCount;
    final currentRow = currentPoint ~/ widget.dotCount;
    final currentCol = currentPoint % widget.dotCount;
    
    // 计算行列差
    final rowDiff = currentRow - lastRow;
    final colDiff = currentCol - lastCol;
    
    // 检查是否在同一行、同一列或对角线上，且中间有点
    if ((rowDiff.abs() == 2 && colDiff.abs() == 0) || // 同列，间隔1行
        (rowDiff.abs() == 0 && colDiff.abs() == 2) || // 同行，间隔1列
        (rowDiff.abs() == 2 && colDiff.abs() == 2) || // 对角线，间隔都是1
        (rowDiff.abs() == 1 && colDiff.abs() == 2) || // 棋盘L型
        (rowDiff.abs() == 2 && colDiff.abs() == 1)) {
      // 棋盘L型

      // 计算中间点的索引
      int middleRow = lastRow + rowDiff ~/ 2;
      int middleCol = lastCol + colDiff ~/ 2;
      int middlePoint = middleRow * widget.dotCount + middleCol;
      
      // 如果中间点不在图案中，添加到图案
      if (!_pattern.contains(middlePoint)) {
        _pattern.add(middlePoint);
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
    required this.isError,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制所有点
    for (int i = 0; i < points.length; i++) {
      final bool isSelected = pattern.contains(i);
      final Color dotColor = isSelected
          ? (isError ? errorColor : selectedColor)
          : notSelectedColor;
      
      // 使用#D8D8D8作为选中圆圈的背景色
      final Color dotFillColor =
          isSelected ? FYColors.color_D8D8D8 : Colors.white;

      // 使用#E0E0E0作为选中圆圈的边框颜色
      final Color borderColor = isSelected ? FYColors.color_E0E0E0 : dotColor;

      // 绘制填充
      final fillPaint = Paint()
        ..color = dotFillColor
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(points[i], dotSize / 2, fillPaint);
      
      // 绘制边框
      final outlinePaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawCircle(points[i], dotSize / 2, outlinePaint);
      
      // 如果是选中状态，绘制内部小圆点
      if (isSelected) {
        final centerDotPaint = Paint()
          ..color = isError ? errorColor : selectedColor
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(points[i], dotSize / 6, centerDotPaint);
      }
    }
    
    // 连接选中的点
    if (pattern.isNotEmpty) {
      // 根据是否为错误状态决定连接线颜色
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