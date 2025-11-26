import 'package:adminapp/Constents/Colors.dart';
import 'package:flutter/material.dart';

enum CardStatus { active, upcoming, expired }

class CustomCard extends StatefulWidget {
  final String title; // usually name
  final List<String> details;
  final List<IconData>? icons;
  final List<VoidCallback>? iconActions;
  final Color? iconColor;
  final String? profileImageUrl;

  final bool showStatusSelector;
  final ValueChanged<CardStatus>? onStatusChanged;

  const CustomCard({
    super.key,
    required this.title,
    required this.details,
    this.icons,
    this.iconActions,
    this.iconColor,
    this.profileImageUrl,
    this.showStatusSelector = false,
    this.onStatusChanged,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  CardStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile + Details Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      ...widget.details.map((d) => Text(
                            d,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                          )),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Icon Row (always horizontal for 3 icons)
            if (widget.icons != null && widget.icons!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(widget.icons!.length, (index) {
                  return _buildIconButton(
                    widget.icons![index],
                    widget.iconActions != null &&
                            widget.iconActions!.length > index
                        ? widget.iconActions![index]
                        : () {},
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  /// Avatar builder with fallback: image → initials from name → default icon
  Widget _buildAvatar() {
    // Case 1: Profile image
    if (widget.profileImageUrl != null &&
        widget.profileImageUrl!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(widget.profileImageUrl!),
      );
    }

    // Case 2: Initials from title (name)
    if (widget.title.isNotEmpty) {
      String initials = _getInitialsFromName(widget.title);
      Color bgColor = _getColorFromInitials(initials);

      return CircleAvatar(
        radius: 28,
        backgroundColor: bgColor,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
    }

    // Case 3: Default avatar
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey.shade300,
      child: Icon(Icons.person, size: 28, color: Colors.grey.shade700),
    );
  }

  /// Extract initials safely from full name
  String _getInitialsFromName(String name) {
    List<String> parts = name.trim().split(" ");
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    } else {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
  }

  /// Generate background color from initials hash
  Color _getColorFromInitials(String initials) {
    int hash = initials.codeUnits.fold(0, (prev, elem) => prev + elem);
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    return colors[hash % colors.length];
  }

  /// Clean icon button
  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (widget.iconColor ?? secondaryColor).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: widget.iconColor ?? secondaryColor, size: 26),
      ),
    );
  }
}
