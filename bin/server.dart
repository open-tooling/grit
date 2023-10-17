import 'dart:io';

import 'package:shelf_plus/shelf_plus.dart';

import 'nzbget.dart';
import 'qbittorrent.dart';

final nzbGet = NZBGet();
final qBittorrent = QBittorrent();

Future<void> main() async {
  await shelfRun(
    init,
    defaultBindPort: 6789,
    defaultEnableHotReload: false,
    defaultBindAddress: InternetAddress.anyIPv4,
  );
}

Handler init() {
  var app = Router().plus
    ..get('/', (Request request) => Response.ok('OK'))
    ..post('/<credentials>/jsonrpc', _handler);
  return app;
}

class Credentials {
  final String username;
  final String password;

  Credentials({
    required this.username,
    required this.password,
  });
}

Uri? getProxyURI(Request request) {
  final host = Platform.environment['grit-host'] ?? request.headers['x-grit-host'];
  final protocol = Platform.environment['grit-protocol'] ?? request.headers['x-grit-protocol'];
  final port = Platform.environment['grit-port'] ?? request.headers['x-grit-port'];
  return Uri.tryParse('$protocol://$host:$port');
}

Credentials? getCredentials(Request request) {
  try {
    final pair = Platform.environment['grit-credentials'] ?? Uri.decodeFull(request.params['credentials']!);
    final credentials = pair.split(":");
    return Credentials(username: credentials[0], password: credentials[1]);
  } catch (e) {
    return null;
  }
}

dynamic _handler(Request request) async {
  final remoteUri = getProxyURI(request) ?? (throw Exception('no proxy'));
  final credentials = getCredentials(request) ?? (throw Exception('no credentials'));
  final cookie = await qBittorrent.cookie(credentials, remoteUri) ?? (throw Exception('no credentials'));

  final nzbRequest = NZBGetRequest.fromJson(await request.body.asJson);
  switch (nzbRequest.method) {
    case NZBGetRequestMethod.status:
      final List<Torrent> data = await qBittorrent.torrents(cookie, remoteUri);
      return await nzbGet.status(data);
    case NZBGetRequestMethod.listGroups:
      final data = await qBittorrent.torrents(cookie, remoteUri);
      return await nzbGet.listGroups(data);
    case NZBGetRequestMethod.version:
      return await nzbGet.version();
  }
}
