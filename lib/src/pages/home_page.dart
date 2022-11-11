import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_desktop_folder_picker/flutter_desktop_folder_picker.dart';
import 'package:flutter_images_resizer/src/controller/resizer.dart';
import 'package:image/image.dart' as image;
import 'package:skadi/skadi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ImageResizer resizer = ImageResizer();

  void onPickFolder() async {
    var folder = await FlutterDesktopFolderPicker.openFolderPickerDialog();
    if (folder != null) {
      resizer.setFolder(folder);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resizer"),
        actions: [
          IconButton(
            onPressed: onPickFolder,
            icon: const Icon(Icons.folder_open),
          ),
          IconButton(
            onPressed: () {
              resizer.clear();
              setState(() {});
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSetting(),
            const Divider(),
            Expanded(
              child: resizer.images.isEmpty
                  ? const Center(child: Text("No Images found"))
                  : GridView.builder(
                      itemCount: resizer.images.length,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {
                        return Image.file(
                          resizer.images[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
            SkadiAsyncButton(
              onPressed: resizer.folder != null
                  ? () async {
                      await compute<ImageResizer, void>(resize, resizer);
                    }
                  : null,
              child: const Text("Resize"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetting() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Folder: ${resizer.folder ?? ""}",
            style: const TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(
          width: 100,
          child: TextFormField(
            initialValue: "250",
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (value) {
              resizer.setSize(int.parse(value));
            },
            decoration: const InputDecoration(
              hintText: "Size",
              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SpaceX(32),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField<image.Interpolation>(
            value: resizer.interpolation,
            onChanged: (value) {
              resizer.setInterpolation(value);
            },
            items: [
              for (var item in image.Interpolation.values)
                DropdownMenuItem(
                  value: item,
                  child: Text(item.name),
                ),
            ],
            decoration: const InputDecoration(
              hintText: "Interpolation",
              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
