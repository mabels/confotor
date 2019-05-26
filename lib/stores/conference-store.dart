import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-action.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/conference.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/stores/ticket-store.dart';
import 'package:meta/meta.dart';

class ConferenceStore extends ConferenceKey {
  final CheckInList checkInList;
  final TicketStore ticketStore;
  ConferenceStore({@required ConfotorAppState appState, @required CheckInList checkInList}):
    checkInList = checkInList,
    ticketStore = TicketStore(appState: appState),
    super(checkInList.url);

  update(RequestUpdateConference ruc) {
    checkInList.update(ruc.checkInList);
    return this;
  }

  updateCheckInItems(List<CheckInItem> ciim) {
    ticketStore.updateCheckInItems(ciim);
    return this;
  }


  updateCheckInActions(List<CheckInAction> ciam) {
    ticketStore.updateCheckInActions(ciam);
    return this;
  }

  updateTickets(List<Ticket> tickets) {
    ticketStore.updateTickets(tickets);
    return this;
  }

  Conference toConference() {
    // print('toConference:${ticketStore.values.length}');
    return Conference(
      checkInList: checkInList,
      ticketAndCheckInsList: ticketStore.values.map((tacs) => tacs.toTicketAndCheckIns()).toList());
  }
}