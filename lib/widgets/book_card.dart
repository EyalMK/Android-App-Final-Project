import 'package:flutter/material.dart';
import 'package:android_dev_final_project/models/book.dart';
import 'package:android_dev_final_project/utils/theme.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final String extension;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.extension
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover with extension icon
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'book-cover-${book.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(book.coverUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Extension icon in top-right corner
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getExtensionColor(extension).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getExtensionIcon(extension),
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Book info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getAgeGroupColor(book.ageGroup),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.ageGroup,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Extension badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getExtensionColor(extension),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          extension.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (book.isCached)
                        const Icon(
                          Icons.download_done,
                          size: 16,
                          color: Colors.green,
                        ),
                    ],
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

  IconData _getExtensionIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
      case 'word':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getExtensionColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
      case 'word':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
