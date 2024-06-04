import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notification',
          channelDescription: 'Notification channel for basic tests',
          importance: NotificationImportance.High,
          channelShowBadge: true,
        )
      ],
      debug: true
    );
  }

  static Future<void> showNotification({required String title, required String body, required String payload}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: {'imagePath': payload},
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN_IMAGE',
          label: 'Open Image',
          autoDismissible: true,
          actionType: ActionType.Default,
        )
      ],
    );
  }

  static int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}
