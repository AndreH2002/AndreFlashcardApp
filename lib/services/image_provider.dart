import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageProvider extends ChangeNotifier{
  
  
  Future<File?> _getImageFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    return await file.exists() ? file : null;
  }
}