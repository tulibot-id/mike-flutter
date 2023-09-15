import 'package:flutter/material.dart';

class RouteObserverService extends RouteObserver<PageRoute<dynamic>> {
  static final RouteObserverService _instance = RouteObserverService._internal();

  factory RouteObserverService() => _instance;

  RouteObserverService._internal();
}

class PreviousRoute {
  String? routeName;

  PreviousRoute._privateConstructor();

  static final PreviousRoute instance = PreviousRoute._privateConstructor();
}