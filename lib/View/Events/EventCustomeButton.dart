
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final dynamic buttonTitle; // Can be String or Widget
  final Color buttonColor;
  final Icon? iconData;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.buttonTitle,
    this.buttonColor = Colors.green,
    this.iconData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? () {} : onPressed, // keep button enabled
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 65,
              height: 24,
              child: Padding(
                padding: EdgeInsets.only(left: 18, right: 18),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (iconData != null) ...[
                  iconData!,
                  const SizedBox(width: 8),
                ],
                buttonTitle is String ? Text(buttonTitle) : buttonTitle,
              ],
            ),
    );
  }
}