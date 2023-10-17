import 'qbittorrent.dart';

class NZBGet {
  status(List<Torrent> data) => _status(data);

  listGroups(List<Torrent> data) => _listGroups(data);

  version() => _version();
}

class NZBGetRequest {
  final NZBGetRequestMethod method;
  final List<dynamic> params;

  NZBGetRequest({
    required this.method,
    required this.params,
  });

  static NZBGetRequest fromJson(Map<String, dynamic> json) => NZBGetRequest(
        method: NZBGetRequestMethod.fromValue(json['method']),
        params: [json['params']],
      );
}

enum NZBGetRequestMethod {
  status(jsonName: 'status'),
  listGroups(jsonName: 'listgroups'),
  version(jsonName: 'version');

  const NZBGetRequestMethod({required this.jsonName});

  final String jsonName;

  static NZBGetRequestMethod fromValue(jsonValue) =>
      NZBGetRequestMethod.values.singleWhere((i) => jsonValue.toString() == i.jsonName);
}

_version() async => {"version": "1.1", "id": 1, "result": "21.1"};

_status(List<Torrent> data) async {
  final remaining = data.fold(0, (previousValue, element) => element.amountLeft + previousValue).toInt();
  final downloadRate = data.fold(0, (previousValue, element) => element.dlspeed + previousValue).toInt();
  final downloaded = data.fold(0, (previousValue, element) => element.downloaded + previousValue).toInt();

  return {
    "version": "1.1",
    "id": 1,
    "result": {
      "RemainingSizeLo": remaining.toInt(),
      "DownloadRate": downloadRate.toInt(),
      "ServerPaused": false,
      "DownloadPaused": false,
      "DownloadedSizeLo": downloaded.toInt(),
    }
  };
}

_listGroups(List<Torrent> data) async {
  final mapped = data
      .map((e) => {
            "NZBID": data.indexOf(e),
            "Status": e.state,
            "NZBName": e.name,
            "Category": e.category,
            "FileSizeMB": e.totalSize ~/ 1000000,
            "DownloadedSizeMB": e.downloaded ~/ 1000000,
          })
      .toList();
  return {"version": "1.1", "id": 1, "result": mapped};
}
