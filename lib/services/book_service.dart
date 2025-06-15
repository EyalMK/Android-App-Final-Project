import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:android_dev_final_project/models/book.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class BookService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  
  // Age group constants
  static const String ageGroup04 = '0-4';
  static const String ageGroup48 = '4-8';
  static const String ageGroup812 = '8-12';
  
  // Get books by age group and extension
  Stream<List<Book>> getBooksByAgeGroupAndExtension(String ageGroup, String extension) {
    return _firestore
        .collection('books')
        .where('ageGroup', isEqualTo: ageGroup)
        .where('extension', isEqualTo: extension)
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
    });
  }
  
  // Upload a book
  Future<Book> uploadBook({
    required String title,
    required String author,
    required String description,
    required String ageGroup,
    required File bookFile,
    required File coverImage,
  }) async {
    final String bookId = const Uuid().v4();

    // Upload book file and cover image to Supabase storage...
    final bookFileBytes = await bookFile.readAsBytes();
    final bookFileName = bookFile.path.split('/').last;
    final bookExtension = bookFileName.split('.').last.toLowerCase();

    final coverFileBytes = await coverImage.readAsBytes();
    final coverFileName = coverImage.path.split('/').last;

    await _supabase.storage
        .from('books')
        .uploadBinary(bookFileName, bookFileBytes,
        fileOptions: const FileOptions(upsert: true));

    await _supabase.storage
            .from('book-covers')
            .uploadBinary(coverFileName, coverFileBytes,
            fileOptions: const FileOptions(upsert: true));

    final bookUrl = _supabase.storage.from('books').getPublicUrl(bookFileName);
    final coverUrl = _supabase.storage.from('book-covers').getPublicUrl(coverFileName);

    // Create book object
    final book = Book(
      id: bookId,
      title: title,
      author: author,
      description: description,
      coverUrl: coverUrl,
      fileUrl: bookUrl,
      extension: bookExtensionFromString(bookExtension),
      ageGroup: ageGroup,
      uploadDate: DateTime.now(),
    );
    
    // Save book metadata to Firestore
    await _firestore.collection('books').doc(bookId).set(book.toMap());
    
    notifyListeners();
    return book;
  }
  
  // Download a book
  Future<File> downloadBook(Book book) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${book.id}.${bookExtensionToString(book.extension)}';
    final file = File(filePath);

    // Check if file already exists
    if (await file.exists()) {
      return file;
    }
    
    // Download file
    final doc = await FirebaseFirestore.instance.collection('books').doc(book.id).get();
    final String bookUrl = doc['fileUrl'];

    final bookResponse = await http.get(Uri.parse(bookUrl));
    if (bookResponse.statusCode == 200) {
      await file.writeAsBytes(bookResponse.bodyBytes);
    } else {
      throw HttpException("Failed to download book");
    }

    // Update download count in Firestore
    await _firestore.collection('books').doc(book.id).update({
      'downloadCount': FieldValue.increment(1),
    });
    
    notifyListeners();
    return file;
  }
  
  // Get user's downloaded books
  Future<List<Book>> getDownloadedBooks() async {
    final booksSnapshot = await _firestore
        .collection('books')
        .get();

    final directory = await getApplicationDocumentsDirectory();

    final downloadedBooks = <Book>[];

    for (final doc in booksSnapshot.docs) {
      final book = Book.fromMap(doc.data(), doc.id);
      final filePath = '${directory.path}/${book.id}.${bookExtensionToString(book.extension)}';
      final file = File(filePath);

      if (await file.exists()) {
        downloadedBooks.add(book);
      }
    }

    return downloadedBooks;
  }
  
  // Delete a book (admin or owner only)
  Future<void> deleteBook(String bookId) async {
    final bookDoc = await _firestore.collection('books').doc(bookId).get();
    if (!bookDoc.exists) {
      throw Exception('Book not found');
    }

    // Delete book document from Firestore
    await _firestore.collection('books').doc(bookId).delete();
    
    notifyListeners();
  }
}
