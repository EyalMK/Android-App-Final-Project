import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final List<String> favoriteBooks;
  final List<String> downloadedBooks;
  final DateTime createdAt;
  final DateTime lastLogin;

  AppUser({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.favoriteBooks = const [],
    this.downloadedBooks = const [],
    required this.createdAt,
    required this.lastLogin,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      phoneNumber: map['phoneNumber'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      favoriteBooks: List<String>.from(map['favoriteBooks'] ?? []),
      downloadedBooks: List<String>.from(map['downloadedBooks'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: (map['lastLogin'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'favoriteBooks': favoriteBooks,
      'downloadedBooks': downloadedBooks,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  AppUser copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    List<String>? favoriteBooks,
    List<String>? downloadedBooks,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteBooks: favoriteBooks ?? this.favoriteBooks,
      downloadedBooks: downloadedBooks ?? this.downloadedBooks,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
