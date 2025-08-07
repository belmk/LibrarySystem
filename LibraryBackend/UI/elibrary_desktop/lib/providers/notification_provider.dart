import 'package:elibrary_desktop/models/notification.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class NotificationProvider extends BaseProvider<Notification> {
  NotificationProvider() : super("Notification");

  @override
  Notification fromJson(data) => Notification.fromJson(data);
}