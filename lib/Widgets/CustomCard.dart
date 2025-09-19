import 'package:adminapp/Constents/Colors.dart';
import 'package:flutter/material.dart';

enum CardStatus { active, upcoming, expired }

class CustomCard extends StatefulWidget {
  final String title;
  final List<String> details;
  final List<IconData>? icons;
  final List<VoidCallback>? iconActions;
  final Color? iconColor;
  final String? profileImageUrl;
  final String? initials; // New property for initials

  final bool showStatusSelector;
  final CardStatus? initialStatus;
  final ValueChanged<CardStatus>? onStatusChanged;

  const CustomCard({
    super.key,
    required this.title,
    required this.details,
    this.icons,
    this.iconActions,
    this.iconColor,
    this.profileImageUrl,
    this.initials,
    this.showStatusSelector = false,
    this.initialStatus,
    this.onStatusChanged,
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  CardStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(), // Cleanly handle avatar cases
                const SizedBox(width: 12),

                // Title + Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...widget.details.map((d) => Text(d)),
                    ],
                  ),
                ),

                // Optional icons
                if (widget.icons != null && widget.icons!.isNotEmpty)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.icons!.length, (index) {
                      return IconButton(
                        icon: Icon(
                          widget.icons![index],
                          color: widget.iconColor ?? secondaryColor,
                        ),
                        onPressed: widget.iconActions != null &&
                                widget.iconActions!.length > index
                            ? widget.iconActions![index]
                            : () {},
                      );
                    }),
                  ),
              ],
            ),

            // Optional radio buttons
            if (widget.showStatusSelector) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRadio("Active", CardStatus.active),
                  _buildRadio("Upcoming", CardStatus.upcoming),
                  _buildRadio("Expired", CardStatus.expired),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Avatar builder
  Widget _buildAvatar() {
    // Case 1: Network image
    if (widget.profileImageUrl != null && widget.profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(widget.profileImageUrl!),
      );
    }

    // Case 2: Initials
    if (widget.initials != null && widget.initials!.isNotEmpty) {
      // Take first 2 letters safely
      String initials = widget.initials!
          .substring(
            0,
            widget.initials!.length >= 2 ? 2 : widget.initials!.length,
          )
          .toUpperCase();

      // Generate a consistent color based on initials
      Color bgColor = _getColorFromInitials(initials);

      return CircleAvatar(
        radius: 25,
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

    // Case 3: Default person icon
    return CircleAvatar(
      radius: 25,
      backgroundColor: Colors.grey.shade300,
      child: Icon(Icons.person, size: 28, color: Colors.grey.shade700),
    );
  }

  /// Generate a color from initials so it varies per user
  Color _getColorFromInitials(String initials) {
    // Simple hashing: sum char codes
    int hash = initials.codeUnits.fold(0, (prev, elem) => prev + elem);
    // Pick a color from a list
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

  Widget _buildRadio(String label, CardStatus status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<CardStatus>(
          value: status,
          groupValue: _selectedStatus,
          activeColor: secondaryColor,
          onChanged: (value) {
            setState(() => _selectedStatus = value);
            if (value != null && widget.onStatusChanged != null) {
              widget.onStatusChanged!(value);
            }
          },
        ),
        Text(label),
      ],
    );
  }
}
