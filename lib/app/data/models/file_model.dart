class FileModel {
  final String id;
  final String name;
  final String path;
  final int size;
  final String type;
  final DateTime lastModified;
  final bool isDirectory;
  final String? url;
  final String? thumbnailUrl;

  FileModel({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.type,
    required this.lastModified,
    required this.isDirectory,
    this.url,
    this.thumbnailUrl,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      size: json['size'] as int,
      type: json['type'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
      isDirectory: json['isDirectory'] as bool,
      url: json['url'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'size': size,
      'type': type,
      'lastModified': lastModified.toIso8601String(),
      'isDirectory': isDirectory,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  FileModel copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    String? type,
    DateTime? lastModified,
    bool? isDirectory,
    String? url,
    String? thumbnailUrl,
  }) {
    return FileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      type: type ?? this.type,
      lastModified: lastModified ?? this.lastModified,
      isDirectory: isDirectory ?? this.isDirectory,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
} 