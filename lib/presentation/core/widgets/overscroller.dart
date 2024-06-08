import 'package:flutter/widgets.dart';

final class Overscroller extends StatefulWidget {
  final Widget child;
  final ScrollController childScrollController;
  final Function? onOverscrollTopPointerUp;
  final Function? onOverscrollBottomPointerUp;
  final Function? onOverscrollTop;
  final Function? onOverscrollBottom;

  const Overscroller({
    super.key,
    required this.childScrollController,
    this.onOverscrollTopPointerUp,
    this.onOverscrollBottomPointerUp,
    this.onOverscrollTop,
    this.onOverscrollBottom,
    required this.child,
  });

  @override
  State<Overscroller> createState() => _OverscrollerState();
}

final class _OverscrollerState extends State<Overscroller> {
  ScrollController get _scrollController => widget.childScrollController;

  bool _overscrollCalled = false;

  bool get _isBeginOverscrollTop => _scrollController.position.pixels > -150 && _scrollController.position.pixels < 0;

  bool get _isBeginOverscrollBottom =>
      _scrollController.position.pixels < _scrollController.position.maxScrollExtent + 150 &&
      _scrollController.position.pixels > 0;

  bool get _isOverscrolledTop => _scrollController.position.pixels < -150;

  bool get _isOverscrolledBottom =>
      _scrollController.position.pixels >= _scrollController.position.maxScrollExtent + 150;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerDown: (_) {},
          onPointerUp: (_) {
            if (_isOverscrolledTop) {
              widget.onOverscrollTopPointerUp?.call();
            } else if (_isOverscrolledBottom) {
              widget.onOverscrollBottomPointerUp?.call();
            }
          },
          onPointerMove: (event) {
            if (_isOverscrolledBottom) {
              _overscrollTop();
            } else if (_isBeginOverscrollBottom) {
              _overscrollCalled = false;
            }

            if (_isOverscrolledTop) {
              _overscrollBottom();
            } else if (_isBeginOverscrollTop) {
              _overscrollCalled = false;
            }
          },
          child: widget.child,
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
