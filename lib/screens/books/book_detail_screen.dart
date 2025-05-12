import 'dart:io';
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

  @override
  void initState() {
    super.initState();
    _checkIfDownloaded();
  }

  Future<void> _checkIfDownloaded() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${widget.book.id}.pdf';
    final file = File(filePath);
    
    setState(() {
      _isDownloaded = file.existsSync();
    });
  }

  Future<void> _downloadBook() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = null;
    });

    try {
      final bookService = Provider.of<BookService>(context, listen: false);
      final file = await bookService.downloadBook(widget.book);
      
      setState(() {
        _isDownloaded = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book downloaded successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _openBook() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${widget.book.id}.pdf';
    final file = File(filePath);
    
    if (await file.exists()) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(
              filePath: filePath,
              title: widget.book.title,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _isDownloaded = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book not found. Please download again.')),
        );
      }
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
                    image: DecorationImage(
                      image: NetworkImage(widget.book.coverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
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
                  
                  // Age group and upload date
                  Row(
                    children: [
                      Chip(
                        label: Text('Ages ${widget.book.ageGroup}'),
                        backgroundColor: _getAgeGroupColor(widget.book.ageGroup),
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Uploaded on ${DateFormat.yMMMd().format(widget.book.uploadDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ],
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
                  
                  // Download count
                  Row(
                    children: [
                      const Icon(Icons.download, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.book.downloadCount} downloads',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
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
}

