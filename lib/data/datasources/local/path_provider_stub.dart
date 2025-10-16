// Stub implementation for web platform
import 'dart:io';

class Directory {
  final String path;
  Directory(this.path);
}

Future<Directory> getApplicationDocumentsDirectory() async {
  // For web, we'll use a mock directory
  // In a real implementation, you might use IndexedDB or localStorage
  throw UnsupportedError('getApplicationDocumentsDirectory is not supported on web platform');
}

Future<Directory> getTemporaryDirectory() async {
  throw UnsupportedError('getTemporaryDirectory is not supported on web platform');
}
