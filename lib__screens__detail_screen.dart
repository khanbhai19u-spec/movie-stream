import 'package:flutter/material.dart';

import '../core/repository.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/net_image.dart';
import '../widgets/poster_card.dart';
import 'player_screen.dart';

class DetailScreen extends StatefulWidget {
  final MediaItem item;

  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const _repo = Repository();

  late Future<MovieDetail> _future;
  int _season = 1;
  int _episode = 1;
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    _future = _repo.detail(widget.item);
  }

  Future<void> _play(MediaItem item) async {
    if (_resolving) return;
    setState(() => _resolving = true);
    try {
      final result = await _repo.streams(item, se: _season, ep: _episode);
      if (!mounted) return;
      if (result.links.isEmpty) {
        _toast('No streams available');
        return;
      }
      final link = result.links.length == 1
          ? result.links.first
          : await _pickQuality(result.links);
      if (link == null || !mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayerScreen(
            title: item.isSeries
                ? '${item.title}  S$_season·E$_episode'
                : item.title,
            link: link,
          ),
        ),
      );
    } catch (e) {
      _toast('$e');
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<StreamLink?> _pickQuality(List<StreamLink> links) {
    return showModalBottomSheet<StreamLink>(
      context: context,
      backgroundColor: FX.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Text('Choose quality',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            for (final l in links)
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: const Icon(Icons.play_circle_fill_rounded, color: FX.cyan),
                title: Text(l.label.isNotEmpty ? l.label : l.quality),
                subtitle: Text('${l.quality}  ·  ${l.kind.toUpperCase()}',
                    style: const TextStyle(color: FX.textDim, fontSize: 12)),
                onTap: () => Navigator.pop(ctx, l),
              ),
          ],
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, maxLines: 3, overflow: TextOverflow.ellipsis),
        behavior: SnackBarBehavior.floating,
        backgroundColor: FX.surfaceHi,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MovieDetail>(
        future: _future,
        builder: (context, snap) {
          // Show the basic item immediately; enrich once detail arrives.
          final detail = snap.data;
          final item = detail?.item ?? widget.item;
          return _content(item, detail, loading: !snap.hasData && !snap.hasError);
        },
      ),
    );
  }

  Widget _content(MediaItem item, MovieDetail? detail, {required bool loading}) {
    final seasons = detail?.seasons ?? const <Season>[];
    final currentSeason = seasons.where((s) => s.se == _season).isNotEmpty
        ? seasons.firstWhere((s) => s.se == _season)
        : (seasons.isNotEmpty ? seasons.first : null);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 360,
          backgroundColor: FX.bg,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                NetImage(item.wideImage),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.4, 1.0],
                      colors: [Color(0x00070B14), FX.bg],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RatingPill(item.rating),
                    for (final t in [item.year, item.durationLabel, item.country])
                      if (t.isNotEmpty)
                        Text(t,
                            style: const TextStyle(color: FX.textDim, fontSize: 13)),
                  ],
                ),
                if (item.genres.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final g in item.genres)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: FX.surfaceHi,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(g,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 22),
                _PlayButton(
                  resolving: _resolving,
                  label: item.isSeries ? 'Play S$_season · E$_episode' : 'Play',
                  onTap: () => _play(item),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('Overview',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                        color: FX.textDim, fontSize: 14, height: 1.55),
                  ),
                ],
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 28),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: FX.cyan),
                      ),
                    ),
                  ),
                if (seasons.isNotEmpty && currentSeason != null) ...[
                  const SizedBox(height: 26),
                  _SeasonPicker(
                    seasons: seasons,
                    season: currentSeason.se,
                    episode: _episode,
                    onSeason: (s) => setState(() {
                      _season = s;
                      _episode = 1;
                    }),
                    onEpisode: (e) => setState(() => _episode = e),
                  ),
                ],
                if (detail != null && detail.cast.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  const Text('Cast',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: detail.cast.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (_, i) {
                        final c = detail.cast[i];
                        return SizedBox(
                          width: 64,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: NetImage(
                                  c.avatarUrl,
                                  radius: BorderRadius.circular(28),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.name,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11, color: FX.textDim),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool resolving;
  final String label;
  final VoidCallback onTap;

  const _PlayButton(
      {required this.resolving, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: resolving ? null : onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: FX.gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: FX.blue.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: resolving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 26),
                  const SizedBox(width: 6),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
      ),
    );
  }
}

class _SeasonPicker extends StatelessWidget {
  final List<Season> seasons;
  final int season;
  final int episode;
  final ValueChanged<int> onSeason;
  final ValueChanged<int> onEpisode;

  const _SeasonPicker({
    required this.seasons,
    required this.season,
    required this.episode,
    required this.onSeason,
    required this.onEpisode,
  });

  @override
  Widget build(BuildContext context) {
    final current = seasons.firstWhere((s) => s.se == season);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Episodes',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: seasons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = seasons[i];
              return ChoiceChip(
                label: Text('Season ${s.se}'),
                selected: s.se == season,
                showCheckmark: false,
                selectedColor: FX.blue,
                backgroundColor: FX.surfaceHi,
                side: BorderSide.none,
                onSelected: (_) => onSeason(s.se),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in current.episodes)
              GestureDetector(
                onTap: () => onEpisode(e),
                child: Container(
                  width: 52,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: e == episode ? FX.gradient : null,
                    color: e == episode ? null : FX.surfaceHi,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$e',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
