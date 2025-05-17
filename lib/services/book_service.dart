import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:android_dev_final_project/models/book.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class BookService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
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
  
  // Upload a book
  Future<Book> uploadBook({
    required String title,
    required String author,
    required String description,
    required String ageGroup,
    required File bookFile,
  }) async {
    final String bookId = const Uuid().v4();

    final bookBytes = await bookFile.readAsBytes();
    final bookBase64 = base64Encode(bookBytes);
    
    // Create book object
    final book = Book(
      id: bookId,
      title: title,
      author: author,
      description: description,
      bookData: bookBase64,
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
    final filePath = '${directory.path}/${book.id}.pdf';
    final file = File(filePath);
    
    // Check if file already exists
    if (await file.exists()) {
      return file;
    }
    
    // Download file
    final doc = await FirebaseFirestore.instance.collection('books').doc(book.id).get();
    final bookBytes = base64Decode(doc['bookData']);
    await file.writeAsBytes(bookBytes);
    
    // Update download count in Firestore
    await _firestore.collection('books').doc(book.id).update({
      'downloadCount': FieldValue.increment(1),
    });

    // Update book object with cached status
    final updatedBook = book.copyWith(
      downloadCount: book.downloadCount + 1,
      isCached: true,
    );
    
    notifyListeners();
    return file;
  }
  
  // Get user's downloaded books
  Future<List<Book>> getDownloadedBooks() async {
    final booksSnapshot = await _firestore
        .collection('books')
        .get();
    
    return booksSnapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
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
