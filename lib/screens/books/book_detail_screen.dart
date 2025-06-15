import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:android_dev_final_project/models/book.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Map<String, bool> _isDownloading = {
    'pdf': false,
    'docx': false,
    };
  String? _message;

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }
        return status.isGranted;
      } else {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    }
    return false;
  }

  Future<void> _downloadFile(String url, String extension) async {
  setState(() {
    _isDownloading[extension] = true;
    _message = null;
  });

    try {
      if (!await _requestStoragePermission()) {
        setState(() {
          _message = 'Storage permission denied.';
        });
        return;
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final downloadsPath = "/storage/emulated/0/Download";
        final safeTitle = widget.book.title.replaceAll(' ', '_');
        final filePath = '$downloadsPath/$safeTitle.$extension';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        final exists = await file.exists();
        final size = await file.length();

        if (!exists || size == 0) {
          setState(() {
            _message = 'Download failed.';
          });
        } else {
          setState(() {
            _message = 'Book downloaded to: $filePath';
          });
          await OpenFilex.open(filePath);
        }
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _message = 'Download error: $e';
      });
    } finally {
      setState(() {
        _isDownloading[extension] = false;
      });
    }
  }

  Color _getAgeColor(String ageGroup) {
    switch (ageGroup) {
      case '0-4':
        return Colors.green;
      case '4-8':
        return Colors.blue;
      case '8-12':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(book.coverUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(book.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Text('By ${book.author}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 12),

            Row(
              children: [
                Chip(
                  label: Text('Ages ${book.ageGroup}'),
                  backgroundColor: _getAgeColor(book.ageGroup),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  'Uploaded on ${DateFormat.yMMMd().format(book.uploadDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text('Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(book.description, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),

            if (_message != null) ...[
              Text(
                _message!,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDownloading['docx'] == true
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              icon: const Icon(Icons.download),
              label: _isDownloading['docx'] == true
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Download Word'),
              onPressed: _isDownloading['docx'] == true
                  ? null
                  : () => _downloadFile(book.wordUrl, 'docx'),
            ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: _isDownloading['pdf'] == true
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Download PDF'),
              onPressed: _isDownloading['pdf'] == true
                  ? null
                  : () => _downloadFile(book.pdfUrl, 'pdf'),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
