// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:share_plus/share_plus.dart';

// class QrShareHelper {
//   /// Render a widget to image bytes
//   static Future<Uint8List> _capturePng(GlobalKey key) async {
//     RenderRepaintBoundary boundary =
//         key.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     return byteData!.buffer.asUint8List();
//   }

//   /// Show dialog with QR code and share as image
//   static void showQrDialog(BuildContext context, String uid) {
//     final GlobalKey qrKey = GlobalKey();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: const Text("Event QR Code"),
//           content: SingleChildScrollView(
//             // make content scrollable
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   width: 200,
//                   height: 200,
//                   child: RepaintBoundary(
//                     key: qrKey,
//                     child: QrImageView(
//                       data: uid,
//                       version: QrVersions.auto,
//                       gapless: false,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text("Event UID:\n$uid", textAlign: TextAlign.center),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 // capture QR image as PNG
//                 RenderRepaintBoundary boundary = qrKey.currentContext!
//                     .findRenderObject() as RenderRepaintBoundary;
//                 final image = await boundary.toImage(pixelRatio: 3.0);
//                 final byteData =
//                     await image.toByteData(format: ui.ImageByteFormat.png);
//                 final pngBytes = byteData!.buffer.asUint8List();

//                 final tempDir = await getTemporaryDirectory();
//                 final file =
//                     await File('${tempDir.path}/qr.png').writeAsBytes(pngBytes);

//                 Share.shareXFiles([XFile(file.path)], text: "Event QR Code");
//               },
//               child: const Text("Share QR Image"),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Close"),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
