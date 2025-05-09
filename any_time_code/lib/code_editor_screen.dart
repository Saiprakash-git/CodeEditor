import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CodeEditorScreen extends StatefulWidget {
  final String filePath;

  CodeEditorScreen({required this.filePath});

  @override
  _CodeEditorScreenState createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  TextEditingController _controller = TextEditingController();
  late String currentFilePath;

  @override
  void initState() {
    super.initState();
    currentFilePath = widget.filePath;

    if (currentFilePath.isNotEmpty) {
      _loadFile();
    }
  }

  Future<void> _loadFile() async {
    try {
      final file = File(currentFilePath);
      if (await file.exists()) {
        String contents = await file.readAsString();
        _controller.text = contents;
      }
    } catch (e) {
      print("Error loading file: $e");
    }
  }

  Future<void> _saveFile() async {
    try {
      if (currentFilePath.isEmpty) {
        // If the file path is empty, create a new file
        final directory = await getApplicationDocumentsDirectory();
        final newFile = File('${directory.path}/new_file.txt');
        await newFile.writeAsString(_controller.text);
        setState(() {
          currentFilePath = newFile.path;
        });
      } else {
        final file = File(currentFilePath);
        await file.writeAsString(_controller.text);
      }
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentFilePath.isEmpty ? 'New File' : 'Editing: ${currentFilePath.split('/').last}'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveFile,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          controller: _controller,
          maxLines: null,
          decoration: InputDecoration(
            hintText: "Start typing your code...",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
  }
}
