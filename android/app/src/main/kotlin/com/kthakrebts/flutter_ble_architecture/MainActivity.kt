package com.kthakrebts.flutter_ble_architecture

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var bleManager: BleManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        bleManager = BleManager(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        bleManager?.onDestroy()
        super.onDestroy()
    }
}
