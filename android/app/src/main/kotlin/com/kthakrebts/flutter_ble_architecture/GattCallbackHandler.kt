package com.kthakrebts.flutter_ble_architecture

import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothProfile
import android.util.Log

/**
 * Handles low-level Android GATT callback events and forwards results.
 */
class GattCallbackHandler(
    private val onConnectionStateChanged: (deviceId: String, status: Int, newState: Int) -> Unit,
    private val onServicesDiscovered: (deviceId: String, status: Int) -> Unit,
    private val onCharacteristicRead: (deviceId: String, characteristicUuid: String, value: ByteArray, status: Int) -> Unit
) : BluetoothGattCallback() {

    private val TAG = "GattCallbackHandler"

    override fun onConnectionStateChange(gatt: BluetoothGatt?, status: Int, newState: Int) {
        val address = gatt?.device?.address ?: return
        Log.d(TAG, "onConnectionStateChange - Device: $address, Status: $status, NewState: $newState")
        
        onConnectionStateChanged(address, status, newState)

        if (newState == BluetoothProfile.STATE_CONNECTED && status == BluetoothGatt.GATT_SUCCESS) {
            Log.i(TAG, "Connected to GATT server on $address, initiating service discovery...")
            gatt.discoverServices()
        } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
            Log.i(TAG, "Disconnected from GATT server on $address")
            gatt.close()
        }
    }

    override fun onServicesDiscovered(gatt: BluetoothGatt?, status: Int) {
        val address = gatt?.device?.address ?: return
        Log.d(TAG, "onServicesDiscovered - Device: $address, Status: $status")
        onServicesDiscovered(address, status)
    }

    @Deprecated("Deprecated in Android 13 but kept for backward compatibility")
    override fun onCharacteristicRead(
        gatt: BluetoothGatt?,
        characteristic: BluetoothGattCharacteristic?,
        status: Int
    ) {
        val address = gatt?.device?.address ?: return
        val uuid = characteristic?.uuid?.toString() ?: return
        val value = characteristic.value ?: ByteArray(0)
        Log.d(TAG, "onCharacteristicRead - Device: $address, Characteristic: $uuid, Status: $status")
        onCharacteristicRead(address, uuid, value, status)
    }

    override fun onMtuChanged(gatt: BluetoothGatt?, mtu: Int, status: Int) {
        Log.d(TAG, "onMtuChanged - Device: ${gatt?.device?.address}, MTU: $mtu, Status: $status")
    }
}
