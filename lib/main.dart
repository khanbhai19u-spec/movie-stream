import 'package:flutter/material.dart';

import 'models/media_item.dart';
import 'services/movie_service.dart';

void main() => runApp(const MyApp());

class AppColors {
  static const bg = Color(0xFF0E0F13);
  static const surface = Color(0xFF181A20);
  static const accent = Color(0xFF7C5CFF);
  static const textDim = Color(0xFF9AA0AE);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
      ),
      home: const HomeFeedPage(),
    );
  }
}

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  final _service = const MovieService();
  late Future<List<MediaItem>> _future;
  MediaType? _filter; // null = সব

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = _service.search('popular');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<MediaItem>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 48, color: AppColors.textDim),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => setState(_load),
                      child: const Text('আবার চেষ্টা করুন'),
                    ),
                  ],
                ),
              );
            }

            final all = snap.data!;
            final items = _filter == null
                ? all
                : all.where((e) => e.type == _filter).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: _Header()),
                const SliverToBoxAdapter(child: _SearchBar()),
                SliverToBoxAdapter(
                  child: _FilterChips(
                    selected: _filter,
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                ),
                if (all.isNotEmpty)
                  SliverToBoxAdapter(
                      child: _FeaturedCarousel(items: all.take(5).toList())),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text('সাম্প্রতিক',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _MediaCard(item: items[i]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text('Discover',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'খুঁজুন…',
          hintStyle: const TextStyle(color: AppColors.textDim),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textDim),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final MediaType? selected;
  final ValueChanged<MediaType?> onChanged;

  const _FilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <MediaType?, String>{
      null: 'সব',
      MediaType.video: 'ভিডিও',
      MediaType.audio: 'অডিও',
      MediaType.image: 'ছবি',
    };

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        children: options.entries.map((e) {
          final isOn = e.key == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value),
              selected: isOn,
              showCheckmark: false,
              selectedColor: AppColors.accent,
              backgroundColor: AppColors.surface,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              onSelected: (_) => onChanged(e.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FeaturedCarousel extends StatelessWidget {
  final List<MediaItem> items;

  const _FeaturedCarousel({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return Padding(
            padding: const EdgeInsets.only(left: 12, right: 4, top: 8, bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _Thumb(url: item.thumbnailUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xDD000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  final MediaItem item;

  const _MediaCard({required this.item});

  String? get _duration {
    final d = item.duration;
    if (d == null) return null;
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  IconData get _icon => switch (item.type) {
        MediaType.video => Icons.play_circle_outline_rounded,
        MediaType.audio => Icons.headphones_rounded,
        MediaType.image => Icons.image_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 96,
                  height: 72,
                  child: _Thumb(url: item.thumbnailUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(_icon, size: 16, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(item.type.name,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textDim)),
                        if (_duration != null) ...[
                          const SizedBox(width: 10),
                          Text(_duration!,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textDim)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textDim),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? url;

  const _Thumb({this.url});

  Widget get _placeholder => Container(
        color: const Color(0xFF23262F),
        child: const Icon(Icons.movie_outlined, color: AppColors.textDim),
      );

  @override
  Widget build(BuildContext context) {
    if (url == null) return _placeholder;
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _placeholder,
    );
  }
}
