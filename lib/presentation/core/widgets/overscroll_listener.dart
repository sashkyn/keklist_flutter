import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

final class OverscrollListener extends StatefulWidget {
  final Widget child;
  final Widget? topOverscrollChild;
  final Widget? bottomOverscrollChild;
  final ScrollController childScrollController;
  final Function? onOverscrollTopPointerUp;
  final Function? onOverscrollBottomPointerUp;
  final Function? onOverscrollTop;
  final Function? onOverscrollBottom;
  final double overscrollTargetOffset;
  final double scrollBottomOffset;

  const OverscrollListener({
    super.key,
    this.onOverscrollTopPointerUp,
    this.onOverscrollBottomPointerUp,
    this.onOverscrollTop,
    this.onOverscrollBottom,
    this.overscrollTargetOffset = 150.0,
    this.scrollBottomOffset = 150.0,
    required this.childScrollController,
    required this.child,
    this.topOverscrollChild,
    this.bottomOverscrollChild,
  });

  @override
  State<OverscrollListener> createState() => _OverscrollListenerState();
}

final class _OverscrollListenerState extends State<OverscrollListener> {
  ScrollController get _scrollController => widget.childScrollController;

  ScrollPosition? get _scrollPosition {
    if (_scrollController.positions.isEmpty) {
      return null;
    }
    return _scrollController.position;
  }

  bool _overscrollCalled = false;

  bool get _isBeginOverscrollTop =>
      (_scrollPosition?.pixels ?? 0.0) > -widget.overscrollTargetOffset && (_scrollPosition?.pixels ?? 0.0) < 0;

  bool get _isBeginOverscrollBottom =>
      (_scrollPosition?.pixels ?? 0.0) < (_scrollPosition?.maxScrollExtent ?? 0.0) + widget.overscrollTargetOffset &&
      (_scrollPosition?.pixels ?? 0.0) > 0.0;

  bool get _isOverscrolledTop => (_scrollPosition?.pixels ?? 0.0) < -widget.overscrollTargetOffset;

  bool get _isOverscrolledBottom =>
      (_scrollPosition?.pixels ?? 0.0) >= (_scrollPosition?.maxScrollExtent ?? 0.0) + widget.overscrollTargetOffset;

  final double _overscrollWidgetOffset = 40.0;
  late double _topWidgetY = -_overscrollWidgetOffset;
  late double _bottomWidgetY = 0.0;

  @override
  void initState() {
    super.initState();

    if (widget.topOverscrollChild != null || widget.bottomOverscrollChild != null) {
      _scrollController.addListener(
        () {
          setState(() {
            if (widget.topOverscrollChild != null) {
              _topWidgetY = -(_scrollPosition?.pixels ?? 0.0) - _overscrollWidgetOffset;
            }
            if (widget.bottomOverscrollChild != null) {
              _bottomWidgetY = (_scrollPosition?.pixels ?? 0.0) -
                  (_scrollPosition?.maxScrollExtent ?? 0.0) +
                  widget.scrollBottomOffset -
                  _overscrollWidgetOffset;
            }
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Listener(
          onPointerUp: (_) {
            if (_isOverscrolledTop) {
              widget.onOverscrollTopPointerUp?.call();
            } else if (_isOverscrolledBottom) {
              widget.onOverscrollBottomPointerUp?.call();
            }
          },
          onPointerMove: (event) {
            if (_isOverscrolledBottom) {
              _overscrollBottom();
            } else if (_isBeginOverscrollBottom) {
              _overscrollCalled = false;
            }

            if (_isOverscrolledTop) {
              _overscrollTop();
            } else if (_isBeginOverscrollTop) {
              _overscrollCalled = false;
            }
          },
          child: widget.child,
        ),
        if (widget.topOverscrollChild != null)
          Visibility(
            visible: _isOverscrolledTop,
            child: Positioned(
              top: _topWidgetY,
              child: widget.topOverscrollChild!.animate().fade(duration: const Duration(milliseconds: 100)),
            ),
          ),
        if (widget.bottomOverscrollChild != null)
          Visibility(
            visible: _isOverscrolledBottom,
            child: Positioned(
              bottom: _bottomWidgetY,
              child: widget.bottomOverscrollChild!.animate().fade(duration: const Duration(milliseconds: 100)),
            ),
          ),
      ],
    );
  }

  void _overscrollTop() {
    if (_overscrollCalled) {
      return;
    }
    _overscrollCalled = true;
    widget.onOverscrollTop?.call();
  }

  void _overscrollBottom() {
    if (_overscrollCalled) {
      return;
    }
    _overscrollCalled = true;
    widget.onOverscrollBottom?.call();
  }
}
