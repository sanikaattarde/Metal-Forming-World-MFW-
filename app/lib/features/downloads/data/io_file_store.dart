import 'dart:io';

import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/domain/download_ports.dart';

// Spike T-02.4: a FileStore on the device's file system. The app-private
// folder and the free-space reading wait for their plugins (DEP-49), so the
// caller passes the folder and, if it has one, a free-space reading.

/// [FileStore] in a folder, with partial files kept apart from complete ones.
final class IoFileStore implements FileStore {
  /// Creates the store in [root]. Without [freeSpace], free space is
  /// reported as unlimited, which is a spike shortcut.
  IoFileStore(this.root, {this._freeSpace});

  /// The store's folder.
  final Directory root;

  final Future<int> Function()? _freeSpace;

  static const int _noSpace = 28;

  Directory get _partials => Directory('${root.path}/partial');

  Directory get _complete => Directory('${root.path}/complete');

  File _partial(String name) => File('${_partials.path}/$name');

  @override
  Future<int> freeBytes() async =>
      await _freeSpace?.call() ?? 0x7fffffffffffffff;

  @override
  Future<int> partialLength(String name) async {
    final File file = _partial(name);
    return await file.exists() ? file.length() : 0;
  }

  @override
  Future<Result<void>> appendPartial(String name, List<int> chunk) async {
    try {
      await _partials.create(recursive: true);
      await _partial(name).writeAsBytes(chunk, mode: FileMode.append);
      return const Ok<void>(null);
    } on FileSystemException catch (error) {
      if (error.osError?.errorCode == _noSpace) {
        return const Err<void>(AppFailure(FailureCode.insufficientStorage));
      }
      return const Err<void>(AppFailure(FailureCode.unknown));
    }
  }

  @override
  Stream<List<int>> readPartial(String name) => _partial(name).openRead();

  @override
  Future<void> deletePartial(String name) async {
    final File file = _partial(name);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<Result<String>> promotePartial(
    String partialName,
    String fileName,
  ) async {
    final File file = _partial(partialName);
    if (!await file.exists()) {
      return const Err<String>(AppFailure(FailureCode.notFound));
    }
    await _complete.create(recursive: true);
    final File moved = await file.rename('${_complete.path}/$fileName');
    return Ok<String>(moved.path);
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
}
