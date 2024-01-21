import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class RoundRectangleCard extends StatefulWidget {
  final Widget child;
  final Function()? onTap;
  final bool animate;
  final List<BoxShadow> boxShadow;

  const RoundRectangleCard({
    Key? key,
    required this.child,
    this.onTap,
    this.animate = true,
    this.boxShadow = const [
      BoxShadow(
        color: CupertinoColors.systemGrey5,
        spreadRadius: 0,
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  }) : super(key: key);

  @override
  _RoundRectangleCardState createState() => _RoundRectangleCardState();
}

class _RoundRectangleCardState extends State<RoundRectangleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 400),
      );
      _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isDown = false;
    var isCancel = false;
    var core = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // In light mode, color is white; in dark mode, color is black
        color:
            SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                    Brightness.dark
                ? CupertinoDynamicColor.resolve(
                    CupertinoColors.secondarySystemBackground, context)
                : CupertinoDynamicColor.resolve(CupertinoColors.white, context),
        boxShadow: SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark
            ? null : widget.boxShadow
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(child: widget.child),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
    return widget.animate
        ? GestureDetector(
            onTapDown: (_) async {
              isDown = true;
              isCancel = false;
              _animationController.forward();
              await Future.delayed(const Duration(milliseconds: 125));
              isDown = false;
              if (isCancel) {
                if (widget.onTap != null) {
                  widget.onTap?.call();
                }
                _animationController.reverse();
                isCancel = false;
              }
            },
            onTapUp: (_) async {
              isCancel = true;
              if (!isDown) _animationController.reverse();
            },
            onTapCancel: () async => _animationController.reverse(),
            child: ScaleTransition(scale: _scaleAnimation, child: core),
          )
        : GestureDetector(onTap: widget.onTap, child: core);
  }
}

class RoundRectangleCardWithForehead extends StatelessWidget {
  final Widget child;
  final Widget forehead;
  final Color foreheadColor;
  final Function()? onTap;
  final bool animate;

  const RoundRectangleCardWithForehead({
    Key? key,
    required this.child,
    required this.forehead,
    this.foreheadColor = CupertinoColors.systemFill,
    this.onTap,
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: SizedBox(
                child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: CupertinoDynamicColor.resolve(foreheadColor, context),
            boxShadow: const [
            ],
          ),
        ))),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            forehead,
            RoundRectangleCard(
              onTap: onTap,
              animate: animate,
              boxShadow: const [],
              child: child,
            ),
          ],
        )
      ],
    );
  }
}
