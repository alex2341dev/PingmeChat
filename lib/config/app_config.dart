import 'dart:ui';

import 'package:matrix/matrix.dart';

abstract class AppConfig {
  static String _applicationName = 'PingmeChat';
  static String get applicationName => _applicationName;
  static String? _applicationWelcomeMessage;
  static String? get applicationWelcomeMessage => _applicationWelcomeMessage;
  static String _defaultHomeserver = 'matrix.org';
  static String get defaultHomeserver => _defaultHomeserver;
  static double fontSizeFactor = 1;
  static const Color chatColor = primaryColor;
  static Color? colorSchemeSeed = primaryColor;
  static const double messageFontSize = 16.0;
  static const bool allowOtherHomeservers = true;
  static const bool enableRegistration = true;
  static const Color primaryColor = Color(0xFF5625BA);
  static const Color primaryColorLight = Color(0xFFCCBDEA);
  static const Color secondaryColor = Color(0xFF41a2bc);
  static String _privacyUrl =
      'https://github.com/exemple/pingmechat/blob/main/PRIVACY.md';
  static String get privacyUrl => _privacyUrl;
  static const String website = 'https://pingmechat.im';
  static const String enablePushTutorial =
      'https://github.com/exemple/pingmechat/wiki/Push-Notifications-without-Google-Services';
  static const String encryptionTutorial =
      'https://github.com/exemple/pingmechat/wiki/How-to-use-end-to-end-encryption-in-PingmeChat';
  static const String startChatTutorial =
      'https://github.com/exemple/pingmechat/wiki/How-to-Find-Users-in-PingmeChat';
  static const String appId = 'ichat.pingme.pingmechat.PingmeChat';
  static const String appOpenUrlScheme = 'chat.pingme.pingmechat';
  static String _webBaseUrl = 'https://pingmechat.im/web';
  static String get webBaseUrl => _webBaseUrl;
  static const String sourceCodeUrl = 'https://github.com/exemple/pingmechat';
  static const String supportUrl =
      'https://github.com/exemple/pingmechat/issues';
  static const String changelogUrl =
      'https://github.com/exemple/pingmechat/blob/main/CHANGELOG.md';
  static final Uri newIssueUrl = Uri(
    scheme: 'https',
    host: 'github.com',
    path: '/exemple/pingmechat/issues/new',
  );
  static bool renderHtml = true;
  static bool hideRedactedEvents = false;
  static bool hideUnknownEvents = true;
  static bool hideUnimportantStateEvents = true;
  static bool separateChatTypes = false;
  static bool autoplayImages = true;
  static bool sendTypingNotifications = true;
  static bool sendPublicReadReceipts = true;
  static bool swipeRightToLeftToReply = true;
  static bool autoStart = false;
  static bool? sendOnEnter;
  static bool showPresences = true;
  static bool experimentalVoip = false;
  static const bool hideTypingUsernames = false;
  static const bool hideAllStateEvents = false;
  static const String inviteLinkPrefix = 'https://matrix.to/#/';
  static const String deepLinkPrefix = 'chat.pingme.pingmechat://chat/';
  static const String schemePrefix = 'matrix:';
  static const String pushNotificationsChannelId = 'pingmechat_push';
  static const String pushNotificationsAppId = 'chat.pingme.pingmechat';
  static const String pushNotificationsPusherFormat = 'event_id_only';
  static const String emojiFontName = 'Noto Emoji';
  static const String emojiFontUrl =
      'https://github.com/googlefonts/noto-emoji/';
  static const double borderRadius = 18.0;
  static const double columnWidth = 360.0;
  static final Uri homeserverList = Uri(
    scheme: 'https',
    host: 'servers.joinmatrix.org',
    path: 'servers.json',
  );

  static const String updateServerUrl =
      "https://raw.githubusercontent.com/alex2341dev/PingmeChatInstallers/main";

  static void loadFromJson(Map<String, dynamic> json) {
    if (json['chat_color'] != null) {
      try {
        colorSchemeSeed = Color(json['chat_color']);
      } catch (e) {
        Logs().w(
          'Invalid color in config.json! Please make sure to define the color in this format: "0xffdd0000"',
          e,
        );
      }
    }
    if (json['application_name'] is String) {
      _applicationName = json['application_name'];
    }
    if (json['application_welcome_message'] is String) {
      _applicationWelcomeMessage = json['application_welcome_message'];
    }
    if (json['default_homeserver'] is String) {
      _defaultHomeserver = json['default_homeserver'];
    }
    if (json['privacy_url'] is String) {
      _privacyUrl = json['privacy_url'];
    }
    if (json['web_base_url'] is String) {
      _webBaseUrl = json['web_base_url'];
    }
    if (json['render_html'] is bool) {
      renderHtml = json['render_html'];
    }
    if (json['hide_redacted_events'] is bool) {
      hideRedactedEvents = json['hide_redacted_events'];
    }
    if (json['hide_unknown_events'] is bool) {
      hideUnknownEvents = json['hide_unknown_events'];
    }
  }
}
