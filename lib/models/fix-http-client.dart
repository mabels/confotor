
import 'package:http/http.dart';

class MyClient extends BaseClient {
  final Client _inner = Client();

  MyClient();

  Future<StreamedResponse> send(BaseRequest request) {
    return _inner.send(request);
  }

}

final realHttp = MyClient();
BaseClient fixHttpClient(BaseClient client) {
  if (client != null) {
    return client;
  }
  return realHttp;
}