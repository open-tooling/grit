import 'dart:convert';

import 'package:http/http.dart' as http;

import 'server.dart';

class QBittorrent {
  Future<List<Torrent>> torrents(String cookie, Uri service) async {
    final url = Uri.parse('$service/api/v2/torrents/info');
    final headers = {'Cookie': cookie};
    final response = await http.get(url, headers: headers);

    return (jsonDecode(response.body).map<Torrent>((element) {
      final torrent = Torrent.fromJson(element);
      return torrent;
    })).toList();
  }

  Future<String?> cookie(Credentials credentials, Uri serviceUrl) async {
    try {
      final url = Uri.parse('$serviceUrl/api/v2/auth/login');
      final response = await http.post(url, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      }, body: {
        'password': credentials.password,
        'username': credentials.username,
      });
      return response.headers['set-cookie']!.split(';')[0];
    } catch (e) {
      return null;
    }
  }
}

class Torrent {
  int amountLeft;
  String category;
  int dlspeed;
  int downloaded;
  String name;
  String state;
  int totalSize;

  Torrent({
    required this.amountLeft,
    required this.category,
    required this.dlspeed,
    required this.downloaded,
    required this.name,
    required this.state,
    required this.totalSize,
  });

  factory Torrent.fromJson(Map<String, dynamic> json) {
    return Torrent(
      amountLeft: json['amount_left'],
      category: json['category'],
      dlspeed: json['dlspeed'],
      downloaded: json['downloaded'],
      name: json['name'],
      state: json['state'],
      totalSize: json['total_size'],
    );
  }
}
