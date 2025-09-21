import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final int index;
  final Color secondaryColor;
  final IconData? Function(String eventName) getEventIcon;

  // General onTap (for arrow version)
  final void Function(String eventId, String eventName)? onTap;

  // Optional NFC + QR handlers
  final void Function(String eventId, String eventName)? onNfcTap;
  final void Function(String eventId, String eventName)? onQrTap;

  const EventCard({
    super.key,
    required this.event,
    required this.index,
    required this.secondaryColor,
    required this.getEventIcon,
    this.onTap,
    this.onNfcTap,
    this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format date
    String dateText = "";
    if (event["date"] != null) {
      try {
        dateText = DateFormat("dd MMM yyyy").format(event["date"]);
      } catch (_) {}
    }

    // Avatar colors (loop over 8)
    final List<Color> avatarColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    final avatarColor = avatarColors[index % avatarColors.length];

    // Decide trailing widget
    Widget trailingWidget;
    if (onNfcTap != null && onQrTap != null) {
      trailingWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.nfc, color: Colors.blue),
            onPressed: () => onNfcTap!(event["uid"], event["name"]),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code, color: Colors.green),
            onPressed: () => onQrTap!(event["uid"], event["name"]),
          ),
        ],
      );
    } else {
      trailingWidget = const Icon(Icons.arrow_forward_ios);
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: avatarColor,
          child: getEventIcon(event["name"]) != null
              ? Icon(
                  getEventIcon(event["name"]),
                  color: Colors.white,
                  size: 28,
                )
              : Text(
                  event["name"][0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          event["name"],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dateText.isNotEmpty)
              Text("📅 $dateText",
                  style: const TextStyle(color: Colors.grey)),
            Text(
              "👥 Attendees: ${event["attendees"]}",
              style: const TextStyle(color: Colors.black87),
            ),
            if (event["points"] != null)
              Text(
                "⭐ Points: ${event["points"]}",
                style: TextStyle(color: secondaryColor),
              ),
          ],
        ),
        trailing: trailingWidget,
        onTap: onTap != null ? () => onTap!(event["uid"], event["name"]) : null,
      ),
    );
  }
}
