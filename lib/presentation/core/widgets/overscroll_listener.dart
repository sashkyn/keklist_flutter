import 'package:flutter/material.dart';

final class OverscrollListener extends StatefulWidget {
  final Widget child;
  final ScrollController childScrollController;
  final Function? onOverscrollTopPointerUp;
  final Function? onOverscrollBottomPointerUp;
  final Function? onOverscrollTop;
  final Function? onOverscrollBottom;
  final double overscrollOffset;

  const OverscrollListener({
    super.key,
    this.onOverscrollTopPointerUp,
    this.onOverscrollBottomPointerUp,
    this.onOverscrollTop,
    this.onOverscrollBottom,
    this.overscrollOffset = 150.0,
    required this.childScrollController,
    required this.child,
  });

  @override
  State<OverscrollListener> createState() => _OverscrollListenerState();
}

final class _OverscrollListenerState extends State<OverscrollListener> {
  ScrollController get _scrollController => widget.childScrollController;

  bool _overscrollCalled = false;

  bool get _isBeginOverscrollTop =>
      _scrollController.position.pixels > -widget.overscrollOffset && _scrollController.position.pixels < 0;

  bool get _isBeginOverscrollBottom =>
      _scrollController.position.pixels < _scrollController.position.maxScrollExtent + widget.overscrollOffset &&
      _scrollController.position.pixels > 0;

  bool get _isOverscrolledTop => _scrollController.position.pixels < -widget.overscrollOffset;

  bool get _isOverscrolledBottom =>
      _scrollController.position.pixels >= _scrollController.position.maxScrollExtent + widget.overscrollOffset;

  // final double _overscrollWidgetOffset = 32.0;
  // late double _topWidgetY = -_overscrollWidgetOffset;

  @override
  void initState() {
    super.initState();

    // _scrollController.addListener(() {
    //   setState(() {
    //     _topWidgetY = -_scrollController.position.pixels - _overscrollWidgetOffset;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        // Positioned(
        //   top: _topWidgetY,
        //   child: const Row(
        //     children: [
        //       Icon(Icons.arrow_upward),
        //       Text('Go to previous day'),
        //     ],
        //   ),
        // ),
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
