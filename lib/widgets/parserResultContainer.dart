import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../utils/parser/base.dart';
import '../utils/parser/tools.dart';
import 'downloadProgress.dart';

class ParserResultContainer extends StatefulWidget {
  var result;
  Base? platformInstance;

  ParserResultContainer(
      {Key? key, required this.result, Base? this.platformInstance})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ParserResultContainerState();
}

class ParserResultContainerState extends State<ParserResultContainer> {
  double videoContainerHeight = 400;
  FijkPlayer player = FijkPlayer();

  @override
  void didUpdateWidget(covariant ParserResultContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    print('-- deactivate');
    if (this.player.isPlayable()) {
      this.player.reset();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result == null) return SizedBox.shrink();
    List<Widget> childList = [];
    // 解析为视频
    if (widget.result["result_type"] == "video") {
      var videoUrl = widget.result["video_url"];
      this.setVideoSource(videoUrl);
      childList.add(Row(
        children: [
          Container(
            height: 30,
            child: ElevatedButton(
              onPressed: onSaveVideo,
              child: Text("下载视频"),
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 10)),
          Container(
            height: 30,
            child: ElevatedButton(
              child: Text("复制链接"),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: videoUrl));
                SmartDialog.showToast("已复制");
              },
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 10)),
          Container(
            height: 30,
            child: ElevatedButton(
              child: Text("视频链接"),
              onPressed: () {
                SmartDialog.show(
                  widget: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      color: Colors.white,
                      child: SelectableText(widget.result["video_url"]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ));
      childList.add(Padding(padding: EdgeInsets.only(top: 5)));
      // 帖子内容
      if (widget.result["title"] != null) {
        childList.add(Padding(
          padding: EdgeInsets.only(top: 10, bottom: 8),
          child: Text(widget.result["title"]),
        ));
      }
      // 视频链接
      /*if (this.parseResult["video_url"] != null) {
        childList.add(SelectableText(this.parseResult["video_url"]));
        // 上边距
        childList.add(Padding(padding: EdgeInsets.only(top: 10)));
      }*/
      // 视频播放组件
      childList.add(Container(
        width: double.infinity,
        child: _fijkPlayer(cover: widget.result["cover"]),
      ));
    }
    // 解析为图片
    else if (widget.result["result_type"] == "image") {
      if (widget.result["title"] != null) {
        childList.add(Container(
          child: Text(widget.result["title"]),
        ));
        childList.add(Padding(padding: EdgeInsets.only(bottom: 10)));
      }
      List<Widget> images = [];
      for (var image in widget.result["images"]) {
        var imageSrc = image["url"];
        List sheets = [
          {
            "title": "保存相册",
            "click": (act) async {
              SmartDialog.dismiss();
              this.saveMediaFile(imageSrc, image["ext"]);
            },
            "code": "save"
          },
          {
            "title": "取消",
            "click": (act) {
              SmartDialog.dismiss();
            },
            "code": "cancel"
          }
        ];
        images.add(GestureDetector(
          onTapUp: (TapUpDetails) {
            SmartDialog.show(
              widget: GestureDetector(
                onLongPress: () {
                  SmartDialog.show(
                    isLoadingTemp: false,
                    alignmentTemp: Alignment.bottomCenter,
                    animationDurationTemp: Duration(milliseconds: 80),
                    // isUseAnimationTemp: false,
                    widget: this._menuSheets(sheets),
                  );
                },
                child: Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: Image.network(imageSrc),
                  decoration: BoxDecoration(),
                ),
              ),
            );
          },
          child: GestureDetector(
            onLongPress: () {
              SmartDialog.show(
                alignmentTemp: Alignment.bottomCenter,
                animationDurationTemp: Duration(milliseconds: 80),
                widget: this._menuSheets(sheets),
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(imageSrc), fit: BoxFit.cover),
              ),
            ),
          ),
        ));
      }
      childList.add(Wrap(children: images, spacing: 1, runSpacing: 2));
      childList.add(Container(
        padding: EdgeInsets.only(top: 5.0),
        child: Row(
          children: [
            Text("Tips：", style: TextStyle(color: Colors.red)),
            Text("解析结果为图片，点击图片预览，长按下载保存。"),
          ],
        ),
      ));
    }
    // 识别不到
    else {
      childList = [
        Center(
          child: Container(
            child: Text("不支持的类型"),
          ),
        )
      ];
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: Color(0xffeeeeee)),
        borderRadius: BorderRadius.circular(3),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xffededed),
            offset: Offset(0, 1.0),
            blurRadius: 3.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      // child: _fijkPlayer(),
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: childList,
          ),
        ),
      ),
    );
  }

  void saveMediaFile(String url, String ext) async {
    var rootPath = await widget.platformInstance?.getSavePath();
    print(rootPath);
    var savePath = rootPath.toString() +
        // Tools.md5(url) +
        // "_" +
        formatDate(DateTime.now(), [yyyy, mm, dd, hh, nn, ss]) +
        "_" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        "." +
        ext;
    this.saveFile(url, savePath);
  }

  void onSaveVideo() async {
    var url = widget.result["video_url"];
    this.saveMediaFile(url, "mp4");
  }

  void saveFile(url, savePath) {
    var file = File(savePath);
    if (file.existsSync()) {
      print("文件已存在：" + savePath);
      // 存在文件就删除
      file.deleteSync();
    }

    Function? updatePercent;
    var dio = Tools.download(
        url: url,
        savePath: savePath,
        onReceiveProgress: (percent, received, total) {
          updatePercent?.call(percent);
        },
        onComplete: (v) {
          SmartDialog.showToast("下载完成");
          SmartDialog.dismiss();
          DeviceInfoPlugin().androidInfo.then((deviceInfo) {
            // 荣耀20下载的视频不能在相册显示，要借助原生插件
            try {
              if (deviceInfo.model == "YAL-AL00") {
                ImageGallerySaver.saveFile(savePath).then((value) {
                  var newPath = savePath + ".delete";
                  File(savePath).renameSync(newPath);
                  File(newPath).deleteSync();
                });
              }
            } catch (e) {}
          });
        },
        onError: (err) {
          SmartDialog.dismiss();
        });
    SmartDialog.show(
      clickBgDismissTemp: false,
      widget: DownloadProgress(
        handleUpdate: (handleUpdate) => updatePercent = handleUpdate,
      ),
      onDismiss: () {
        dio.cancel();
      },
    );
  }

  Widget _menuSheets(sheets) {
    var sheetStyle = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );
    List<Widget> sheetWidgets = [];
    for (var sheet in sheets) {
      sheetWidgets.add(Row(
        children: [
          Expanded(
            child: Padding(
                padding: EdgeInsets.only(bottom: 9),
                child: GestureDetector(
                  onTapUp: (TapUpDetails) {
                    sheet["click"]?.call(sheet["code"]);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      sheet["title"],
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    decoration: sheetStyle,
                  ),
                )),
          )
        ],
      ));
    }
    return Container(
      height: 120,
      padding: EdgeInsets.only(left: 5, right: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5.0),
          topRight: Radius.circular(5.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: sheetWidgets,
      ),
    );
  }

  Widget _fijkPlayer({String? cover}) {
    return Container(
      // height: 400,
      child: FijkView(
        player: this.player,
        height: this.videoContainerHeight,
        color: Color(0xff494949),
        cover: cover == null ? null : NetworkImage(cover),
      ),
    );
  }

  void setVideoSource(String url) async {
    await this.player.reset();
    this.player.setDataSource(url, showCover: true);
  }

  void pauseVideo() {
    if (this.player.isPlayable() && this.player.state == FijkState.started) {
      this.player.pause();
    }
  }
}
