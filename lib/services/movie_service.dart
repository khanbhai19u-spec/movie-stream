import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import '../models/media_item.dart';

class MovieServiceException implements Exception {
  final String message;
  const MovieServiceException(this.message);

  @override
  String toString() => 'MovieServiceException: $message';
}

DynamicLibrary _openCore() {
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('libmovie_core.so');
  }
  if (Platform.isWindows) return DynamicLibrary.open('movie_core.dll');
  if (Platform.isMacOS) return DynamicLibrary.open('libmovie_core.dylib');
  if (Platform.isIOS) return DynamicLibrary.process(); // static link
  throw UnsupportedError('Unsupported platform');
}

String _callCore(String symbol, String arg) {
  final lib = _openCore();

  final fn = lib.lookupFunction<Pointer<Utf8> Function(Pointer<Utf8>),
      Pointer<Utf8> Function(Pointer<Utf8>)>(symbol);
  final free = lib.lookupFunction<Void Function(Pointer<Utf8>),
      void Function(Pointer<Utf8>)>('movie_free_string');

  final argPtr = arg.toNativeUtf8();
  try {
    final resPtr = fn(argPtr);
    if (resPtr == nullptr) {
      throw const MovieServiceException('Core returned null');
    }
    try {
      return resPtr.toDartString();
    } finally {
      free(resPtr);
    }
  } finally {
    malloc.free(argPtr);
  }
}

class MovieService {
  const MovieService();

  Future<List<MediaItem>> search(String query) async {
    final raw = await Isolate.run(() => _callCore('movie_search_json', query));
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const MovieServiceException('Invalid search response');
    }
    return decoded
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MediaItem> getById(String id) async {
    final raw = await Isolate.run(() => _callCore('movie_get_json', id));
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const MovieServiceException('Invalid movie response');
    }
    return MediaItem.fromJson(decoded);
  }
}
