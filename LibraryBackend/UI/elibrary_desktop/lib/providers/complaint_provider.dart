import 'package:elibrary_desktop/models/complaint.dart';
import 'package:elibrary_desktop/providers/base_provider.dart';

class ComplaintProvider extends BaseProvider<Complaint> {
  ComplaintProvider() : super("Complaint");

  @override
  Complaint fromJson(data) => Complaint.fromJson(data);
}