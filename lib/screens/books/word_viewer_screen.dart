import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
import 'package:docx_to_text/docx_to_text.dart';

class WordViewerScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const WordViewerScreen({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  State<WordViewerScreen> createState() => _WordViewerScreenState();
}

class _WordViewerScreenState extends State<WordViewerScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<String> _pages = [];
  List<Uint8List> _images = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadAndParseDoc();
  }

  Future<void> _loadAndParseDoc() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _pages = [];
      _images = [];
      _currentPage = 0;
    });

    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        setState(() {
          _errorMessage = 'Document file not found at: ${widget.filePath}';
          _isLoading = false;
        });
        return;
      }

      final bytes = await file.readAsBytes();

      // 1. Extract text
      final fullText = docxToText(bytes);
      // Split pages using "Page X" markers.
      final reg = RegExp(r'Page\s+\d+', multiLine: true);
      final matches = reg.allMatches(fullText);

      List<String> pages = [];
      int lastEnd = 0;
      for (final match in matches) {
        if (lastEnd != 0) {
          pages.add(fullText.substring(lastEnd, match.start).trim());
        }
        lastEnd = match.end;
      }
      pages.add(fullText.substring(lastEnd).trim());
      pages = pages.where((p) => p.isNotEmpty).toList();

      // 2. Extract images from word/media
      List<Uint8List> images = [];
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final f in archive.files) {
        if (f.name.startsWith('word/media/') &&
            (f.name.endsWith('.jpg') ||
                f.name.endsWith('.jpeg') ||
                f.name.endsWith('.png'))) {
          images.add(f.content as Uint8List);
        }
      }

      setState(() {
        _pages = pages;
        _images = images;
        _isLoading = false;
        _currentPage = 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error reading document: $e';
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
              const SizedBox(height: 24),
              Text(
                'Cannot Load Document',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadAndParseDoc,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (_pages.isEmpty) {
      content = const Center(child: Text("No pages found."));
    } else {
      // Show one page and, if image available, show that image
      content = Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      _pages[_currentPage],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    if (_currentPage < _images.length)
                      Image.memory(_images[_currentPage]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentPage > 0 ? _prevPage : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
                Text(
                  'Page ${_currentPage + 1} of ${_pages.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _currentPage < _pages.length - 1 ? _nextPage : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue.withOpacity(0.1),
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  'DOCX',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: content,
    );
  }
}
