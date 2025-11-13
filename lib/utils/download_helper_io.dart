import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Cross-platform helper: on IO platforms write the file to temp and attempt to
/// open it using the platform's default handler. This matches the web
/// `downloadFile` API used by the admin screen.
Future<void> downloadFile(String filename, String content) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsString(content);

  // Try to open the file if possible. If it fails, silently continue.
  try {
    final uri = Uri.file(file.path);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    // No-op: opening is optional; file is saved to temp and path can be shown to user.
  }
}

Future<String> saveFileToTemp(String filename, String content) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsString(content);
  return file.path;
}
