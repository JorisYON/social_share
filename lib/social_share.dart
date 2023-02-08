import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SocialShare {
  static const MethodChannel _channel = const MethodChannel('social_share');

  static Future<String?> shareInstagramStory(
      {String? stickerPath,
      String? backgroundTopColor,
      String? backgroundBottomColor,
      String? backgroundImagePath,
      String? backgroundVideoPath}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      if (backgroundImagePath != null) {
        args = <String, dynamic>{
          "stickerImage": stickerPath,
          "backgroundImage": backgroundImagePath,
        };
      } else if (backgroundVideoPath != null) {
        args = <String, dynamic>{
          "stickerImage": stickerPath,
          "backgroundVideo": backgroundVideoPath,
        };
      } else {
        args = <String, dynamic>{
          "stickerImage": stickerPath,
          "backgroundTopColor": backgroundTopColor,
          "backgroundBottomColor": backgroundBottomColor
        };
      }
    } else {
      final tempDir = await getTemporaryDirectory();

      String? stickerAssetName;
      if (stickerPath != null) {
        File file = File(stickerPath);
        Uint8List bytes = file.readAsBytesSync();
        var stickerData = bytes.buffer.asUint8List();
        stickerAssetName = 'stickerAsset.png';
        final Uint8List stickerAssetAsList = stickerData;
        final stickerAssetPath = '${tempDir.path}/$stickerAssetName';
        file = await File(stickerAssetPath).create();
        file.writeAsBytesSync(stickerAssetAsList);
      }

      String? backgroundImageAssetName;
      if (backgroundImagePath != null) {
        File backgroundImage = File(backgroundImagePath);
        Uint8List backgroundImageData = backgroundImage.readAsBytesSync();
        backgroundImageAssetName = 'backgroundImageAsset.png';
        final Uint8List backgroundAssetAsList = backgroundImageData;
        final backgroundAssetPath = '${tempDir.path}/$backgroundImageAssetName';
        File backFile = await File(backgroundAssetPath).create();
        backFile.writeAsBytesSync(backgroundAssetAsList);
      }

      String? backgroundVideoAssetName;
      if (backgroundVideoPath != null) {
        File backgroundVideo = File(backgroundVideoPath);
        Uint8List backgroundImageData = backgroundVideo.readAsBytesSync();
        backgroundVideoAssetName = 'backgroundVideoAsset.mp4';
        final Uint8List backgroundAssetAsList = backgroundImageData;
        final backgroundAssetPath = '${tempDir.path}/$backgroundVideoAssetName';
        File backFile = await File(backgroundAssetPath).create();
        backFile.writeAsBytesSync(backgroundAssetAsList);
      }

      args = <String, dynamic>{
        "stickerImage": stickerAssetName,
        "backgroundImage": backgroundImageAssetName,
        "backgroundVideo": backgroundVideoAssetName,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor
      };
    }
    final String? response = await _channel.invokeMethod(
      'shareInstagramStory',
      args,
    );
    return response;
  }

  static Future<String?> shareInstagramWall({
    String? imagePath,
    String? videoPath,
  }) async {
    Map<String, dynamic> args;
    if(Platform.isIOS){
      args = <String, dynamic>{
        "image": imagePath,
        "video": videoPath,
      };
    }else{

      final tempDir = await getTemporaryDirectory();

      String? imageAssetName;
      if (imagePath != null) {
        File backgroundImage = File(imagePath);
        Uint8List backgroundImageData = backgroundImage.readAsBytesSync();
        imageAssetName = 'imageAsset.png';
        final Uint8List backgroundAssetAsList = backgroundImageData;
        final backgroundAssetPath = '${tempDir.path}/$imageAssetName';
        File backFile = await File(backgroundAssetPath).create();
        backFile.writeAsBytesSync(backgroundAssetAsList);
      }

      String? videoAssetName;
      if (videoPath != null) {
        File backgroundVideo = File(videoPath);
        Uint8List backgroundImageData = backgroundVideo.readAsBytesSync();
        videoAssetName = 'videoAsset.mp4';
        final Uint8List backgroundAssetAsList = backgroundImageData;
        final backgroundAssetPath = '${tempDir.path}/$videoAssetName';
        File backFile = await File(backgroundAssetPath).create();
        backFile.writeAsBytesSync(backgroundAssetAsList);
      }

      args = <String, dynamic>{
        "image": imageAssetName,
        "video": videoAssetName,
      };
    }
    final String? response = await _channel.invokeMethod(
      'shareInstagramWall',
      args,
    );
    return response;
  }

  static Future<String?> shareFacebookStory(
      {String? stickerPath,
      String? backgroundImagePath,
      String? backgroundVideoPath,
      String? backgroundTopColor,
      String? backgroundBottomColor,
      required String appId}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      if (backgroundImagePath != null) {
        args = <String, dynamic>{
          "backgroundImage": backgroundImagePath,
          "stickerImage": stickerPath,
          "FacebookAppID": appId
        };
      } else if (backgroundVideoPath != null) {
        args = <String, dynamic>{
          "stickerImage": stickerPath,
          "backgroundVideo": backgroundVideoPath,
          "FacebookAppID": appId
        };
      } else {
        args = <String, dynamic>{
          "stickerImage": stickerPath,
          "backgroundTopColor": backgroundTopColor,
          "backgroundBottomColor": backgroundBottomColor,
          "FacebookAppID": appId
        };
      }
    } else {
      final tempDir = await getTemporaryDirectory();

      String? stickerAssetName;
      if (stickerPath != null) {
        File file = File(stickerPath);
        Uint8List bytes = file.readAsBytesSync();
        var stickerData = bytes.buffer.asUint8List();
        stickerAssetName = 'stickerAsset.png';
        final Uint8List stickerAssetAsList = stickerData;
        final stickerAssetPath = '${tempDir.path}/$stickerAssetName';
        file = await File(stickerAssetPath).create();
        file.writeAsBytesSync(stickerAssetAsList);
      }

      String? backgroundImageAssetName;
      if (backgroundImagePath != null) {
        File backgroundImage = File(backgroundImagePath);
        Uint8List backgroundImageData = backgroundImage.readAsBytesSync();
        backgroundImageAssetName = 'backgroundImageAsset.png';
        final Uint8List backgroundAssetAsList = backgroundImageData;
        final backgroundAssetPath = '${tempDir.path}/$backgroundImageAssetName';
        File backFile = await File(backgroundAssetPath).create();
        backFile.writeAsBytesSync(backgroundAssetAsList);
      }

      String? backgroundVideoAssetName;
      if (backgroundVideoPath != null) {
        File backgroundVideo = File(backgroundVideoPath);
        Uint8List backgroundImageData = backgroundVideo.readAsBytesSync();
        backgroundVideoAssetName = 'backgroundVideoAsset.mp4';
        final Uint8List backgroundAssetAsList = backgroundImageData;
        final backgroundAssetPath = '${tempDir.path}/$backgroundVideoAssetName';
        File backFile = await File(backgroundAssetPath).create();
        backFile.writeAsBytesSync(backgroundAssetAsList);
      }

      args = <String, dynamic>{
        "stickerImage": stickerAssetName,
        "backgroundImage": backgroundImageAssetName,
        "backgroundVideo": backgroundVideoAssetName,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "appId": appId
      };
    }
    final String? response = await _channel.invokeMethod(
      'shareFacebookStory',
      args,
    );
    return response;
  }

  static Future<String?> shareFacebookWall(
      {String? imagePath,
        String? videoPath,
        String? link,
      String? hashtag}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {

      args = <String, dynamic>{
        "image": imagePath ?? '',
        "video": videoPath ?? '',
        "hashtag": hashtag ?? '',
        "link": link ?? '',
      };
    } else {
      final tempDir = await getTemporaryDirectory();

      String? imageAssetName;
      if (imagePath != null) {
        File backgroundImage = File(imagePath);
        Uint8List backgroundImageData = backgroundImage.readAsBytesSync();
        imageAssetName = 'imageAsset.png';
        final Uint8List backgroundAssetAsList = backgroundImageData;
        final backgroundAssetPath = '${tempDir.path}/$imageAssetName';
        File backFile = await File(backgroundAssetPath).create();
        backFile.writeAsBytesSync(backgroundAssetAsList);
      }

      String? videoAssetName;
      if (videoPath != null) {
        File backgroundVideo = File(videoPath);
        Uint8List backgroundVideoData = backgroundVideo.readAsBytesSync();
        videoAssetName = 'videoAsset.mp4';
        final Uint8List backgroundAssetAsList = backgroundVideoData;
        final backgroundAssetPath = '${tempDir.path}/$videoAssetName';
        File backFile = await File(backgroundAssetPath).create();
        backFile.writeAsBytesSync(backgroundAssetAsList);
      }

      args = <String, dynamic>{
        "image": imageAssetName,
        "video": videoAssetName,
        "hashtag": hashtag,
        "link": link,
      };
    }
    final String? response = await _channel.invokeMethod(
      'shareFacebookWall',
      args,
    );
    return response;
  }

  static Future<String?> shareTwitter(String captionText,
      {List<String>? hashtags, String? url, String? trailingText}) async {
    Map<String, dynamic> args;
    String modifiedUrl;
    if (Platform.isAndroid) {
      modifiedUrl = Uri.parse(url ?? '').toString().replaceAll('#', "%23");
    } else {
      modifiedUrl = Uri.parse(url ?? '').toString();
    }
    if (hashtags != null && hashtags.isNotEmpty) {
      String tags = "";
      hashtags.forEach((f) {
        tags += ("%23" + f.toString() + " ").toString();
      });
      args = <String, dynamic>{
        "captionText": captionText + "\n" + tags.toString(),
        "url": modifiedUrl,
        "trailingText": trailingText ?? ''
      };
    } else {
      args = <String, dynamic>{
        "captionText": captionText + " ",
        "url": modifiedUrl,
        "trailingText": trailingText ?? ''
      };
    }
    final String? version = await _channel.invokeMethod('shareTwitter', args);
    return version;
  }

  static Future<String?> shareSms(String message,
      {String? url, String? trailingText}) async {
    Map<String, dynamic>? args;
    if (Platform.isIOS) {
      if (url == null) {
        args = <String, dynamic>{
          "message": message,
        };
      } else {
        args = <String, dynamic>{
          "message": message + " ",
          "urlLink": Uri.parse(url).toString(),
          "trailingText": trailingText
        };
      }
    } else if (Platform.isAndroid) {
      args = <String, dynamic>{
        "message": message + (url ?? '') + (trailingText ?? ''),
      };
    }
    final String? version = await _channel.invokeMethod('shareSms', args);
    return version;
  }

  static Future<bool?> copyToClipboard(content) async {
    final Map<String, String> args = <String, String>{
      "content": content.toString()
    };
    final bool? response = await _channel.invokeMethod('copyToClipboard', args);
    return response;
  }

  static Future<bool?> shareOptions(String contentText,
      {String? imagePath}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      args = <String, dynamic>{"image": imagePath, "content": contentText};
    } else {
      if (imagePath != null) {
        File file = File(imagePath);
        Uint8List bytes = file.readAsBytesSync();
        var imagedata = bytes.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        String imageName = 'stickerAsset.png';
        final Uint8List imageAsList = imagedata;
        final imageDataPath = '${tempDir.path}/$imageName';
        file = await File(imageDataPath).create();
        file.writeAsBytesSync(imageAsList);
        args = <String, dynamic>{"image": imageName, "content": contentText};
      } else {
        args = <String, dynamic>{"image": imagePath, "content": contentText};
      }
    }
    final bool? version = await _channel.invokeMethod('shareOptions', args);
    return version;
  }

  static Future<String?> shareWhatsapp(String content) async {
    final Map<String, dynamic> args = <String, dynamic>{"content": content};
    final String? version = await _channel.invokeMethod('shareWhatsapp', args);
    return version;
  }

  static Future<Map?> checkInstalledAppsForShare() async {
    final Map? apps = await _channel.invokeMethod('checkInstalledApps');
    return apps;
  }

  static Future<String?> shareTelegram(String content) async {
    final Map<String, dynamic> args = <String, dynamic>{"content": content};
    final String? version = await _channel.invokeMethod('shareTelegram', args);
    return version;
  }

// static Future<String> shareSlack() async {
//   final String version = await _channel.invokeMethod('shareSlack');
//   return version;
// }
}
