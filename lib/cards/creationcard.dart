import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../models/cardmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CreationCard extends StatefulWidget {
  const CreationCard({super.key, required this.model});

  final CardModel model;

  @override
  State<CreationCard> createState() => _CreationCardState();
}

class _CreationCardState extends State<CreationCard> {
  late TextEditingController termController;
  late TextEditingController defController;

  @override
  void initState() {
    super.initState();

    termController = TextEditingController(text: widget.model.term)
      ..addListener(() {
        setState(() {
          widget.model.term = termController.text;
        });
      });
    defController = TextEditingController(text: widget.model.definition)
      ..addListener(() {
        setState(() {
          widget.model.definition = defController.text;
        });
      });
  }

  @override
  void dispose() {
    termController.dispose();
    defController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Term
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(label: Text('Term')),
                controller: termController,
              ),
            ),
            Flexible(
              child: widget.model.termImagePath == null
                  ? ElevatedButton.icon(
                      onPressed: () => _pickImage(true),
                      label: const Text('Add image'))
                  : imageWidget(true),
            ),
          ],
        ),

        //Definition
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(label: Text('Definition')),
                controller: defController,
              ),
            ),
            Flexible(
              child: widget.model.defImagePath == null
                  ? ElevatedButton.icon(
                      onPressed: () => _pickImage(false),
                      label: const Text('Add image'))
                  : imageWidget(false),
            )
          ],
        ),
      ],
    );
  }

  // Pulls up a view where you can select camera or gallery
  Future<void> _pickImage(bool isTerm) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _getImage(ImageSource.camera, isTerm);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _getImage(ImageSource.gallery, isTerm);
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Get image from the chosen source
  Future<void> _getImage(ImageSource source, bool isTerm) async {
    final pickedFile = await _pickAndSaveImage(source);

    if (pickedFile == null) return; // user canceled
    final savedFilename = await _saveImagePermanently(pickedFile);

    setState(() {
      if (isTerm) {
        widget.model.termImagePath = savedFilename;
        debugPrint("📸 Term image path: $savedFilename");
      } else {
        widget.model.defImagePath = savedFilename;
        debugPrint("📸 Def image path: $savedFilename");
      }
      debugPrint("File exists: ${File(savedFilename).existsSync()}");
    });
  }

// Pass the source 
  Future<XFile?> _pickAndSaveImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    return pickedFile; 
  }

// Save to app documents dir (persistent)
  Future<String> _saveImagePermanently(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = DateTime.now().millisecondsSinceEpoch.toString();
    final filename = "$name.jpg";
    final newPath = '${directory.path}/$name.jpg';
    debugPrint("Picked path: ${image.path}");
    debugPrint("Exists before copy: ${await File(image.path).exists()}");
    
    
    await File(image.path).copy(newPath);

    return filename;
  }

// Remove image
 Future<void> _removeImage(bool isTerm) async {
  final filename = isTerm ? widget.model.termImagePath : widget.model.defImagePath;

  if (filename != null) {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    if (await file.exists()) {
      try {
        await file.delete();
        debugPrint("🗑️ Deleted image file: $filename");
      } catch (e) {
        debugPrint("⚠️ Failed to delete image: $e");
      }
    }
  }

  setState(() {
    if (isTerm) {
      widget.model.termImagePath = null;
    } else {
      widget.model.defImagePath = null;
    }
  });
}

//reconstructs the path
Future<File?> _getImageFile(String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  return await file.exists() ? file : null;
}

// Display image
  Widget imageWidget(bool isTerm) {
    final filename =
        isTerm ? widget.model.termImagePath : widget.model.defImagePath;

    if (filename == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: _getImageFile(filename),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
      
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Remove Image"),
                  content: const Text("Do you want to remove this image?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeImage(isTerm);
                      },
                      child: const Text("Remove"),
                    ),
                  ],
                ),
              );
            },
            child: 
            !snapshot.hasData || snapshot.data == null
            ? Icon(Icons.broken_image, size: 50, color: Colors.white)
            :Image.file(
              snapshot.data!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 50, color: Colors.white),
            ),
          ),
        );
      }
    );
  }
}
