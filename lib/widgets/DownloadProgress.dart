import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DownloadProgress extends StatefulWidget {
  Function(Function handleUpdate)? handleUpdate;

  DownloadProgress({Key? key, this.handleUpdate}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DownloadProgressState();
}

class DownloadProgressState extends State<DownloadProgress> {
  double percent = 0.0;

  @override
  void initState() {
    widget.handleUpdate?.call((double percent) {
      setState(() {
        if (percent is double) this.percent = percent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 50, right: 50),
      child: LinearProgressIndicator(
        value: this.percent,
        backgroundColor: Colors.white,
        minHeight: 5,
      ),
    );
  }
}
