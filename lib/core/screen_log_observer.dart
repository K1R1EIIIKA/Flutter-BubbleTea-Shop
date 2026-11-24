import 'package:flutter/material.dart';

class ScreenLogObserver extends NavigatorObserver {
  void _log(String action, Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null) debugPrint('BubbleTeaScreen $action $name');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == null) return;
    _log('pause', previousRoute);
    _log('show', route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == null) return;
    _log('close', route);
    _log('return', previousRoute);
  }
}
