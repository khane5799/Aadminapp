// import 'package:adminapp/Provider/NFCProvider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class NfcView extends StatelessWidget {
//   const NfcView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final nfcProvider = Provider.of<NfcProvider>(context);

//     return Scaffold(
//       appBar: AppBar(title: const Text("NFC Demo")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             /// --- Show Current NFC Message ---
//             Text(
//               nfcProvider.nfcUrl.isNotEmpty
//                   ? "Read: ${nfcProvider.nfcUrl}"
//                   : "No NFC Data",
//               style: const TextStyle(fontSize: 18),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               nfcProvider.nfcMessage,
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 30),

//             /// --- Read NFC Button ---
//             ElevatedButton.icon(
//               onPressed: nfcProvider.isProcessing
//                   ? null
//                   : () async {
//                       await nfcProvider.startNFCOperation();
//                     },
//               icon: const Icon(Icons.nfc),
//               label: const Text("Read NFC"),
//             ),
//             const SizedBox(height: 16),

//             /// --- Write NFC Button ---
//             ElevatedButton.icon(
//               onPressed: nfcProvider.isProcessing
//                   ? null
//                   : () async {
//                       await nfcProvider.writeToTag("https://example.com/member123");
//                     },
//               icon: const Icon(Icons.save_alt),
//               label: const Text("Write NFC"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
