import 'package:elibrary_mobile/models/notification.dart';
import 'package:elibrary_mobile/providers/base_provider.dart';

class NotificationProvider extends BaseProvider<Notification> {
  NotificationProvider() : super("Notification");

  @override
  Notification fromJson(data) => Notification.fromJson(data);
}