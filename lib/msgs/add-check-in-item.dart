
import 'package:confotor/models/check-in-item.dart';
import 'package:meta/meta.dart';

import 'confotor-msg.dart';

class AddCheckInItem extends ConfotorMsg {
  final CheckInItem item;
  AddCheckInItem({@required CheckInItem item}): item = item;
}
