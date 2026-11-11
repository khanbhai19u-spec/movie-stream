import 'dart:async';

import 'package:flutter/material.dart';

import '../core/repository.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/poster_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _repo = Repository();

  final _controller = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  String _query = '';
  List<String> _suggestions = [];
  final List<MediaItem> _items = [];
  int _page = 1;
  bool _hasMore = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    final q = text.trim();
    if (q.isEmpty) {
      setState(() {
        _query = '';
        _items.clear();
        _suggestions = [];
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final s = await _repo.suggest(q);
        if (mounted && _controller.text.trim() == q) {
          setState(() => _suggestions = s.take(8).toList());
        }
      } catch (_) {}
      _runSearch(q);
    });
  }

  Future<void> _runSearch(String q) async {
    setState(() {
      _query = q;
      _items.clear();
      _page = 1;
      _hasMore = false;
      _error = null;
      _loading = true;
    });
    try {
      final page = await _repo.search(q, page: 1);
      if (!mounted || q != _query) return;
      setState(() {
        _items.addAll(page.items);
        _hasMore = page.hasMore;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore || _query.isEmpty) return;
    final q = _query;
    setState(() => _loading = true);
    try {
      final page = await _repo.search(q, page: _page + 1);
      if (!mounted || q != _query) return;
      setState(() {
        _page += 1;
        _items.addAll(page.items);
        _hasMore = page.hasMore;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              onSubmitted: (v) {
                _debounce?.cancel();
                if (v.trim().isNotEmpty) _runSearch(v.trim());
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search movies & series',
                hintStyle: const TextStyle(color: FX.textDim),
                prefixIcon: const Icon(Icons.search_rounded, color: FX.cyan),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, color: FX.textDim),
                        onPressed: () {
                          _controller.clear();
                          _onChanged('');
                        },
                      ),
                filled: true,
                fillColor: FX.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: FX.blue, width: 1.4),
                ),
              ),
            ),
          ),
          if (_suggestions.isNotEmpty && _items.isEmpty && !_loading)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(_suggestions[i]),
                  backgroundColor: FX.surfaceHi,
                  side: BorderSide.none,
                  onPressed: () {
                    _controller.text = _suggestions[i];
                    _runSearch(_suggestions[i]);
                  },
                ),
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: FX.textDim)),
        ),
      );
    }
    if (_query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.travel_explore_rounded, size: 64, color: FX.surfaceHi),
            SizedBox(height: 12),
            Text('Find something to watch',
                style: TextStyle(color: FX.textDim, fontSize: 15)),
          ],
        ),
      );
    }
    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator(color: FX.cyan));
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text('No results', style: TextStyle(color: FX.textDim)),
      );
    }
    return GridView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemCount: _items.length + (_loading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= _items.length) {
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: FX.cyan),
            ),
          );
        }
        return PosterCard(item: _items[i], width: double.infinity, rank: null);
      },
    );
  }
}
