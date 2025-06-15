import 'dart:io';
import 'package:android_dev_final_project/screens/books/word_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:android_dev_final_project/utils/theme.dart';
import 'package:android_dev_final_project/models/book.dart';
import 'package:android_dev_final_project/screens/books/pdf_viewer_screen.dart';
import 'package:android_dev_final_project/services/book_service.dart';
import 'package:android_dev_final_project/widgets/custom_button.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isDownloading = false;
  bool _isDownloaded = false;
  String? _errorMessage;
  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _checkIfDownloaded();
  }

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
    super.dispose();
  }

  Future<void> _checkIfDownloaded() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${widget.book.id}.${bookExtensionToString(widget.book.extension)}';
      final file = File(filePath);

      if (mounted) {
        setState(() {
          _isDownloaded = file.existsSync();
        });
      }
    } catch (e) {
      // Handle error silently or log it
      if (mounted) {
        setState(() {
          _errorMessage = 'Error checking download status';
        });
      }
    }
  }

  Future<void> _downloadBook() async {
    if (!mounted) return;

    setState(() {
      _isDownloading = true;
      _errorMessage = null;
    });

    try {
      final bookService = Provider.of<BookService>(context, listen: false);
      await bookService.downloadBook(widget.book);

      if (mounted) {
        setState(() {
          _isDownloaded = true;
        });

        // Use the helper method for safe SnackBar display
        _showSnackBarSafely(
          'Book downloaded successfully',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _openBook() async {
    if (!mounted) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${widget.book.id}.${bookExtensionToString(widget.book.extension)}';
      final file = File(filePath);

      if (await file.exists()) {
        if (!mounted) return;

        if (widget.book.extension == BookExtension.pdf) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                filePath: filePath,
                title: widget.book.title,
              ),
            ),
          );
        } else if (widget.book.extension == BookExtension.doc) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordViewerScreen(
                filePath: filePath,
                title: widget.book.title,
              ),
            ),
          );
        } else {
          _showSnackBarSafely(
            'This book format is not supported for viewing',
            backgroundColor: Colors.orange,
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isDownloaded = false;
          });

          _showSnackBarSafely(
            'Book not found. Please download again.',
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBarSafely(
          'Error opening book: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _showSnackBarSafely(String message, {Color? backgroundColor}) {
    if (!mounted) return;

    try {
      // Clear existing snackbars and show new one
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: backgroundColor,
        ),
      );
    } catch (e) {
      // If SnackBar fails, just ignore it
      debugPrint('Failed to show SnackBar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book cover
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Hero(
                tag: 'book-cover-${widget.book.id}',
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    image: widget.book.coverUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(widget.book.coverUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        // Handle image loading error silently
                      },
                    )
                        : null,
                  ),
                  child: widget.book.coverUrl.isEmpty
                      ? const Center(
                    child: Icon(
                      Icons.book,
                      size: 64,
                      color: Colors.grey,
                    ),
                  )
                      : null,
                ),
              ),
            ),

            // Book details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${widget.book.author}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Age group, file type, and upload date
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text('Ages ${widget.book.ageGroup}'),
                        backgroundColor: _getAgeGroupColor(widget.book.ageGroup),
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(bookExtensionToString(widget.book.extension).toUpperCase()),
                        backgroundColor: _getExtensionColor(widget.book.extension),
                        avatar: Icon(
                          _getExtensionIcon(widget.book.extension),
                          color: Colors.white,
                          size: 18,
                        ),
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uploaded on ${DateFormat.yMMMd().format(widget.book.uploadDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),

                  // Download count and file info
                  Row(
                    children: [
                      const Icon(Icons.download, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.book.downloadCount} downloads',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      if (_isDownloaded)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.download_done, size: 16, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'Downloaded',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

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

                  // Download or Read button
                  CustomButton(
                    text: _isDownloaded ? 'Read Book' : 'Download Book',
                    icon: _isDownloaded ? Icons.menu_book : Icons.download,
                    isLoading: _isDownloading,
                    onPressed: _isDownloaded ? _openBook : _downloadBook,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAgeGroupColor(String ageGroup) {
    switch (ageGroup) {
      case '0-4':
        return AppTheme.age04Color;
      case '4-8':
        return AppTheme.age48Color;
      case '8-12':
        return AppTheme.age812Color;
      default:
        return Colors.grey;
    }
  }

  Color _getExtensionColor(BookExtension extension) {
    switch (extension) {
      case BookExtension.pdf:
        return Colors.red;
      case BookExtension.doc:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getExtensionIcon(BookExtension extension) {
    switch (extension) {
      case BookExtension.pdf:
        return Icons.picture_as_pdf;
      case BookExtension.doc:
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}
