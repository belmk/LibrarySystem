import 'package:elibrary_desktop/models/activity.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class ActivityProvider extends BaseProvider<Activity> {
  ActivityProvider() : super("Activity");

  @override
  Activity fromJson(data) => Activity.fromJson(data);
}