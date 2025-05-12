import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:android_dev_final_project/models/book.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class BookService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
    required File coverImage,
  }) async {
    if (_auth.currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final String userId = _auth.currentUser!.uid;
    final String bookId = const Uuid().v4();
    
    // Upload book file to Firebase Storage
    final bookRef = _storage.ref().child('books/$bookId/${bookFile.path.split('/').last}');
    final bookUploadTask = bookRef.putFile(bookFile);
    final bookSnapshot = await bookUploadTask.whenComplete(() {});
    final String bookUrl = await bookSnapshot.ref.getDownloadURL();
    
    // Upload cover image to Firebase Storage
    final coverRef = _storage.ref().child('books/$bookId/cover.jpg');
    final coverUploadTask = coverRef.putFile(coverImage);
    final coverSnapshot = await coverUploadTask.whenComplete(() {});
    final String coverUrl = await coverSnapshot.ref.getDownloadURL();
    
    // Create book object
    final book = Book(
      id: bookId,
      title: title,
      author: author,
      description: description,
      coverUrl: coverUrl,
      fileUrl: bookUrl,
      ageGroup: ageGroup,
      uploadDate: DateTime.now(),
      uploadedBy: userId,
    );
    
    // Save book metadata to Firestore
    await _firestore.collection('books').doc(bookId).set(book.toMap());
    
    notifyListeners();
    return book;
  }
  
  // Download a book
  Future<File> downloadBook(Book book) async {
    if (_auth.currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${book.id}.pdf';
    final file = File(filePath);
    
    // Check if file already exists
    if (await file.exists()) {
      return file;
    }
    
    // Download file
    final response = await http.get(Uri.parse(book.fileUrl));
    await file.writeAsBytes(response.bodyBytes);
    
    // Update download count in Firestore
    await _firestore.collection('books').doc(book.id).update({
      'downloadCount': FieldValue.increment(1),
    });
    
    // Add to user's downloaded books
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'downloadedBooks': FieldValue.arrayUnion([book.id]),
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
    if (_auth.currentUser == null) {
      return [];
    }
    
    final userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    final userData = userDoc.data();
    
    if (userData == null || !userData.containsKey('downloadedBooks')) {
      return [];
    }
    
    final downloadedIds = List<String>.from(userData['downloadedBooks']);
    if (downloadedIds.isEmpty) {
      return [];
    }
    
    final booksSnapshot = await _firestore
        .collection('books')
        .where(FieldPath.documentId, whereIn: downloadedIds)
        .get();
    
    return booksSnapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
  }
  
  // Delete a book (admin or owner only)
  Future<void> deleteBook(String bookId) async {
    if (_auth.currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    final bookDoc = await _firestore.collection('books').doc(bookId).get();
    if (!bookDoc.exists) {
      throw Exception('Book not found');
    }
    
    final book = Book.fromMap(bookDoc.data()!, bookId);
    
    // Check if user is the uploader
    if (book.uploadedBy != _auth.currentUser!.uid) {
      throw Exception('Not authorized to delete this book');
    }
    
    // Delete book file and cover from Storage
    final bookRef = _storage.refFromURL(book.fileUrl);
    final coverRef = _storage.refFromURL(book.coverUrl);
    
    await bookRef.delete();
    await coverRef.delete();
    
    // Delete book document from Firestore
    await _firestore.collection('books').doc(bookId).delete();
    
    notifyListeners();
  }
}
