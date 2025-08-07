import 'package:elibrary_desktop/models/role.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class RoleProvider extends BaseProvider<Role> {
  RoleProvider() : super("Role");

  @override
  Role fromJson(data) => Role.fromJson(data);
}