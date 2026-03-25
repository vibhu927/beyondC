import 'package:flutter/material.dart';

class BCAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BCAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.zero;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
