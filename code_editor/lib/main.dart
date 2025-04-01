import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:highlight/languages/dart.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart'; // Ensure this import is correct
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/default.dart';
import 'package:highlight/languages/python.dart';

void main() {
  print(defaultTheme);
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyClass(),
  ));
}

class MyClass extends StatefulWidget {
  const MyClass({super.key});

  @override
  State<MyClass> createState() => _MyClassState();
}

class _MyClassState extends State<MyClass> {
  CodeController? _codeController; // Declare it here

  @override
  void initState() {
    super.initState();

    final source = "void main() {\n print(\"Hello, world!\");\n}";

    // Initialize the controller inside initState
    _codeController = CodeController(
      text: source,
      language: dart,
      // Apply theme properly
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Code Editor"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: CodeField(
            controller: _codeController!,
            textStyle: const TextStyle(fontFamily: 'SourceCode', fontSize: 20),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController?.dispose(); // Dispose the controller properly
    super.dispose();
  }
}
