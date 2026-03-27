import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouterHolder {
  RouterHolder._();

  static GoRouter? router;
  static GlobalKey<NavigatorState>? rootNavigatorKey;
}
