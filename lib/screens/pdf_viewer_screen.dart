// When user select a pdf file from file selection screen,
// it navigates to this screen and display the selected pdf file.

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfViewerScreen extends StatelessWidget {
  final String filePath;
  const PdfViewerScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: PdfViewer.file(filePath));
  }
}
