import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-action.dart';
import 'package:confotor/models/check-in-item.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/models/ticket.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/stores/ticket-store.dart';

class ConferenceStore {
  final CheckInList checkInListItem;
  final TicketStore ticketStore;
  ConferenceStore({ConfotorAppState appState, RequestUpdateConference ruc}):
    checkInListItem = ruc.checkInListItem,
    ticketStore = TicketStore(appState: appState, checkInListItem: ruc.checkInListItem);

  get url => checkInListItem.url;

  update(RequestUpdateConference ruc) {
    checkInListItem.update(ruc.checkInListItem);
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
}