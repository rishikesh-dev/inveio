import 'package:url_launcher/url_launcher.dart';

/// Opens the given [url] in the default browser.
///
/// Throws an [Exception] if the URL cannot be launched.
Future<void> openLink(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}
