import '../models.dart';
import 'sparkbox_core.dart';

class MovieDetail {
  final MediaItem item;
  final List<CastMember> cast;
  final List<Season> seasons;

  const MovieDetail({
    required this.item,
    required this.cast,
    required this.seasons,
  });
}

class SearchPage {
  final List<MediaItem> items;
  final bool hasMore;

  const SearchPage(this.items, this.hasMore);
}

class StreamResult {
  final List<StreamLink> links;
  final List<Map<String, dynamic>> subtitles;

  const StreamResult(this.links, this.subtitles);
}

/// Typed facade over [SparkBoxCore] (the Rust core behind FFI).
class Repository {
  const Repository();

  Future<List<HomeSection>> home() async {
    final raw = await SparkBoxCore.home();
    return raw.map(HomeSection.fromMap).where((s) => s.items.isNotEmpty).toList();
  }

  Future<List<String>> suggest(String query) => SparkBoxCore.suggest(query);

  Future<SearchPage> search(String query, {int page = 1}) async {
    final data = await SparkBoxCore.search(query, page: page);
    final items = ((data['items'] as List?) ?? const [])
        .map((e) => MediaItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return SearchPage(items, data['hasMore'] == true);
  }

  Future<MovieDetail> detail(MediaItem base) async {
    final data = await SparkBoxCore.detailRich(base.toMap());
    final item = data['item'] is Map<String, dynamic>
        ? MediaItem.fromMap(data['item'] as Map<String, dynamic>)
        : base;
    final cast = ((data['cast'] as List?) ?? const [])
        .map((e) => CastMember.fromMap(e as Map<String, dynamic>))
        .toList();

    var seasons = <Season>[];
    if (item.isSeries) {
      try {
        final raw = await SparkBoxCore.seasons(item.id);
        seasons = raw.map(Season.fromMap).toList();
      } catch (_) {
        // Seasons are optional; the page still works without them.
      }
    }
    return MovieDetail(item: item, cast: cast, seasons: seasons);
  }

  Future<StreamResult> streams(MediaItem item, {int se = 1, int ep = 1}) async {
    final detail = await SparkBoxCore.playDetail(item.toMap());
    final data = await SparkBoxCore.streams(detail, se, ep, item.isSeries);
    final links = ((data['links'] as List?) ?? const [])
        .map((e) => StreamLink.fromMap(e as Map<String, dynamic>))
        .toList();
    final subs =
        ((data['subtitles'] as List?) ?? const []).cast<Map<String, dynamic>>();
    return StreamResult(links, subs);
  }
}
