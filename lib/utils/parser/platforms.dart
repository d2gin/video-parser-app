import 'package:video_download/utils/parser/ppx.dart';
import 'package:video_download/utils/parser/weibo.dart';

import 'base.dart';
import 'douyin.dart';

class Platforms {
  static final description = {
    "auto": {
      "title": "自动识别",
      "logo": "assets/images/logo.png",
      "color": 0xff1D0B1B,
    },
    "douyin": {
      "title": "抖音无水印",
      "logo": "assets/images/douyin.png",
      "color": 0xff1D0B1B,
    },
    "ppx": {
      "title": "皮皮虾无水印",
      "logo": "assets/images/ppx.jpg",
      "color": 0xffFE6881,
    },
    "weibo": {
      "title": "微博无水印",
      "logo": "assets/images/weibo.png",
      "color": 0xffF2C931,
    },
  };
  static Map<String, Base> instances = {
    "ppx": Ppx(),
    "douyin": Douyin(),
    "weibo": Weibo(),
  };
}
