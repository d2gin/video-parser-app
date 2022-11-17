import 'package:flutter/material.dart';

class DragLoatingActionButtonLocation extends FloatingActionButtonLocation {
  Offset? locationOffset;

  DragLoatingActionButtonLocation(this.locationOffset) : super();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    if(locationOffset != null) {
      return locationOffset!;
    }
    return FloatingActionButtonLocation.endFloat.getOffset(scaffoldGeometry);
  }
}
