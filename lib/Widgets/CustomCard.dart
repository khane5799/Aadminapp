import 'package:adminapp/Constents/Colors.dart';
import 'package:flutter/material.dart';

enum CardStatus { active, upcoming, expired }

class CustomCard extends StatefulWidget {
  final String title;
  final List<String> details; // e.g., ["Code: M123", "Division: North"]
  final List<IconData>? icons; // optional list of icons for actions
  final List<VoidCallback>? iconActions; // actions for each icon
  final Color? iconColor; // optional color for icons

  // NEW: radio button options
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
            // Row for title and icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title + Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ...widget.details.map((d) => Text(d)),
                  ],
                ),

                // Icons
                if (widget.icons != null && widget.icons!.isNotEmpty)
                  Column(
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
