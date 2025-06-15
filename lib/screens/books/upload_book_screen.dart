import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_dev_final_project/services/book_service.dart';
import 'package:android_dev_final_project/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';

class UploadBookScreen extends StatefulWidget {
  final String ageGroup;
  final String extension;

  const UploadBookScreen({
    super.key,
    required this.ageGroup,
    required this.extension
  });

  @override
  State<UploadBookScreen> createState() => _UploadBookScreenState();
}

class _UploadBookScreenState extends State<UploadBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  ScaffoldMessengerState? _scaffoldMessenger;

  File? _bookFile;
  File? _coverImage;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to ScaffoldMessenger for safe disposal
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    // Use the saved reference instead of context lookup
    try {
      _scaffoldMessenger?.clearSnackBars();
    } catch (e) {
      // Ignore errors during disposal
    }
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickBookFile() async {
    try {
      XTypeGroup typeGroup;

      if (widget.extension.toLowerCase() == 'pdf') {
        typeGroup = const XTypeGroup(
          label: 'PDF Files',
          extensions: ['pdf'],
          mimeTypes: ['application/pdf'],
        );
      } else {
        // For DOC/DOCX files
        typeGroup = const XTypeGroup(
          label: 'Word Documents',
          extensions: ['doc', 'docx'],
          mimeTypes: [
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          ],
        );
      }

      final XFile? file = await openFile(
        acceptedTypeGroups: [typeGroup],
      );

      if (file != null) {
        // Validate file extension
        final fileName = file.name.toLowerCase();
        final isValidFile = widget.extension.toLowerCase() == 'pdf'
            ? fileName.endsWith('.pdf')
            : (fileName.endsWith('.doc') || fileName.endsWith('.docx'));

        if (!isValidFile) {
          setState(() {
            _errorMessage = 'Please select a valid ${widget.extension.toUpperCase()} file';
          });
          return;
        }

        setState(() {
          _bookFile = File(file.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _uploadBook() async {
    if (!_formKey.currentState!.validate()) return;

    if (_bookFile == null) {
      setState(() {
        _errorMessage = 'Please select a ${widget.extension.toUpperCase()} file';
      });
      return;
    }

    if (_coverImage == null) {
      setState(() {
        _errorMessage = 'Please select a cover image';
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
        coverImage: _coverImage!
      );

      if (mounted) {
        // Just navigate back with success result
        Navigator.pop(context, {
          'success': true,
          'message': '${widget.extension.toUpperCase()} book uploaded successfully'
        });
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

  String get _fileTypeDisplayName {
    return widget.extension.toLowerCase() == 'pdf' ? 'PDF' : 'Word Document';
  }

  IconData get _fileTypeIcon {
    return widget.extension.toLowerCase() == 'pdf'
        ? Icons.picture_as_pdf
        : Icons.description;
  }

  Color get _fileTypeColor {
    return widget.extension.toLowerCase() == 'pdf'
        ? Colors.red
        : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload ${_fileTypeDisplayName}'),
        backgroundColor: _fileTypeColor.withOpacity(0.1),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with file type indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _fileTypeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _fileTypeColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _fileTypeIcon,
                        size: 32,
                        color: _fileTypeColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload ${_fileTypeDisplayName}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _fileTypeColor,
                              ),
                            ),
                            Text(
                              'For ages ${widget.ageGroup}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _fileTypeColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Cover image picker
                GestureDetector(
                  onTap: _pickCoverImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      ),
                      image: _coverImage != null
                          ? DecorationImage(
                        image: FileImage(_coverImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _coverImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Cover Image',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Book file picker
                OutlinedButton.icon(
                  onPressed: _pickBookFile,
                  icon: Icon(_fileTypeIcon, color: _fileTypeColor),
                  label: Text(_bookFile != null
                      ? 'Selected: ${_bookFile!.path.split('/').last}'
                      : 'Select ${_fileTypeDisplayName} File'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: _fileTypeColor.withOpacity(0.5)),
                    foregroundColor: _fileTypeColor,
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Upload button
                CustomButton(
                  text: 'Upload ${_fileTypeDisplayName}',
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
