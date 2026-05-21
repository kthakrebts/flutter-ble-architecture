package com.kthakrebts.flutter_ble_architecture

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.content.Context
import android.util.Log
import java.util.concurrent.ConcurrentHashMap

/**
 * Manages active GATT connections to BLE peripherals.
 */
class BleConnectionManager(
    private val context: Context,
    private val bluetoothAdapter: BluetoothAdapter
) {
    private val TAG = "BleConnectionManager"
    
    // Thread-safe map storing active GATT connections by MAC address
    private val activeConnections = ConcurrentHashMap<String, BluetoothGatt>()

    @SuppressLint("MissingPermission")
    fun connect(address: String, callback: BluetoothGattCallback): Boolean {
        try {
            if (activeConnections.containsKey(address)) {
                Log.w(TAG, "Device $address is already connected or connection is pending.")
                return true
            }

            val device: BluetoothDevice = bluetoothAdapter.getRemoteDevice(address)
            Log.i(TAG, "Initiating GATT connection to $address")
            
            // Connect to GATT Server
            val gatt = device.connectGatt(context, false, callback)
            if (gatt != null) {
                activeConnections[address] = gatt
                return true
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error connecting to device $address: ${e.message}", e)
        }
        return false
    }

    @SuppressLint("MissingPermission")
    fun disconnect(address: String) {
        val gatt = activeConnections.remove(address)
        if (gatt != null) {
            Log.i(TAG, "Disconnecting and closing GATT connection for $address")
            gatt.disconnect()
            gatt.close()
        } else {
            Log.w(TAG, "No active GATT connection found for device $address")
        }
    }

    fun getGatt(address: String): BluetoothGatt? {
        return activeConnections[address]
    }

    fun disconnectAll() {
        Log.i(TAG, "Disconnecting all active GATT connections...")
        activeConnections.keys.forEach { address ->
            disconnect(address)
        }
    }
}
