import 'package:elibrary_mobile/models/complaint.dart';
import 'package:elibrary_mobile/providers/base_provider.dart';

class ComplaintProvider extends BaseProvider<Complaint> {
  ComplaintProvider() : super("Complaint");

  @override
  Complaint fromJson(data) => Complaint.fromJson(data);
}