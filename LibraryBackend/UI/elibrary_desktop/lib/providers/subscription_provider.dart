import 'package:elibrary_desktop/models/subscription.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class SubscriptionProvider extends BaseProvider<Subscription> {
  SubscriptionProvider() : super("Subscription");

  @override
  Subscription fromJson(data) => Subscription.fromJson(data);
}