package com.kthakrebts.flutter_ble_architecture

import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Main coordinator bridging Flutter MethodChannel to Android Native BLE APIs.
 */
class BleManager(private val context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {

    private val TAG = "BleManager"
    private val channel = MethodChannel(messenger, "com.kthakrebts.ble/bridge")

    private val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter = bluetoothManager.adapter

    private lateinit var scanner: BleScanner
    private lateinit var connectionManager: BleConnectionManager

    init {
        channel.setMethodCallHandler(this)
        
        if (bluetoothAdapter != null) {
            // Scanner callback
            scanner = BleScanner(context, bluetoothAdapter) { scanResult ->
                val deviceMap = mapOf(
                    "name" to (scanResult.device.name ?: "Unknown Device"),
                    "address" to scanResult.device.address,
                    "rssi" to scanResult.rssi
                )
                // Stream scan results back to Flutter UI asynchronously
                runOnMainThread {
                    channel.invokeMethod("onDeviceDiscovered", deviceMap)
                }
            }

            connectionManager = BleConnectionManager(context, bluetoothAdapter)
        } else {
            Log.e(TAG, "Bluetooth Adapter not available on this hardware.")
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (bluetoothAdapter == null) {
            result.error("BLE_UNAVAILABLE", "Bluetooth hardware is not supported on this device.", null)
            return
        }

        when (call.method) {
            "startScan" -> {
                try {
                    scanner.startScan()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SCAN_ERROR", e.message, null)
                }
            }
            "stopScan" -> {
                try {
                    scanner.stopScan()
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SCAN_ERROR", e.message, null)
                }
            }
            "connect" -> {
                val address = call.argument<String>("address")
                if (address == null) {
                    result.error("INVALID_ARGUMENT", "MAC address is required.", null)
                    return
                }

                val callback = GattCallbackHandler(
                    onConnectionStateChanged = { devAddress, status, newState ->
                        val stateMap = mapOf(
                            "address" to devAddress,
                            "status" to status,
                            "state" to newState
                        )
                        runOnMainThread {
                            channel.invokeMethod("onConnectionStateChanged", stateMap)
                        }
                    },
                    onServicesDiscovered = { devAddress, status ->
                        val serviceList = connectionManager.getGatt(devAddress)
                            ?.services
                            ?.map { it.uuid.toString() } ?: emptyList()
                        
                        val serviceMap = mapOf(
                            "address" to devAddress,
                            "status" to status,
                            "services" to serviceList
                        )
                        runOnMainThread {
                            channel.invokeMethod("onServicesDiscovered", serviceMap)
                        }
                    },
                    onCharacteristicRead = { devAddress, charUuid, value, status ->
                        val charMap = mapOf(
                            "address" to devAddress,
                            "characteristic" to charUuid,
                            "value" to value,
                            "status" to status
                        )
                        runOnMainThread {
                            channel.invokeMethod("onCharacteristicRead", charMap)
                        }
                    }
                )

                val success = connectionManager.connect(address, callback)
                result.success(success)
            }
            "disconnect" -> {
                val address = call.argument<String>("address")
                if (address == null) {
                    result.error("INVALID_ARGUMENT", "MAC address is required.", null)
                    return
                }
                connectionManager.disconnect(address)
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun runOnMainThread(action: () -> Unit) {
        val mainHandler = android.os.Handler(context.mainLooper)
        mainHandler.post(action)
    }

    fun onDestroy() {
        if (::connectionManager.isInitialized) {
            connectionManager.disconnectAll()
        }
    }
}
