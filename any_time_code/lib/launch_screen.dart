
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main.dart';

class LaunchScreen extends StatelessWidget {
  void _proceed(BuildContext context, String choice) {
    // Optionally store choice
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CodeEditorScreen()),
    );
  }

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
                onPressed: () => _proceed(context, "new"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.folder_open),
                label: Text("Open File"),
                onPressed: () => _proceed(context, "open"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
