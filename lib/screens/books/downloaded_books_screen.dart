import 'package:flutter/material.dart';
import 'package:android_dev_final_project/models/book.dart';
import 'package:android_dev_final_project/screens/books/book_detail_screen.dart';
import 'package:android_dev_final_project/services/book_service.dart';
import 'package:android_dev_final_project/widgets/book_card.dart';
import 'package:provider/provider.dart';

class DownloadedBooksScreen extends StatefulWidget {
  const DownloadedBooksScreen({super.key});

  @override
  State<DownloadedBooksScreen> createState() => _DownloadedBooksScreenState();
}

class _DownloadedBooksScreenState extends State<DownloadedBooksScreen> {
  List<Book> _downloadedBooks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDownloadedBooks();
  }

  Future<void> _loadDownloadedBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookService = Provider.of<BookService>(context, listen: false);
      final books = await bookService.getDownloadedBooks();
      
      setState(() {
        _downloadedBooks = books;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDownloadedBooks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    'Error: $_errorMessage',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                )
              : _downloadedBooks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_done_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No downloaded books',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your downloaded books will appear here',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _downloadedBooks.length,
                      itemBuilder: (context, index) {
                        final book = _downloadedBooks[index];
                        return BookCard(
                          book: book,
                          extension: bookExtensionToString(book.extension),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailScreen(book: book),
                              ),
                            ).then((_) => _loadDownloadedBooks());
                          },
                        );
                      },
                    ),
    );
  }
}
