class NoteImage {
  const NoteImage({
    required this.id,
    required this.imageUrl,
    required this.fileSize,
    required this.checksum,
    required this.analysisStatus,
    required this.ocrText,
    required this.objectLabels,
    required this.uploadedAt,
  });

  final String id;
  final String imageUrl;
  final int fileSize;
  final String checksum;
  final String analysisStatus;
  final String ocrText;
  final List<String> objectLabels;
  final DateTime uploadedAt;

  factory NoteImage.fromJson(Map<String, dynamic> json) {
    return NoteImage(
      id: json['id'] as String,
      imageUrl: (json['image_url'] ?? '') as String,
      fileSize: json['file_size'] as int,
      checksum: json['checksum'] as String,
      analysisStatus: json['analysis_status'] as String,
      ocrText: (json['ocr_text'] ?? '') as String,
      objectLabels: (json['object_labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }
}

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.image,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NoteImage? image;

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      body: (json['body'] ?? '') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      image: json['image'] != null
          ? NoteImage.fromJson(json['image'] as Map<String, dynamic>)
          : null,
    );
  }
}
