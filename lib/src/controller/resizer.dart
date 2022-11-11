import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart';

class ImageResizer {
  String? folder;
  Interpolation interpolation = Interpolation.average;
  int _size = 250;
  final List<File> images = [];

  void setFolder(String path) {
    folder = path;
    images.clear();
    Directory directory = Directory(path);
    for (var file in directory.listSync()) {
      if (file is File) {
        var fileExt = file.path.split(".").last;
        if (fileExt == "png" || fileExt == "jpg" || fileExt == "jpeg") {
          images.add(file);
        }
      }
    }
  }

  void clear() {
    folder = null;
    images.clear();
  }

  void setInterpolation(Interpolation? i) {
    if (i == null) return;
    interpolation = i;
  }

  void setSize(int size) {
    _size = size;
  }
}

void resize(ImageResizer resizer) async {
  int index = 1;
  Directory resizedDir = Directory("${resizer.folder}${Platform.pathSeparator}resized")..createSync();
  for (var file in [...resizer.images]) {
    var image = decodeImage(file.readAsBytesSync())!;
    var thumbnail = copyResize(
      image,
      width: resizer._size,
      interpolation: resizer.interpolation,
    );
    File resizedFile = File("${resizedDir.path}${Platform.pathSeparator}${file.uri.pathSegments.last}");
    await resizedFile.create(recursive: true);
    await resizedFile.writeAsBytes(encodePng(thumbnail, level: 8));
    debugPrint("$index/${resizer.images.length}: ${resizedFile.path}");
    index++;
  }
}
