// This is the entry point of the application.
// It navigates to the File Selection screen when the app is launched.

import 'package:aifile/screens/file_selection_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AIFile());
}

class AIFile extends StatelessWidget {
  const AIFile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'AIFile', home: FileSelectionScreen());
  }
}
