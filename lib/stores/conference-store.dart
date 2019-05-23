import 'package:confotor/components/confotor-app.dart';
import 'package:confotor/models/check-in-list-item.dart';
import 'package:confotor/msgs/conference-msg.dart';
import 'package:confotor/stores/ticket-store.dart';

class ConferenceStore {
  final CheckInListItem checkInListItem;
  final TicketStore ticketStore;
  ConferenceStore({ConfotorAppState appState, RequestUpdateConference ruc}):
    checkInListItem = ruc.checkInListItem,
    ticketStore = TicketStore(appState: appState).update(ruc.ticketAndCheckIns);

  get url => checkInListItem.url;

  update(RequestUpdateConference ruc) {
    checkInListItem.update(ruc.checkInListItem);
    ticketStore.update(ruc.ticketAndCheckIns);
    return this;
  }
}