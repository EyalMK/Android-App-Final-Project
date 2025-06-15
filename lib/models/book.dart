import 'package:cloud_firestore/cloud_firestore.dart';

enum BookExtension { pdf, doc }

BookExtension bookExtensionFromString(String ext) {
  switch (ext.toLowerCase()) {
    case 'pdf':
      return BookExtension.pdf;
    case 'doc':
    case 'docx':
      return BookExtension.doc;
    default:
      throw ArgumentError('Unsupported file extension: $ext');
  }
}

String bookExtensionToString(BookExtension ext) {
  switch (ext) {
    case BookExtension.pdf:
      return 'pdf';
    case BookExtension.doc:
      return 'doc';
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String fileUrl;
  final BookExtension extension;
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
    required this.extension,
    required this.ageGroup,
    required this.uploadDate,
    this.downloadCount = 0,
    this.isCached = false,
  });

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    final fileUrl = map['fileUrl'] ?? '';
    final extStr = fileUrl.split('.').last.toLowerCase();
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      fileUrl: fileUrl,
      extension: bookExtensionFromString(extStr),
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
      'extension': bookExtensionToString(extension),
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
    BookExtension? extension,
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
      coverUrl: coverUrl ?? this.coverUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      extension: extension ?? this.extension,
      ageGroup: ageGroup ?? this.ageGroup,
      uploadDate: uploadDate ?? this.uploadDate,
      downloadCount: downloadCount ?? this.downloadCount,
      isCached: isCached ?? this.isCached,
    );
  }

  bool get isPdf => extension == BookExtension.pdf;
  bool get isWord => extension == BookExtension.doc;
}
