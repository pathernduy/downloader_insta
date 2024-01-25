import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart'; // import dio package for API calls

class UserInfo {
  String? _username, _id;
  bool _isPrivate = false;

  String? get id => _id;

  set id(String? value) {
    _id = value;
  }

  String? get username => _username;

  set username(String? value) {
    _username = value;
  }

  bool get isPrivate => _isPrivate;

  set isPrivate(bool value) {
    _isPrivate = value;
  }



}
