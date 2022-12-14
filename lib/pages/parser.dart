import 'dart:async';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:video_download/utils/parser/base.dart';
import 'package:video_download/utils/parser/platforms.dart';
import 'package:video_download/utils/parser/tools.dart';
import 'package:video_download/widgets/FloatingActionButton/DraggableFloatingActionButton.dart';
import 'package:video_download/widgets/ParserResultContainer.dart';

import '../widgets/FloatingActionButton/DragFloatingActionButtonLocation.dart';
import '../widgets/FloatingActionButton/NoScalingAnimation.dart';

class ParserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ParserPageState();
}

class ParserPageState extends State with WidgetsBindingObserver {
  late TextEditingController inputCtrl;
  String platform = "auto";
  Map platformMaps = Platforms.description;
  Base? platformInstance;
  var parseResult;
  final GlobalKey _parserResultContainerKey =
      GlobalKey<ParserResultContainerState>();
  final GlobalKey _floatingActionButtonKey =
      GlobalKey<DraggableFloatingActionButtonState>();

  FijkPlayer player = FijkPlayer();
  late Color navbarFrontColor = Colors.white;

  double downloadPercent = 0.00;
  late Widget showDownloadPercent;
  List urlParsed = [];
  double videoContainerHeight = 400;

  Offset? floatingActionButtonOffset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    inputCtrl = TextEditingController(text: "https://h5.pipix.com/s/L3RtPLW/");
    this._detectClipboardAndParse();
  }

  @override
  void didUpdateWidget(covariant StatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    player.release();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("--" + state.toString());
    switch (state) {
      // ?????????????????????????????????????????????????????????????????????????????????
      case AppLifecycleState.inactive:
        break;
      // ???????????????????????????
      case AppLifecycleState.resumed:
        // if (player.isPlayable() && player.state == FijkState.paused) {
        // player.start();
        // }
        this._detectClipboardAndParse();
        break;
      // ??????????????????????????????
      case AppLifecycleState.paused:
        setState(() {
          var state = _parserResultContainerKey.currentState
              as ParserResultContainerState;
          state.setState(() {
            if (state.player.isPlayable() &&
                state.player.state == FijkState.started) {
              state.player.pause();
            }
          });
        });
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "????????????",
          style: TextStyle(
            // color: navbarFrontColor,
            color: Color(0xff000000),
            fontSize: 16,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        // backgroundColor: Color(platformMaps[platform]["color"]),
        backgroundColor: Color(0xfff0f0f0),
        toolbarHeight: 40,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // ????????????
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 6)),
            // ??????logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _logoContainer(platformMaps[platform]["logo"]),
              ],
            ),
            // ????????????
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 32),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 5),
                      width: 55,
                      child: Text(
                        "????????????",
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      child: _shareInput(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 32),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      padding: EdgeInsets.only(right: 5),
                      child: Text(
                        "????????????",
                        textAlign: TextAlign.end,
                      ),
                    ),
                    // ??????
                    Expanded(child: _platformSelect()),
                  ],
                ),
              ),
            ),
            // ????????????
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 32),
                child: Row(
                  children: [
                    Container(
                      width: 65,
                    ),
                    Container(
                      width: 50,
                      child: ElevatedButton(
                        child: Text("??????"),
                        style: ElevatedButton.styleFrom(
                          elevation: 1.0,
                          padding: EdgeInsets.all(0),
                        ),
                        onPressed: handleParse,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 6)),
                    Container(
                      width: 80,
                      child: ElevatedButton(
                        child: Text("???????????????"),
                        style: ElevatedButton.styleFrom(
                          elevation: 1.0,
                          padding: EdgeInsets.all(0),
                        ),
                        onPressed: handleDetectClipboard,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 6)),
                    Container(
                      width: 50,
                      child: ElevatedButton(
                        child: const Text(
                          "??????",
                          style: TextStyle(color: Color(0xff666666)),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xfff9f9f9),
                          elevation: 1.0,
                          padding: EdgeInsets.all(0),
                        ),
                        onPressed: onClear,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ParserResultContainer(
                  key: _parserResultContainerKey,
                  result: this.parseResult,
                  platformInstance: this.platformInstance,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          this.parseResult != null ? _floatingActionButton() : null,
      floatingActionButtonLocation:
          DragLoatingActionButtonLocation(this.floatingActionButtonOffset),
      floatingActionButtonAnimator: NoScalingAnimation(),
    );
  }

  void setNavBarFrontColor() {
    setState(() {
      navbarFrontColor =
          SystemChrome.latestStyle?.statusBarBrightness == Brightness.light
              ? Colors.black
              : Colors.white;
    });
  }

  Container _logoContainer(String logo) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        image: DecorationImage(image: AssetImage(logo)),
      ),
    );
  }

  /**
   * ?????????????????????
   */
  Widget _shareInput() {
    return TextField(
      controller: inputCtrl,
      cursorColor: const Color(0xFF000000),
      cursorWidth: 1.0,
      cursorHeight: 20,
      onChanged: (v) {
        detectPlatform(inputCtrl.value.text);
      },
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(FocusNode());
        handleParse();
      },
      decoration: const InputDecoration(
        hintText: "????????????",
        hintStyle: TextStyle(fontSize: 13),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFDCDFE6),
            width: 0.0,
          ),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFDCDFE6),
            width: 0,
          ),
        ),
        contentPadding:
            EdgeInsets.only(left: 5.0, right: 5.0, top: 0, bottom: 0),
      ),
    );
  }

  /**
   * ??????????????????
   */
  Widget _platformSelect() {
    return Container(
      padding: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.0),
        border: Border.all(width: 0.6, color: Color(0xff999999)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: platform,
          elevation: 1,
          isExpanded: true,
          // borderRadius: BorderRadius.all(Radius.circular(5.0)),
          style: TextStyle(
              color: Colors.black, overflow: TextOverflow.clip, fontSize: 13),
          icon: Expanded(
            // ???????????????
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          alignment: AlignmentDirectional.centerStart,
          items: _platformDropItem(),
          onChanged: (newValue) {
            setState(() {
              platform = newValue!;
            });
          },
        ),
      ),
    );
  }

  /**
   * ?????????????????????
   */
  List<DropdownMenuItem<String>> _platformDropItem() {
    return platformMaps.keys
        .toList()
        .map<DropdownMenuItem<String>>((dynamic value) {
      return DropdownMenuItem<String>(
        value: value as String,
        child: Text(
          platformMaps[value]["title"],
        ),
      );
    }).toList();
  }

  void handleParse([String? share]) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (share == null) share = inputCtrl.value.text;
    String platform;
    this.urlParsed.add(share);
    if (this.platform == "auto") {
      // ????????????
      var d = Tools.detectVideoPlatform(share);
      if (d == null || Platforms.instances[d["platform"]] == null) {
        SmartDialog.show(
          widget: Container(
            child: Text("??????????????????"),
            color: Colors.white,
            padding: EdgeInsets.all(10),
          ),
        );
        await Future.delayed(Duration(seconds: 1));
        SmartDialog.dismiss();
        return;
      }
      platform = d["platform"];
    } else if (Platforms.instances[this.platform] == null) {
      return;
    } else {
      // ????????????
      platform = this.platform;
    }
    Base? instance = Platforms.instances[platform];
    if (instance == null) {
      SmartDialog.showToast("?????????????????????");
      return;
    }
    this.platformInstance = instance;
    SmartDialog.showLoading(msg: "?????????", backDismiss: false);
    instance.analyze(share).then((value) {
      SmartDialog.dismiss();
      setState(() {
        this.parseResult = value;
      });
    });
  }

  void handleDetectClipboard() {
    Clipboard.getData(Clipboard.kTextPlain).then((value) {
      String? str = value?.text;
      if (str == null) {
        return;
      }
      inputCtrl.text = str;
      var d = Tools.detectVideoPlatform(str);
      print(d);
      if (d != null) {
        setState(() {
          this.platform = d["platform"];
        });
      }
    });
  }

  void onClear() {
    inputCtrl.clear();
    setState(() {
      this.resetParse();
    });
  }

  void detectPlatform(str) {
    // ????????????
    var d = Tools.detectVideoPlatform(str);
    if (d != null && this.platformMaps[d["platform"]] != null) {
      setState(() {
        this.platform = d["platform"];
      });
    }
  }

  Widget _floatingActionButton() {
    return DraggableFloatingActionButton(
      key: this._floatingActionButtonKey,
      child: const Text("??????"),
      onPressed: () {
        SmartDialog.showToast("?????????...");
      },
      onDragEnd: () => setState(() {
        DraggableFloatingActionButtonState? ABState = this
            ._floatingActionButtonKey
            .currentState as DraggableFloatingActionButtonState;
        // ??????????????????????????????
        this.floatingActionButtonOffset = ABState.floatingActionButtonOffset;
      }),
    );
  }

  Future<String?> _clipboardTips(result) {
    String platformName = result["platform_name"];
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('????????????????????????'),
        content: Row(children: [
          Text("???????????????????????? "),
          Text(
            platformName,
            style: TextStyle(
              color: Color(platformMaps[result["platform"]]["color"]),
            ),
          ),
          Text(" ??????????????????"),
        ]),
        actions: <Widget>[
          TextButton(
            child: const Text('??????'),
            onPressed: () {
              this.urlParsed.add(result["share"]);
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('??????'),
            onPressed: () {
              this.inputCtrl.text = result["share"];
              detectPlatform(result["share"]);
              this.handleParse();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _detectClipboardAndParse() {
    Clipboard.getData(Clipboard.kTextPlain).then((value) {
      String? str = value?.text;
      if (str == null) {
        return;
      }
      var d = Tools.detectVideoPlatform(str);
      if (d == null || this.platformMaps[d["platform"]] == null) {
        return;
      }
      if (urlParsed.indexOf(str) < 0) {
        _clipboardTips(d);
      } else if (inputCtrl.value.text != str) {
        inputCtrl.text = str;
        SmartDialog.showToast(
            "???????????????????????? " + d["platform_name"] + " ?????????????????????????????????");
      }
    });
  }

  resetParse() {
    this.parseResult = null;
    this.platform = "auto";
  }
}
