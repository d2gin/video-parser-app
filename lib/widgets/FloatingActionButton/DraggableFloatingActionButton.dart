import 'package:flutter/material.dart';

class DraggableFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onDragEnd;
  final Widget? child;

  const DraggableFloatingActionButton(
      {Key? key, required this.onPressed, this.onDragEnd, this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DraggableFloatingActionButtonState();
  }
}

class DraggableFloatingActionButtonState
    extends State<DraggableFloatingActionButton> {
  Offset? floatingActionButtonOffset;

  DraggableFloatingActionButtonState();

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: _downloadButton(),
      child: _downloadButton(),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () {},
      onDragEnd: (details) {
        setState(() {
          this.floatingActionButtonOffset = details.offset;
          widget.onDragEnd?.call();
        });
      },
    );
  }

  FloatingActionButton _downloadButton() {
    return FloatingActionButton(
      child: widget.child == null ? Icon(Icons.add_sharp) : widget.child,
      onPressed: () {
        widget.onPressed?.call();
      },
    );
  }
}
