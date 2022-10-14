import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:video_download/utils/parser/platforms.dart';

import 'base.dart';

class Tools {
  static detectVideoPlatform(String str) {
    Map<String, Base> instances = Platforms.instances;
    for (var k in instances.keys) {
      Base? instance = instances[k];
      if (instance == null) continue;
      try {
        var url = instance.getUrl(str);
        return {
          "platform_name": instance.platformName,
          "platform": instance.platform,
          "url": url,
          "share": str,
        };
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  static CancelToken download(
      {required url,
      required savePath,
      required Function onReceiveProgress,
      Function? onComplete,
      Function? onError}) {
    createCallback(count, total) {
      double percent = 0.0;
      if (onReceiveProgress != null && total != 0) {
        percent = count / total;
      }
      onReceiveProgress(percent, count, total);
    }

    CancelToken token = CancelToken();
    var dio = Dio();
    dio
        .download(url, savePath,
            options: Options(headers: {
              "User-Agent": "Mozilla/5.0 (Linux; Android 11; MI 9 Build/RKQ1.200826.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/94.0.4606.85 Mobile Safari/537.36",
            }),
            cancelToken: token, onReceiveProgress: createCallback)
        .then((value) {
      onComplete?.call(value);
      return Future.value(value);
    }).catchError((err) {
      print(err);
      onError?.call(err);
    });
    return token;
  }

  static String md5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = crypto.md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

  static Future downloadWithChunks(
    url,
    savePath, {
    required ProgressCallback onReceiveProgress,
  }) async {
    const firstChunkSize = 102;
    const maxChunk = 3;

    int total = 0;
    var dio = Dio();
    var progress = <int>[];

    createCallback(no) {
      return (int received, _) {
        progress[no] = received;
        if (onReceiveProgress != null && total != 0) {
          onReceiveProgress(progress.reduce((a, b) => a + b), total);
        }
      };
    }

    Future<Response> downloadChunk(url, start, end, no) async {
      progress.add(0);
      --end;
      return dio.download(
        url,
        savePath + "temp$no",
        onReceiveProgress: createCallback(no),
        options: Options(
          headers: {"range": "bytes=$start-$end"},
        ),
      );
    }

    Future mergeTempFiles(chunk) async {
      File f = File(savePath + "temp0");
      IOSink ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
      for (int i = 1; i < chunk; ++i) {
        File _f = File(savePath + "temp$i");
        await ioSink.addStream(_f.openRead());
        await _f.delete();
      }
      await ioSink.close();
      await f.rename(savePath);
    }

    Response response = await downloadChunk(url, 0, firstChunkSize, 0);
    if (response.statusCode == 206) {
      total = int.parse(response.headers
          .value(HttpHeaders.contentRangeHeader)!
          .split("/")
          .last);
      var len = response.headers.value(HttpHeaders.contentLengthHeader);
      int reserved = total - int.parse(len == null ? "0" : len);
      int chunk = (reserved / firstChunkSize).ceil() + 1;
      if (chunk > 1) {
        int chunkSize = firstChunkSize;
        if (chunk > maxChunk + 1) {
          chunk = maxChunk + 1;
          chunkSize = (reserved / maxChunk).ceil();
        }
        var futures = <Future>[];
        for (int i = 0; i < maxChunk; ++i) {
          int start = firstChunkSize + i * chunkSize;
          futures.add(downloadChunk(url, start, start + chunkSize, i + 1));
        }
        await Future.wait(futures);
      }
      await mergeTempFiles(chunk);
    }
  }
}
