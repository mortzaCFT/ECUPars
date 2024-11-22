import 'package:flutter/material.dart';

class AnimatedIco extends StatefulWidget {
  final Duration speed;
  final IconData logo; // Icon to be animated
  final double width; // Width of the icon
  final double height; // Height of the icon
  final bool repeat; // Whether the animation repeats infinitely
  final Duration timeToRepeat; // Delay before repeating
  final Duration pauseBetweenRepeats; // Pause between repeat cycles
  final double maxScale; // Maximum scale factor for the icon

  const AnimatedIco({
    super.key,
    this.speed = const Duration(milliseconds: 500),
    this.logo = Icons.favorite,
    this.width = 60.0,
    this.height = 60.0,
    this.repeat = true,
    this.timeToRepeat = const Duration(milliseconds: 500),
    this.pauseBetweenRepeats = const Duration(seconds: 1),
    this.maxScale = 1.1,
  });

  @override
  _AnimatedIcoState createState() => _AnimatedIcoState();
}

class _AnimatedIcoState extends State<AnimatedIco> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.speed,
    );

    _rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.1), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 0), weight: 10),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: widget.maxScale), weight: 50),
      TweenSequenceItem(tween: Tween(begin: widget.maxScale, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.repeat) {
      _repeatWithPause();
    } else {
      _startOnceWithDelay();
    }
  }

  Future<void> _startOnceWithDelay() async {
    while (true) {
      await _controller.forward();
      await Future.delayed(widget.timeToRepeat);
      if (!widget.repeat) break;
      _controller.reset();
    }
  }

  Future<void> _repeatWithPause() async {
    while (widget.repeat) {
      await _controller.forward();
      await Future.delayed(widget.pauseBetweenRepeats);
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Transform.rotate(
            angle: _rotation.value,
            child: child,
          ),
        );
      },
      child: Icon(
        widget.logo,
        size: widget.width,
      ),
    );
  }
}
