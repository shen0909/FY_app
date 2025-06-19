// DynamicScrollbarWrapper.dart
import 'package:flutter/material.dart';

class DynamicScrollbarWrapper extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;
  final Axis scrollDirection;
  // 新增参数：当滚动方向为水平时，需要提供整个内容的实际宽度
  final double? overallContentExtent;

  const DynamicScrollbarWrapper({
    Key? key,
    required this.scrollController,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.overallContentExtent, // 仅当 scrollDirection 为 Axis.horizontal 且包裹整个容器时使用
  }) : super(key: key);

  @override
  State<DynamicScrollbarWrapper> createState() =>
      _DynamicScrollbarWrapperState();
}

class _DynamicScrollbarWrapperState extends State<DynamicScrollbarWrapper> {
  double _scrollPosition = 0.0;
  double _calculatedContentExtent = 0.0; // 内部计算或外部传入的内容总长度
  double _calculatedViewportExtent = 0.0; // 内部计算的视口总长度
  final double _thumbSize = 32.0;
  final double _trackThickness = 4.0;
  final double _trackPadding = 2.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateScrollData();
        widget.scrollController.addListener(_handleScrollChange);
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScrollChange);
    super.dispose();
  }

  void _handleScrollChange() {
    if (mounted) {
      setState(() {
        _updateScrollData();
      });
    }
  }

  void _updateScrollData() {
    try {
      if (widget.scrollController.hasClients) {
        _scrollPosition = widget.scrollController.position.pixels;
        // 核心修改：如果提供了 overallContentExtent 且为水平滚动，则使用它作为总内容长度
        if (widget.scrollDirection == Axis.horizontal && widget.overallContentExtent != null) {
          _calculatedContentExtent = widget.overallContentExtent!;
        } else {
          // 否则，按常规方式从 ScrollController 获取内容总长度
          _calculatedContentExtent = widget.scrollController.position.maxScrollExtent +
              widget.scrollController.position.viewportDimension;
        }

        // _viewportExtent 始终从 RenderBox 或 LayoutBuilder 获取，因为 ScrollController.position.viewportDimension
        // 只反映其直接控制的滚动区域的视口，而不是整个包裹容器的视口。
        // 我们将在 build 方法中通过 LayoutBuilder 获取实际渲染的视口大小。
      }
    } catch (e) {
      print("Error updating scroll data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder( // 使用 LayoutBuilder 获取包裹容器的实际尺寸
      builder: (context, constraints) {
        // 根据滚动方向设置实际的视口长度
        _calculatedViewportExtent = widget.scrollDirection == Axis.vertical
            ? constraints.maxHeight
            : constraints.maxWidth;

        // 计算滑块位置
        double thumbPositionRatio = 0.0;
        if (_calculatedContentExtent > _calculatedViewportExtent && (_calculatedContentExtent - _calculatedViewportExtent) > 0) {
          thumbPositionRatio = _scrollPosition / (_calculatedContentExtent - _calculatedViewportExtent);
          thumbPositionRatio = thumbPositionRatio.clamp(0.0, 1.0);
        }

        double trackExtent = _calculatedViewportExtent > 0 ? _calculatedViewportExtent : _thumbSize;
        double availableTrackSpace = trackExtent - _thumbSize;
        double thumbPosition = thumbPositionRatio * availableTrackSpace;

        bool showScrollbar = _calculatedContentExtent > _calculatedViewportExtent;

        return Stack(
          children: [
            widget.child,
            if (showScrollbar)
              _buildScrollbar(thumbPosition, trackExtent),
          ],
        );
      },
    );
  }

  Widget _buildScrollbar(double thumbPosition, double trackExtent) {
    if (widget.scrollDirection == Axis.vertical) {
      return Positioned(
        right: _trackPadding,
        top: 0,
        bottom: 0,
        width: _trackThickness,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE7E7E7),
                borderRadius: BorderRadius.circular(_trackThickness / 2),
              ),
            ),
            Positioned(
              top: thumbPosition,
              child: Container(
                width: _trackThickness,
                height: _thumbSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF3361FE),
                  borderRadius: BorderRadius.circular(_trackThickness / 2),
                ),
              ),
            ),
          ],
        ),
      );
    } else { // Axis.horizontal
      return Positioned(
        bottom: _trackPadding,
        left: 0,
        right: 0,
        height: _trackThickness,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE7E7E7),
                borderRadius: BorderRadius.circular(_trackThickness / 2),
              ),
            ),
            Positioned(
              left: thumbPosition,
              child: Container(
                width: _thumbSize,
                height: _trackThickness,
                decoration: BoxDecoration(
                  color: const Color(0xFF3361FE),
                  borderRadius: BorderRadius.circular(_trackThickness / 2),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}