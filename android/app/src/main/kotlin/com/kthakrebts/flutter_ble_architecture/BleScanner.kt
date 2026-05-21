package com.kthakrebts.flutter_ble_architecture

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.Context
import android.util.Log

/**
 * Manages LE scanning operations on Android.
 */
class BleScanner(
    private val context: Context,
    private val bluetoothAdapter: BluetoothAdapter,
    private val onDeviceFound: (ScanResult) -> Unit
) {
    private val TAG = "BleScanner"
    private val scanner by lazy { bluetoothAdapter.bluetoothLeScanner }
    private var isScanning = false

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            result?.let { onDeviceFound(it) }
        }

        override fun onBatchScanResults(results: MutableList<ScanResult>?) {
            results?.forEach { onDeviceFound(it) }
        }

        override fun onScanFailed(errorCode: Int) {
            Log.e(TAG, "BLE scan failed with error code: $errorCode")
        }
    }

    @SuppressLint("MissingPermission")
    fun startScan() {
        if (isScanning) return

        if (scanner == null) {
            Log.e(TAG, "BluetoothLeScanner is unavailable.")
            return
        }

        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()

        Log.i(TAG, "Starting BLE scanner...")
        scanner.startScan(null, settings, scanCallback)
        isScanning = true
    }

    @SuppressLint("MissingPermission")
    fun stopScan() {
        if (!isScanning) return

        if (scanner == null) {
            Log.e(TAG, "BluetoothLeScanner is unavailable.")
            return
        }

        Log.i(TAG, "Stopping BLE scanner...")
        scanner.stopScan(scanCallback)
        isScanning = false
    }
}
