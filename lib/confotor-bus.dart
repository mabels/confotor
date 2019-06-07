
import 'dart:async';

import 'msgs/confotor-msg.dart';

class ConfotorBus {
  final StreamController<ConfotorMsg> bus = StreamController();
  final Map<String, ConfotorMsg> persistMsgs = new Map();
  Stream<ConfotorMsg> _stream;

  ConfotorBus()  {
    this._stream = this.bus.stream.asBroadcastStream();
  }

  stop() {
    this.bus.close();
    this.persistMsgs.clear();
  }

  add(ConfotorMsg msg, { bool persist = false }) {
    if (persist) {
      persistMsgs[msg.runtimeType.toString()] = msg;
    }
    this.bus.add(msg);
  }

  Stream<ConfotorMsg> get stream {
    StreamController<ConfotorMsg> ctl;
    ctl = StreamController(onListen: () {
      this.persistMsgs.values.forEach((msg) => ctl.add(msg));
    });
    this._stream.listen((msg) => ctl.add(msg),
      onDone: () => ctl.close(),
      onError: (e) => ctl.addError(e),
    );
    return ctl.stream.asBroadcastStream();
  }

  listen(void onData(ConfotorMsg event)) {
    var ret = this.stream.listen(onData);
    return ret;
  }

}
