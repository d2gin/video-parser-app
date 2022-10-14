import 'base.dart';

class Douyin extends Base {
  String shortHost = "v.douyin.com";
  String shareHost = "www.iesdouyin.com";
  String platformName = "抖音";
  String platform = "douyin";

  Douyin() {
    this.urlPattern = r"(http[s]*\://(?:" +
        this.pregQuote(this.shortHost) +
        "|" +
        this.pregQuote(this.shareHost) +
        r")/(?:[\w/]+))";
  }
}
