import 'package:elibrary_mobile/models/subscription.dart';
import 'package:elibrary_mobile/providers/base_provider.dart';

class SubscriptionProvider extends BaseProvider<Subscription> {
  SubscriptionProvider() : super("Subscription");

  @override
  Subscription fromJson(data) => Subscription.fromJson(data);
  
}