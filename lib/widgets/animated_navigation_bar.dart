import 'package:flutter/material.dart';

class AnimatedNavigationBar extends StatefulWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const AnimatedNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.selectedColor = const Color(0xFF667EEA),
    this.unselectedColor = Colors.grey,
  });

  @override
  State<AnimatedNavigationBar> createState() => _AnimatedNavigationBarState();
}

class _AnimatedNavigationBarState extends State<AnimatedNavigationBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _iconControllers;
  late List<AnimationController> _textControllers;
  late List<Animation<double>> _iconAnimations;
  late List<Animation<double>> _textAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didUpdateWidget(AnimatedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateToCurrentIndex();
    }
  }

  void _initializeAnimations() {
    _iconControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _textControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _iconAnimations = _iconControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _textAnimations = _textControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _scaleAnimations = _iconControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _animateToCurrentIndex();
  }

  void _animateToCurrentIndex() {
    for (int i = 0; i < widget.items.length; i++) {
      if (i == widget.currentIndex) {
        _iconControllers[i].forward();
        _textControllers[i].forward();
      } else {
        _iconControllers[i].reverse();
        _textControllers[i].reverse();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.items.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onTap(index),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _iconControllers[index],
                  _textControllers[index],
                ]),
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Icon with Scale and Color
                        Transform.scale(
                          scale: _scaleAnimations[index].value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == widget.currentIndex
                                  ? widget.selectedColor.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              (widget.items[index].icon as Icon).icon!,
                              color: index == widget.currentIndex
                                  ? widget.selectedColor
                                  : widget.unselectedColor,
                              size: 20 * _iconAnimations[index].value,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Animated Text with Fade and Slide
                        AnimatedOpacity(
                          opacity: _textAnimations[index].value,
                          duration: const Duration(milliseconds: 200),
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              (1 - _textAnimations[index].value) * 8,
                            ),
                            child: Text(
                              widget.items[index].label!,
                              style: TextStyle(
                                color: index == widget.currentIndex
                                    ? widget.selectedColor
                                    : widget.unselectedColor.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: index == widget.currentIndex
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
