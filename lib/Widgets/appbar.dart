import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? ActiononTap;
  final Color primerycolor;
  final Color secondaryColor;
  final IconData? icon;
  final bool centertitle;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.centertitle,
    required this.automaticallyImplyLeading,
    this.ActiononTap,
    required this.primerycolor,
    required this.secondaryColor,
    this.icon,
  });

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading : automaticallyImplyLeading,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: centertitle,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primerycolor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 4,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: ActiononTap,
          tooltip: 'onTap',
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}
