import 'package:adminapp/View/Events/QR_Dilog.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class NfcDialog extends StatelessWidget {
  final BuildContext currentContext;
  final dynamic nfcProvider;
  final String event;
  final GlobalKey qrKey;
  final Color primerycolor;
  final Color secondaryColor;

  const NfcDialog({
    super.key,
    required this.currentContext,
    required this.nfcProvider,
    required this.event,
    required this.qrKey,
    required this.primerycolor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glowing background card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [primerycolor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NFC Icon inside glow
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.contactless,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    "Tap Your NFC Card",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lottie NFC Animation
                  Lottie.asset(
                    "assets/images/tap.json",
                    height: 150,
                    repeat: true,
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    "Hold your NFC card near the phone\nto mark attendance.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel
                      OutlinedButton(
                        onPressed: () async {
                          await nfcProvider.stopSession();
                          if (currentContext.mounted) {
                            Navigator.pop(currentContext);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),

                      // QR Fallback
                      ElevatedButton.icon(
                        onPressed: () async {
                          await nfcProvider.stopSession();
                          if (currentContext.mounted) {
                            Navigator.pop(currentContext);

                            // Open QR dialog
                            showDialog(
                              context: context,
                              builder: (_) => QrDialog(
                                eventUid: event,
                                qrKey: qrKey,
                                primerycolor: primerycolor,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.qr_code, color: Colors.white),
                        label: const Text("Share QR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
