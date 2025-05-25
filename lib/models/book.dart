import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String fileUrl;
  final String ageGroup;
  final DateTime uploadDate;
  final int downloadCount;
  final bool isCached;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.fileUrl,
    required this.ageGroup,
    required this.uploadDate,
    this.downloadCount = 0,
    this.isCached = false,
  });

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      ageGroup: map['ageGroup'] ?? '',
      uploadDate: (map['uploadDate'] as Timestamp).toDate(),
      downloadCount: map['downloadCount'] ?? 0,
      isCached: map['isCached'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'fileUrl': fileUrl,
      'ageGroup': ageGroup,
      'uploadDate': uploadDate,
      'downloadCount': downloadCount,
      'isCached': isCached,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    String? fileUrl,
    String? ageGroup,
    DateTime? uploadDate,
    int? downloadCount,
    bool? isCached,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      ageGroup: ageGroup ?? this.ageGroup,
      uploadDate: uploadDate ?? this.uploadDate,
      downloadCount: downloadCount ?? this.downloadCount,
      isCached: isCached ?? this.isCached,
    );
  }
}
