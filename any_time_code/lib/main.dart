


import 'dart:convert';
import 'package:any_time_code/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

import 'launch_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(CodeRunnerApp());
}

class CodeRunnerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheCodeEditor',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1e1e1e),
        primaryColor: Colors.deepPurpleAccent,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class CodeEditorScreen extends StatefulWidget {
  @override
  _CodeEditorScreenState createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  final Map<String, String> defaultSnippets = {
    'python3': 'print("Hello, Python!")',
    'c': '#include <stdio.h>\nint main() { printf("Hello, C!\\n"); return 0; }',
    'cpp': '#include <iostream>\nint main() { std::cout << "Hello, C++!" << std::endl; return 0; }',
    'java': 'public class Main { public static void main(String[] args) { System.out.println("Hello, Java!"); } }',
    'javascript': 'console.log("Hello, JavaScript!");'
  };

  final TextEditingController _codeController = TextEditingController();
  String _selectedLanguage = 'python3';
  String _output = '';
  bool _isRunning = false;
  List<String> tabs = ['main'];
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
    _codeController.text = defaultSnippets[_selectedLanguage]!;
  }

  String _getFileExtension(String lang) {
    switch (lang) {
      case 'python3':
        return 'py';
      case 'c':
        return 'c';
      case 'cpp':
        return 'cpp';
      case 'java':
        return 'java';
      case 'javascript':
        return 'js';
      default:
        return 'txt';
    }
  }

  Future<void> _executeCode() async {
    setState(() {
      _isRunning = true;
      _output = '';
    });

    final url = Uri.parse('https://emkc.org/api/v2/piston/execute');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "language": _selectedLanguage,
        "version": "*",
        "files": [
          {
            "name": "main.${_getFileExtension(_selectedLanguage)}",
            "content": _codeController.text,
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        _output = json['run']['output'] ?? 'No output';
      });
    } else {
      setState(() {
        _output = 'Error: ${response.statusCode} - ${response.body}';
      });
    }

    setState(() {
      _isRunning = false;
    });
  }

  void _addNewTab() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2e2e2e),
          title: Text('New or Open File'),
          content: Text('Choose an option:'),
          actions: [
            TextButton(
              child: Text('New', style: TextStyle(color: Colors.deepPurpleAccent)),
              onPressed: () => Navigator.of(context).pop('new'),
            ),
            TextButton(
              child: Text('Open', style: TextStyle(color: Colors.deepPurpleAccent)),
              onPressed: () => Navigator.of(context).pop('open'),
            ),
          ],
        );
      },
    );

    if (choice == 'new') {
      setState(() {
        final newTabName = 'tab${tabs.length + 1}';
        tabs.add(newTabName);
        currentTab = tabs.length - 1;
        _codeController.text = defaultSnippets[_selectedLanguage]!;
      });
    } else if (choice == 'open') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Open file logic to be implemented')),
      );
    }
  }

  void _closeTab(int index) {
    if (tabs.length == 1) return;
    setState(() {
      tabs.removeAt(index);
      if (currentTab >= tabs.length) currentTab = tabs.length - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LaunchScreen()),
            );
          },
          child: Row(
            children: [
              Icon(Icons.code),
              SizedBox(width: 8),
              Text(
                "AnyTimeCode",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  // decoration: TextDecoration.underline, // Optional: visual hint
                ),
              ),
            ],
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: _isRunning ? null : _executeCode,
            tooltip: "Run Code",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.grey[850],
                value: _selectedLanguage,
                items: ['python3', 'c', 'cpp', 'javascript', 'java']
                    .map((lang) => DropdownMenuItem(
                  child: Text(lang),
                  value: lang,
                ))
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedLanguage = val!;
                  _codeController.text = defaultSnippets[_selectedLanguage]!;
                }),
              ),
            ),
          ),
        ],
        elevation: 4,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                ...tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final name = entry.value;
                  return GestureDetector(
                    onTap: () => setState(() => currentTab = index),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: currentTab == index ? Colors.deepPurple : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(name),
                          SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _closeTab(index),
                            child: Icon(Icons.close, size: 16),
                          )
                        ],
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: _addNewTab,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Icon(Icons.add, size: 20),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Card(
                color: Color(0xFF2e2e2e),
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _codeController,
                    maxLines: null,
                    expands: true,
                    style:
                    GoogleFonts.firaMono(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration.collapsed(
                      hintText: "Write your code here...",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              flex: 1,
              child: Card(
                color: Color(0xFF1b1b1b),
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Output:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        _isRunning
                            ? Center(child: CircularProgressIndicator())
                            : Container(
                          constraints: BoxConstraints(minHeight: 20),
                          width: double.infinity,
                          child: HighlightView(
                            _output,
                            language: 'bash',
                            theme: monokaiSublimeTheme,
                            padding: EdgeInsets.all(12),
                            textStyle: GoogleFonts.firaCode(
                                fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
