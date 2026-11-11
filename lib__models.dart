/// Models matching SparkBoxCore's camelCase JSON payloads.
class MediaItem {
  final String id;
  final String title;
  final bool isSeries;
  final String detailPath;
  final String cover;
  final String backdrop;
  final String rating;
  final String year;
  final String genre;
  final String country;
  final String description;
  final int durationMin;
  final int subjectType;

  const MediaItem({
    required this.id,
    required this.title,
    this.isSeries = false,
    this.detailPath = '',
    this.cover = '',
    this.backdrop = '',
    this.rating = '',
    this.year = '',
    this.genre = '',
    this.country = '',
    this.description = '',
    this.durationMin = 0,
    this.subjectType = 1,
  });

  factory MediaItem.fromMap(Map<String, dynamic> m) => MediaItem(
        id: (m['id'] ?? '').toString(),
        title: (m['title'] ?? '').toString(),
        isSeries: m['isSeries'] == true,
        detailPath: (m['detailPath'] ?? '').toString(),
        cover: (m['cover'] ?? '').toString(),
        backdrop: (m['backdrop'] ?? '').toString(),
        rating: (m['rating'] ?? '').toString(),
        year: (m['year'] ?? '').toString(),
        genre: (m['genre'] ?? '').toString(),
        country: (m['country'] ?? '').toString(),
        description: (m['description'] ?? '').toString(),
        durationMin: (m['durationMin'] as num?)?.toInt() ?? 0,
        subjectType: (m['subjectType'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isSeries': isSeries,
        'detailPath': detailPath,
        'cover': cover,
        'backdrop': backdrop,
        'rating': rating,
        'year': year,
        'genre': genre,
        'country': country,
        'description': description,
        'durationMin': durationMin,
        'subjectType': subjectType,
      };

  /// Backdrop if available, otherwise the portrait cover.
  String get wideImage => backdrop.isNotEmpty ? backdrop : cover;

  List<String> get genres => genre
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  String get durationLabel {
    if (durationMin <= 0) return '';
    final h = durationMin ~/ 60;
    final m = durationMin % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }
}

class HomeSection {
  final String title;
  final List<MediaItem> items;
  final bool ranked;
  final bool isBanner;

  const HomeSection({
    required this.title,
    required this.items,
    this.ranked = false,
    this.isBanner = false,
  });

  factory HomeSection.fromMap(Map<String, dynamic> m) => HomeSection(
        title: (m['title'] ?? '').toString(),
        items: ((m['items'] as List?) ?? const [])
            .map((e) => MediaItem.fromMap(e as Map<String, dynamic>))
            .toList(),
        ranked: m['ranked'] == true,
        isBanner: m['isBanner'] == true,
      );
}

class Season {
  final int se;
  final int maxEp;
  final List<int> episodes;

  const Season({required this.se, required this.maxEp, required this.episodes});

  factory Season.fromMap(Map<String, dynamic> m) => Season(
        se: (m['se'] as num?)?.toInt() ?? 1,
        maxEp: (m['maxEp'] as num?)?.toInt() ?? 0,
        episodes: ((m['episodes'] as List?) ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
      );
}

class CastMember {
  final String name;
  final String avatarUrl;

  const CastMember({required this.name, required this.avatarUrl});

  factory CastMember.fromMap(Map<String, dynamic> m) => CastMember(
        name: (m['name'] ?? '').toString(),
        avatarUrl: (m['avatarUrl'] ?? '').toString(),
      );
}

class StreamLink {
  final String label;
  final String quality;
  final String url;
  final String kind;
  final Map<String, String> headers;

  const StreamLink({
    required this.label,
    required this.quality,
    required this.url,
    required this.kind,
    required this.headers,
  });

  factory StreamLink.fromMap(Map<String, dynamic> m) => StreamLink(
        label: (m['label'] ?? '').toString(),
        quality: (m['quality'] ?? '').toString(),
        url: (m['url'] ?? '').toString(),
        kind: (m['kind'] ?? '').toString(),
        headers: ((m['headers'] as Map?) ?? const {})
            .map((k, v) => MapEntry(k.toString(), v.toString())),
      );
}
