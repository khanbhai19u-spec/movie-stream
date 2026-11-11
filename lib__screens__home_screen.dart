import 'package:flutter/material.dart';

import '../core/repository.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/logo.dart';
import '../widgets/section_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _repo = Repository();
  late Future<List<HomeSection>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.home();
  }

  Future<void> _reload() async {
    final f = _repo.home();
    setState(() => _future = f);
    await f.catchError((_) => <HomeSection>[]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HomeSection>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const _Loading();
        }
        if (snap.hasError) {
          return _ErrorView(message: '${snap.error}', onRetry: _reload);
        }
        final sections = snap.data ?? const [];
        if (sections.isEmpty) {
          return _ErrorView(message: 'No content found', onRetry: _reload);
        }

        final banner = sections.where((s) => s.isBanner).toList();
        final heroItems =
            (banner.isNotEmpty ? banner.first : sections.first).items.take(6).toList();
        final rows = sections.where((s) => !s.isBanner).toList();

        return Stack(
          children: [
            RefreshIndicator(
              color: FX.cyan,
              backgroundColor: FX.surface,
              onRefresh: _reload,
              edgeOffset: 80,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  HeroCarousel(items: heroItems),
                  for (final s in rows) SectionRow(section: s),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            // Floating top bar over the hero image.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
                  child: Row(
                    children: const [FlixoraLogo(size: 30), Spacer()],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FlixoraLogo(size: 52),
          SizedBox(height: 28),
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 3, color: FX.cyan),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: FX.textDim),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: FX.textDim),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(backgroundColor: FX.blue),
            ),
          ],
        ),
      ),
    );
  }
}
