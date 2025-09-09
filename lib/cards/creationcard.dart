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
            widget.model.termImagePath == null
            ?ElevatedButton.icon(onPressed:() => _pickImage(true), label:const Text('Add image') )
            : imageWidget(true),
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
            widget.model.defImagePath == null
            ?ElevatedButton.icon(onPressed:() => _pickImage(false), label:const Text('Add image') )
            :imageWidget(false)
          ],
        ),
      ],
    );
  }
  
  //pulls up a view where you can select camera or gallery
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

  //to put in the get image from gallery 
  Future<void> _getImage(ImageSource source, bool isTerm) async {
  final imagePath = await _pickAndSaveImage();
  if (imagePath == null) return; // user canceled

  setState(() {
    if (isTerm) {
      widget.model.termImagePath = imagePath;
      debugPrint("Term image path: $imagePath");
    } else {
      widget.model.defImagePath = imagePath;
      debugPrint("Def image path: $imagePath");
    }
    debugPrint(File(imagePath).existsSync().toString());
  });
  }



  Future<String?> _pickAndSaveImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return null;

  final appDir = await getApplicationDocumentsDirectory();
  final fileName = path.basename(pickedFile.path);
  final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

  debugPrint("📸 Saved image at: ${savedImage.path}");
  return savedImage.path; // use this instead of pickedFile.path
  }

  Future<void> _removeImage(bool isTerm) async{
    setState(() {
      if(isTerm == true) {
        widget.model.termImagePath = null;
      }
      else {
        widget.model.defImagePath = null;
      }
    });
  }

  Widget imageWidget(bool isTerm){ 
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
                  child: Image.file(
                    File(
                      isTerm
                      ?widget.model.termImagePath!
                      :widget.model.defImagePath!
                    ), 
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
                    ),
                ),
    );
  }
}


