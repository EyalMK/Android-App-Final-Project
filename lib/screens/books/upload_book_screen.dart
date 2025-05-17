import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_dev_final_project/services/book_service.dart';
import 'package:android_dev_final_project/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';

class UploadBookScreen extends StatefulWidget {
  final String ageGroup;

  const UploadBookScreen({
    super.key,
    required this.ageGroup,
  });

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _bookFile;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickBookFile() async {
    try {
      final XTypeGroup pdfTypeGroup = XTypeGroup(
        label: 'PDFs',
        extensions: ['pdf'],
        mimeTypes: ['application/pdf'],
      );

      final XFile? file = await openFile(
        acceptedTypeGroups: [pdfTypeGroup],
      );

      if (file != null) {
        setState(() {
          _bookFile = File(file.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _uploadBook() async {
    if (!_formKey.currentState!.validate()) return;

    if (_bookFile == null) {
      setState(() {
        _errorMessage = 'Please select a PDF file';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final bookService = Provider.of<BookService>(context, listen: false);

      await bookService.uploadBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        description: _descriptionController.text.trim(),
        ageGroup: widget.ageGroup,
        bookFile: _bookFile!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book uploaded successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error uploading book: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Book'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Upload a new book for ages ${widget.ageGroup}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Book file picker
                OutlinedButton.icon(
                  onPressed: _pickBookFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_bookFile != null
                      ? 'Selected: ${_bookFile!.path.split('/').last}'
                      : 'Select PDF File'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Book details form
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Book Title',
                    hintText: 'Enter the title of the book',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'Author',
                    hintText: 'Enter the author\'s name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an author';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter a description of the book',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Error message
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                // Upload button
                CustomButton(
                  text: 'Upload Book',
                  icon: Icons.cloud_upload,
                  isLoading: _isUploading,
                  onPressed: _uploadBook,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
