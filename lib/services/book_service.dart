import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:android_dev_final_project/models/book.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class BookService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Age group constants
  static const String ageGroup04 = '0-4';
  static const String ageGroup48 = '4-8';
  static const String ageGroup812 = '8-12';

  // Get books by age group
  Stream<List<Book>> getBooksByAgeGroup(String ageGroup) {
    return _firestore
        .collection('books')
        .where('ageGroup', isEqualTo: ageGroup)
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // Download a book in a specific format ('pdf' or 'word')
  Future<File> downloadBook(Book book, {String format = 'pdf'}) async {
    if (format != 'pdf' && format != 'word') {
      throw ArgumentError("Unsupported format: $format. Use 'pdf' or 'word'.");
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileExtension = format == 'pdf' ? 'pdf' : 'docx';
    final filePath = '${directory.path}/${book.id}.$fileExtension';
    final file = File(filePath);

    // Check if file already exists
    if (await file.exists()) {
      return file;
    }

    // Fetch file URL from Firestore
    final doc = await _firestore.collection('books').doc(book.id).get();
    final String fileUrl = doc['${format}Url'];

    final response = await http.get(Uri.parse(fileUrl));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw HttpException("Failed to download $format file");
    }

    // Update download count in Firestore
    await _firestore.collection('books').doc(book.id).update({
      'downloadCount': FieldValue.increment(1),
    });

    notifyListeners();
    return file;
  }
}
