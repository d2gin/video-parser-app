import 'base.dart';

class Weibo extends Base {
  String contentHost = "m.weibo.cn";
  String videoHost = "video.weibo.com";
  String platform = "weibo";
  String platformName = "微博";

  Weibo() {
    this.urlPattern = r"(https\://(?:" +
        this.pregQuote(this.contentHost) +
        "|" +
        this.pregQuote(this.videoHost) +
        r")/(?:[\w\?=&%\:/]+))";
  }
}
