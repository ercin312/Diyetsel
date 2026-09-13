import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

class LegalLinks {
  static Future<void> open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> privacy() => open(AppConstants.privacyUrl);
  static Future<void> support() => open(AppConstants.supportUrl);
  static Future<void> terms() => open(AppConstants.termsUrl);

  static Future<void> mailSupport() async {
    await launchUrl(Uri.parse('mailto:${AppConstants.supportEmail}'));
  }
}
