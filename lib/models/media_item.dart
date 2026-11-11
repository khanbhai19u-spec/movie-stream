enum MediaType { image, video, audio }

class MediaItem {
  final String id;
  final String title;
  final String url;
  final MediaType type;
  final String? thumbnailUrl;
  final Duration? duration;
  final DateTime createdAt;

  const MediaItem({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    this.thumbnailUrl,
    this.duration,
    required this.createdAt,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.image,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: json['durationSeconds'] != null
          ? Duration(seconds: json['durationSeconds'] as int)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'type': type.name,
        'thumbnailUrl': thumbnailUrl,
        'durationSeconds': duration?.inSeconds,
        'createdAt': createdAt.toIso8601String(),
      };

  MediaItem copyWith({
    String? id,
    String? title,
    String? url,
    MediaType? type,
    String? thumbnailUrl,
    Duration? duration,
    DateTime? createdAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      type: type ?? this.type,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItem &&
          other.id == id &&
          other.title == title &&
          other.url == url &&
          other.type == type &&
          other.thumbnailUrl == thumbnailUrl &&
          other.duration == duration &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      Object.hash(id, title, url, type, thumbnailUrl, duration, createdAt);

  @override
  String toString() => 'MediaItem(id: $id, title: $title, type: ${type.name})';
}
