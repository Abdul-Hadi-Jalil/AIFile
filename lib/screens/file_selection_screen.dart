import 'package:aifile/screens/pdf_viewer_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileSelectionScreen extends StatelessWidget {
  const FileSelectionScreen({super.key});

  // This function is called when the user tap on the floating action button to select a file.
  // It navigates to the PDF Viewer screen and passes the selected file path.
  Future<void> _selectFile(BuildContext context) async {
    String selectedFilePath = "";
    final PlatformFile? file = await FilePicker.pickFile(
      allowedExtensions: ['pdf'],
    );

    // check if the user selected a file or canceled the file picker.
    if (file != null) {
      if (file.path != null && file.path!.isNotEmpty) {
        selectedFilePath = file.path!;

        // Check if the context is still mounted
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(filePath: selectedFilePath),
          ),
        );
      } else {
        // show a dialog to inform the user that the file path is invalid
        if (!context.mounted) return; // Check if the context is still mounted
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid File Path'),
            content: const Text('The selected file has an invalid path.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // user cancelled the file picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectFile(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
