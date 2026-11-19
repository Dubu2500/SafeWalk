import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'user_provider.dart';

class PhotoProvider extends ChangeNotifier {
  PhotoProvider(
    this.auth, {
    ImagePicker? picker,
    Future<Directory> Function()? baseDir,
  }) : _picker = picker ?? ImagePicker(),
       _baseDir = baseDir ?? getApplicationDocumentsDirectory {
    auth.addListener(_authChanged);
    _authChanged();
  }

  final UserProvider auth;
  final ImagePicker _picker;
  final Future<Directory> Function() _baseDir;
  String? _uid;
  File? _photo;
  bool _disposed = false;

  File? get photo => _photo;

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void _authChanged() {
    final uid = auth.user?.uid;
    if (uid == _uid) return;
    _uid = uid;
    _photo = null;
    _emit();
    if (uid != null) unawaited(_loadPhoto(uid));
  }

  Future<Directory> _photoDir() async {
    final directory = await _baseDir();
    final photoDir = Directory('${directory.path}/ProfilePhotos');
    if (!(await photoDir.exists())) {
      await photoDir.create(recursive: true);
    }
    return photoDir;
  }

  Future<List<File>> _userFiles(String uid) async {
    final photoDir = await _photoDir();
    return photoDir
        .listSync()
        .whereType<File>()
        .where((file) => file.uri.pathSegments.last.startsWith('${uid}_'))
        .toList();
  }

  Future<void> _loadPhoto(String uid) async {
    final files = await _userFiles(uid);
    if (_disposed || uid != _uid) return;
    files.sort((a, b) => b.path.compareTo(a.path));
    _photo = files.isEmpty ? null : files.first;
    _emit();
  }

  Future<bool> pickFromGallery() async {
    final uid = _uid;
    if (uid == null) return false;
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (pickedFile == null) return false;
    final photoDir = await _photoDir();
    final oldFiles = await _userFiles(uid);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPhoto = await File(pickedFile.path)
        .copy('${photoDir.path}/${uid}_$timestamp.jpg');
    for (final file in oldFiles) {
      if (await file.exists()) await file.delete();
    }
    if (_disposed || uid != _uid) return true;
    _photo = newPhoto;
    _emit();
    return true;
  }

  Future<void> removePhoto() async {
    final uid = _uid;
    if (uid == null) return;
    for (final file in await _userFiles(uid)) {
      await file.delete();
    }
    _photo = null;
    _emit();
  }

  @override
  void dispose() {
    _disposed = true;
    auth.removeListener(_authChanged);
    super.dispose();
  }
}
