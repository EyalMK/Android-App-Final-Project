import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PDFViewController _controller;
  int _pages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_isReady)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  'Page ${_currentPage + 1} of $_pages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: 0,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                _pages = pages!;
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                _errorMessage = 'Error loading page $page: $error';
              });
            },
            onViewCreated: (PDFViewController controller) {
              _controller = controller;
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page!;
              });
            },
          ),
          if (!_isReady && _errorMessage.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage.isNotEmpty)
            Center(
              child: Text(
                'Error: $_errorMessage',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (_isReady && _currentPage > 0)
            FloatingActionButton.small(
              heroTag: 'prev',
              onPressed: _currentPage > 0
                  ? () {
                _controller.setPage(_currentPage - 1);
              }
                  : null,
              child: const Icon(Icons.arrow_back),
            ),
          const SizedBox(width: 16),
          if (_isReady && _currentPage < _pages - 1)
            FloatingActionButton.small(
              heroTag: 'next',
              onPressed: _currentPage < _pages - 1
                  ? () {
                _controller.setPage(_currentPage + 1);
              }
                  : null,
              child: const Icon(Icons.arrow_forward),
            ),
        ],
      ),
    );
  }
}