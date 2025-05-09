import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart'; // CodeEditorScreen
import 'package:file_selector/file_selector.dart';

class LaunchScreen extends StatefulWidget {
  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  final List<String> supportedExtensions = ['.java', '.py', '.js', '.txt'];
  List<FileSystemEntity> recentFiles = [];

  @override
  void initState() {
    super.initState();
    _loadRecentFiles();
  }

  // Function to get app directory in internal storage
  Future<Directory> _getAppDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory appDirectory = Directory('${appDocDir.path}/code_editor');

    if (!await appDirectory.exists()) {
      await appDirectory.create(recursive: true);
    }
    return appDirectory;
  }

  // Load the recent files (only 5 files)
  Future<void> _loadRecentFiles() async {
    final dir = await _getAppDirectory();
    final allFiles = dir.listSync()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    final filtered = allFiles.where((file) {
      final ext = '.' + file.path.split('.').last;
      return supportedExtensions.contains(ext);
    }).take(5).toList();

    setState(() {
      recentFiles = filtered;
    });
  }

  Future<void> _createNewFile(BuildContext context) async {
    final TextEditingController _nameController = TextEditingController();
    String selectedExtension = '.py'; // default selection

    final Map<String, String> languageOptions = {
      'Python': '.py',
      'Java': '.java',
      'JavaScript': '.js',
      'C': '.c',
      'C++': '.cpp',
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'File Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedExtension,
                items: languageOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedExtension = value;
                    });
                  }
                },
                decoration: InputDecoration(labelText: 'Language'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text('Create'),
              onPressed: () async {
                final name = _nameController.text.trim();

                if (name.isEmpty || !supportedExtensions.contains(selectedExtension)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Invalid name or unsupported extension'),
                  ));
                  return;
                }

                final dir = await _getAppDirectory();
                final filePath = '${dir.path}/$name$selectedExtension';
                final file = File(filePath);

                if (!await file.exists()) {
                  await file.create();
                }

                Navigator.pop(context);
                await _navigateToEditor(file);
              },
            ),
          ],
        );
      },
    );
  }

  // Open an existing file from app directory
  Future<void> _openExistingFile(BuildContext context) async {
    final dir = await _getAppDirectory();
    final files = dir.listSync();

    final filteredFiles = files.where((file) {
      final ext = '.' + file.path.split('.').last;
      return supportedExtensions.contains(ext);
    }).toList();

    if (filteredFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No supported files found.'),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select File'),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredFiles.length,
              itemBuilder: (context, index) {
                final file = filteredFiles[index];
                return ListTile(
                  title: Text(file.path.split('/').last),
                  onTap: () async {
                    Navigator.pop(context);
                    await _navigateToEditor(File(file.path));
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Open any file using file_selector
  Future<void> _openFileFromDirectory() async {
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'code files',
      extensions: ['py', 'java', 'js', 'txt'],
    );

    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);

    if (file == null) return; // User canceled

    final pickedFile = File(file.path);
    await _navigateToEditor(pickedFile);
  }

  // Navigate to CodeEditorScreen
  Future<void> _navigateToEditor(File file) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CodeEditorScreen(file: file),
      ),
    );
  }

  // Main Widget build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1e1e1e),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.code, size: 100, color: Colors.deepPurpleAccent),
              SizedBox(height: 20),
              Text(
                "Let's Code!",
                style: GoogleFonts.firaCode(
                    fontSize: 20, color: Colors.deepPurpleAccent),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("New File"),
                onPressed: () => _createNewFile(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.folder_open),
                label: Text("Open File"),
                onPressed: () => _openExistingFile(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Files",
                  style: GoogleFonts.firaCode(
                      fontSize: 16, color: Colors.deepPurpleAccent),
                ),
              ),
              SizedBox(height: 10),
              ...recentFiles.map((file) => ListTile(
                title: Text(
                  file.path.split('/').last,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _navigateToEditor(File(file.path)),
              )),
              if (recentFiles.length < 5)
                for (int i = recentFiles.length; i < 5; i++)
                  ListTile(
                    title: Text(
                      '-',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ListTile(
                title: Text(
                  "Open Directory...",
                  style: TextStyle(color: Colors.deepPurpleAccent),
                ),
                leading: Icon(Icons.folder_open, color: Colors.deepPurpleAccent),
                onTap: _openFileFromDirectory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
