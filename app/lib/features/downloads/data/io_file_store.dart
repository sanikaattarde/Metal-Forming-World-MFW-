import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../domain/download_ports.dart';

/// Where issue files live and how much space is free, from the platform
/// (`CODING_STANDARDS.md` section 8.2): Android's no-backup app storage,
/// and iOS's Application Support directory excluded from backups. The
/// channel is set up in `MainActivity.kt` and `AppDelegate.swift`.
abstract interface class IssueStorage {
  /// The folder that holds complete and partial issue files.
  Future<Directory> issueDirectory();

  /// Free space on the volume of [directory], in bytes.
  Future<int> freeBytes(Directory directory);
}

/// [IssueStorage] over the `mfw/storage` platform channel.
final class PlatformIssueStorage implements IssueStorage {
  /// Creates the storage.
  PlatformIssueStorage([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('mfw/storage');

  final MethodChannel _channel;
  Future<Directory>? _directory;

  @override
  Future<Directory> issueDirectory() => _directory ??= _channel
      .invokeMethod<String>('issueDirectory')
      .then((String? path) {
        if (path == null) {
          throw const FileSystemException('no issue directory');
        }
        return Directory(path);
      })
      .catchError((Object error) {
        _directory = null;
        throw error;
      });

  @override
  Future<int> freeBytes(Directory directory) async =>
      await _channel.invokeMethod<int>('freeBytes', directory.path) ?? 0;
}

/// The [FileStore] on the device's file system, in [IssueStorage]'s folder.
///
/// Complete files sit in the folder itself and partial ones in its
/// `partial` folder, so a partial file is never taken for a copy (section
/// 8.2 item 2). A partial file stays open for appending while a download
/// runs, and is closed before it is read, moved or deleted.
final class IoFileStore implements FileStore {
  /// Creates the store over [storage].
  IoFileStore(this._storage);

  final IssueStorage _storage;
  final Map<String, RandomAccessFile> _open = <String, RandomAccessFile>{};

  /// The error number of "no space left on device" on Android and iOS.
  static const int _noSpace = 28;

  Future<Directory> _partialDirectory() async {
    final Directory partial = Directory(
      '${(await _storage.issueDirectory()).path}/partial',
    );
    await partial.create(recursive: true);
    return partial;
  }

  Future<File> _partial(String name) async =>
      File('${(await _partialDirectory()).path}/$name');

  Future<void> _close(String name) async {
    final RandomAccessFile? file = _open.remove(name);
    await file?.close();
  }

  @override
  Future<int> freeBytes() async =>
      _storage.freeBytes(await _storage.issueDirectory());

  @override
  Future<int> partialLength(String name) async {
    final File file = await _partial(name);
    return await file.exists() ? file.length() : 0;
  }

  @override
  Future<Result<void>> appendPartial(String name, List<int> chunk) async {
    try {
      final RandomAccessFile file = _open[name] ??= await (await _partial(name))
          .open(mode: FileMode.append);
      await file.writeFrom(chunk);
      return const Ok<void>(null);
    } on FileSystemException catch (error) {
      await _close(name);
      return Err<void>(
        error.osError?.errorCode == _noSpace
            ? const AppFailure(FailureCode.insufficientStorage)
            : const AppFailure(FailureCode.unknown, detail: 'write failed'),
      );
    }
  }

  @override
  Stream<List<int>> readPartial(String name) async* {
    await _close(name);
    yield* (await _partial(name)).openRead();
  }

  @override
  Future<void> deletePartial(String name) async {
    await _close(name);
    final File file = await _partial(name);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<List<String>> partialFiles() async {
    final List<String> names = <String>[];
    await for (final FileSystemEntity entity
        in (await _partialDirectory()).list()) {
      if (entity is File) {
        names.add(entity.path.substring(entity.path.lastIndexOf('/') + 1));
      }
    }
    return names;
  }

  @override
  Future<Result<String>> promotePartial(
    String partialName,
    String fileName,
  ) async {
    await _close(partialName);
    try {
      final File moved = await (await _partial(partialName))
          .rename('${(await _storage.issueDirectory()).path}/$fileName');
      return Ok<String>(moved.path);
    } on FileSystemException {
      return const Err<String>(
        AppFailure(FailureCode.unknown, detail: 'move failed'),
      );
    }
  }

  @override
  Future<int?> fileLength(String path) async {
    final File file = File(path);
    return await file.exists() ? file.length() : null;
  }

  @override
  Future<void> deleteFile(String path) async {
    final File file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<List<String>> completeFiles() async {
    final Directory directory = await _storage.issueDirectory();
    final List<String> files = <String>[];
    await for (final FileSystemEntity entity in directory.list()) {
      if (entity is File && entity.path.endsWith('.pdf')) {
        files.add(entity.path);
      }
    }
    return files;
  }
}
