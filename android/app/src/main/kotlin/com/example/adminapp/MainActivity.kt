package com.umno.adminapp

import android.app.PendingIntent
import android.content.Intent
import android.content.IntentFilter
import android.nfc.NfcAdapter
import android.nfc.NfcManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var nfcAdapter: NfcAdapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val nfcManager = getSystemService(NFC_SERVICE) as NfcManager
        nfcAdapter = nfcManager.defaultAdapter
    }

    override fun onResume() {
        super.onResume()
        enableForegroundDispatch()
    }

    override fun onPause() {
        super.onPause()
        disableForegroundDispatch()
    }

    private fun enableForegroundDispatch() {
        val intent = Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent, PendingIntent.FLAG_MUTABLE
        )

        val intentFilters = arrayOf(
            IntentFilter(NfcAdapter.ACTION_TAG_DISCOVERED),
            IntentFilter(NfcAdapter.ACTION_NDEF_DISCOVERED),
            IntentFilter(NfcAdapter.ACTION_TECH_DISCOVERED)
        )

        nfcAdapter?.enableForegroundDispatch(this, pendingIntent, intentFilters, null)
    }

    private fun disableForegroundDispatch() {
        nfcAdapter?.disableForegroundDispatch(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        // Check if it's an NFC event
        if (intent.action == NfcAdapter.ACTION_NDEF_DISCOVERED ||
            intent.action == NfcAdapter.ACTION_TAG_DISCOVERED ||
            intent.action == NfcAdapter.ACTION_TECH_DISCOVERED
        ) {
            // Prevents Android from automatically opening URLs
            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        setIntent(intent) // Pass intent to Flutter
    }
}
