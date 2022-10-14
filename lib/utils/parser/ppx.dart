import 'base.dart';

class Ppx extends Base {
  String shortHost = "h5.pipix.com";
  String shareHost = "h5.pipix.com";
  String platformName = "皮皮虾";
  String platform = "ppx";

  Ppx() {
    this.urlPattern =
        "(http[s]*\://(?:${pregQuote(shortHost)}|${pregQuote(shareHost)})/(?:[\\w/]+))";
  }
}
