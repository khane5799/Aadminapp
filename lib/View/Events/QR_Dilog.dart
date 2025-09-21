import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QrDialog extends StatelessWidget {
  final String eventUid;
  final GlobalKey qrKey;
  final Color primerycolor;

  const QrDialog({
    super.key,
    required this.eventUid,
    required this.qrKey,
    required this.primerycolor,
  });

  Future<void> _shareQrCode() async {
    try {
      // Get QR widget boundary
      RenderRepaintBoundary boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Convert to byte data
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr.png').create();
      await file.writeAsBytes(pngBytes);

      // Share image file
      await Share.shareXFiles([XFile(file.path)], text: "");
    } catch (e) {
      debugPrint("Error sharing QR image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Event QR Code",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              height: 180,
              child: RepaintBoundary(
                key: qrKey,
                child: QrImageView(
                  data: eventUid,
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                "Share",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primerycolor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _shareQrCode,
            ),
          ],
        ),
      ),
    );
  }
}
