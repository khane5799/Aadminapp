import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcProvider extends ChangeNotifier {
  bool _isProcessing = false;
  bool _isAvailable = false;
  bool _isSessionActive = false;
  String _nfcUrl = "";
  String _nfcMessage = "";

  bool get isProcessing => _isProcessing;
  bool get isAvailable => _isAvailable;
  bool get isSessionActive => _isSessionActive;
  String get nfcUrl => _nfcUrl;
  String get nfcMessage => _nfcMessage;

  /// Initialize NFC and check availability
  Future<void> initNFC() async {
    try {
      _isAvailable = await NfcManager.instance.isAvailable();
      debugPrint("NFC Available: $_isAvailable");
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing NFC: $e");
      _isAvailable = false;
      notifyListeners();
    }
  }

  /// Check NFC availability
  Future<bool> checkNFCAvailability() async {
    try {
      _isAvailable = await NfcManager.instance.isAvailable();
      debugPrint("NFC Availability Check: $_isAvailable");
      notifyListeners();
      return _isAvailable;
    } catch (e) {
      debugPrint("Error checking NFC availability: $e");
      _isAvailable = false;
      notifyListeners();
      return false;
    }
  }

  /// Stop any active NFC session
  Future<void> stopSession() async {
    try {
      if (_isSessionActive) {
        await NfcManager.instance.stopSession();
        _isSessionActive = false;
        _isProcessing = false;
        debugPrint("NFC session stopped");
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error stopping NFC session: $e");
      _isSessionActive = false;
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<String> startNFCOperation() async {
    try {
      // Stop any existing session first
      await stopSession();

      _isProcessing = true;
      notifyListeners();

      bool isAvail = await NfcManager.instance.isAvailable();

      if (isAvail) {
        _isSessionActive = true;
        Completer<String> completer = Completer<String>();

        NfcManager.instance.startSession(
          onDiscovered: (NfcTag nfcTag) async {
            try {
              await _readFromTag(tag: nfcTag);
              _isProcessing = false;
              _isSessionActive = false;
              notifyListeners();
              await NfcManager.instance.stopSession();
              completer.complete(_nfcUrl);
            } catch (e) {
              _isProcessing = false;
              _isSessionActive = false;
              _nfcMessage = "Error reading tag: ${e.toString()}";
              notifyListeners();
              await NfcManager.instance.stopSession();
              completer.completeError("Error reading tag: ${e.toString()}");
            }
          },
          onError: (e) async {
            _isProcessing = false;
            _isSessionActive = false;
            _nfcMessage = "Error: ${e.toString()}";
            notifyListeners();
            await NfcManager.instance.stopSession();
            completer.completeError("Error: ${e.toString()}");
          },
        );

        return completer.future;
      } else {
        _isProcessing = false;
        _isSessionActive = false;
        _nfcMessage = "Please Enable NFC From Settings";
        notifyListeners();
        return Future.value("Please Enable NFC From Settings");
      }
    } catch (e) {
      _isProcessing = false;
      _isSessionActive = false;
      _nfcMessage = "Error: ${e.toString()}";
      notifyListeners();
      return Future.value("Error: ${e.toString()}");
    }
  }

  /// Reads data from the NFC tag
  Future<void> _readFromTag({required NfcTag tag}) async {
    try {
      Map<String, dynamic>? nfcData = tag.data;
      String? decodedUrl;

      if (nfcData.containsKey('ndef')) {
        List<int>? payload =
            nfcData['ndef']?['cachedMessage']?['records']?[0]?['payload'];
        if (payload != null && payload.isNotEmpty) {
          int langCodeLength = payload[0];
          decodedUrl = String.fromCharCodes(
            payload.sublist(1 + langCodeLength),
          );
          debugPrint("Cleaned NFC payload: $decodedUrl");
          _nfcUrl = decodedUrl;
        }
      }

      _nfcUrl = decodedUrl ?? "No Data Found";
    } catch (e) {
      _nfcUrl = "Error reading tag: ${e.toString()}";
      debugPrint("Error reading NFC tag: $e");
    }

    notifyListeners();
  }

  /// ✅ Writes a string (text/URL) into an NFC tag
  Future<void> writeToTag(String message) async {
    try {
      // Stop any existing session first
      await stopSession();

      _isProcessing = true;
      _nfcMessage = ""; // Clear previous message
      notifyListeners();

      bool isAvail = await NfcManager.instance.isAvailable();
      if (!isAvail) {
        _isProcessing = false;
        _isSessionActive = false;
        _nfcMessage = "NFC not available";
        notifyListeners();
        throw Exception("NFC not available");
      }

      _isSessionActive = true;
      debugPrint("Starting NFC write session for: $message");

      Completer<void> completer = Completer<void>();

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            debugPrint("NFC tag discovered, writing data...");

            // Build an NDEF record with your message (as URI)
            final ndefRecord = NdefRecord.createUri(Uri.parse(message));
            final ndefMessage = NdefMessage([ndefRecord]);
            final ndef = Ndef.from(tag);

            if (ndef == null) {
              _nfcMessage = "Tag is not NDEF compatible";
              debugPrint(_nfcMessage);
              await NfcManager.instance.stopSession(errorMessage: _nfcMessage);
              completer.completeError(_nfcMessage);
              return;
            }

            if (!ndef.isWritable) {
              _nfcMessage = "Tag is not writable";
              debugPrint(_nfcMessage);
              await NfcManager.instance.stopSession(errorMessage: _nfcMessage);
              completer.completeError(_nfcMessage);
              return;
            }

            // Check if there's enough space
            if (ndefMessage.byteLength > ndef.maxSize) {
              _nfcMessage = "Message too long for this tag";
              debugPrint(_nfcMessage);
              await NfcManager.instance.stopSession(errorMessage: _nfcMessage);
              completer.completeError(_nfcMessage);
              return;
            }

            await ndef.write(ndefMessage);
            _nfcMessage = "Write successful: $message";
            debugPrint(_nfcMessage);

            // Stop session after successful write
            await NfcManager.instance.stopSession();
            _isSessionActive = false;
            _isProcessing = false;
            notifyListeners();

            completer.complete();
          } catch (e) {
            _nfcMessage = "Error writing tag: $e";
            debugPrint(_nfcMessage);
            await NfcManager.instance.stopSession(errorMessage: _nfcMessage);
            _isSessionActive = false;
            _isProcessing = false;
            notifyListeners();
            completer.completeError(e);
          }
        },
        onError: (e) async {
          _nfcMessage = "Session error: ${e.toString()}";
          debugPrint(_nfcMessage);
          _isSessionActive = false;
          _isProcessing = false;
          notifyListeners();
          completer.completeError(e);
        },
      );

      // Wait for the operation to complete
      await completer.future;
    } catch (e) {
      _isProcessing = false;
      _isSessionActive = false;
      _nfcMessage = "Exception: ${e.toString()}";
      debugPrint("writeToTag Exception: ${e.toString()}");
      notifyListeners();
      rethrow; // Re-throw so calling code can handle it
    }
  }

  /// Reset all states
  void reset() {
    _isProcessing = false;
    _isSessionActive = false;
    _nfcUrl = "";
    _nfcMessage = "";
    notifyListeners();
  }

  @override
  void dispose() {
    stopSession();
    super.dispose();
  }
}
