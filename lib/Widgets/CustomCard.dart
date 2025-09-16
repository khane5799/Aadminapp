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
            // Row for avatar + title/details + icons
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // center vertically
              children: [
                // Optional profile picture or default icon
                if (widget.profileImageUrl != null &&
                    widget.profileImageUrl!.isNotEmpty) ...[
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(widget.profileImageUrl!),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person,
                        size: 28, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 12),
                ],

                // Title + Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // center content vertically
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

                // Icons
                if (widget.icons != null && widget.icons!.isNotEmpty)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center, // center icons
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

            // Optional radio buttons for status
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
