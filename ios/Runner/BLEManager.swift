import CoreBluetooth
import Flutter
import Foundation

/// Main bridge coordinator between Flutter and iOS CoreBluetooth framework.
class BLEManager: NSObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager?
    private var channel: FlutterMethodChannel?
    
    private var scanner: BLEScanner?
    private var connectionManager: BLEConnectionManager?
    
    // Scanned but not necessarily connected peripherals dictionary to look up for connection
    private var discoveredPeripherals = [String: CBPeripheral]()

    init(messenger: FlutterBinaryMessenger) {
        super.init()
        self.channel = FlutterMethodChannel(name: "com.kthakrebts.ble/bridge", binaryMessenger: messenger)
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.channel?.setMethodCallHandler { [weak self] (call, result) in
            self?.handle(call, result: result)
        }
        
        // Initialize sub-managers
        self.scanner = BLEScanner(centralManager: centralManager) { [weak self] deviceMap in
            self?.channel?.invokeMethod("onDeviceDiscovered", arguments: deviceMap)
        }
        
        self.connectionManager = BLEConnectionManager(
            centralManager: centralManager,
            onConnectionChanged: { [weak self] uuid, state in
                let stateMap: [String: Any] = ["address": uuid, "state": state]
                self?.channel?.invokeMethod("onConnectionStateChanged", arguments: stateMap)
            },
            onServicesDiscovered: { [weak self] uuid, services in
                let serviceMap: [String: Any] = [
                    "address": uuid,
                    "services": services,
                    "status": 0 // 0 means Success on iOS / Android parity
                ]
                self?.channel?.invokeMethod("onServicesDiscovered", arguments: serviceMap)
            }
        )
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard centralManager?.state == .poweredOn else {
            result(FlutterError(code: "BLE_POWERED_OFF", message: "Bluetooth is not turned on.", details: nil))
            return
        }

        switch call.method {
        case "startScan":
            scanner?.startScan()
            result(true)
        case "stopScan":
            scanner?.stopScan()
            result(true)
        case "connect":
            guard let args = call.arguments as? [String: Any],
                  let uuidStr = args["address"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "MAC/UUID is required.", details: nil))
                return
            }
            
            if let peripheral = discoveredPeripherals[uuidStr] {
                connectionManager?.connect(peripheral: peripheral)
                result(true)
            } else {
                // Try retrieving system connected peripherals or UUID match
                if let uuid = UUID(uuidString: uuidStr),
                   let peripheral = centralManager?.retrievePeripherals(withIdentifiers: [uuid]).first {
                    discoveredPeripherals[uuidStr] = peripheral
                    connectionManager?.connect(peripheral: peripheral)
                    result(true)
                } else {
                    result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found in scanned list.", details: nil))
                }
            }
        case "disconnect":
            guard let args = call.arguments as? [String: Any],
                  let uuidStr = args["address"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "MAC/UUID is required.", details: nil))
                return
            }
            connectionManager?.disconnect(uuidString: uuidStr)
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - CBCentralManagerDelegate Callbacks

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("BLE Manager: Central manager state updated: \(central.state.rawValue)")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let uuidStr = peripheral.identifier.uuidString
        discoveredPeripherals[uuidStr] = peripheral
        scanner?.didDiscoverPeripheral(peripheral, advertisementData: advertisementData, rssi: RSSI)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let uuidStr = peripheral.identifier.uuidString
        print("BLE Manager: Connected to \(uuidStr)")
        // State codes: 2 = Connected (Android parity), 0 = Disconnected, 1 = Connecting, 3 = Disconnecting
        let stateMap: [String: Any] = ["address": uuidStr, "state": 2]
        channel?.invokeMethod("onConnectionStateChanged", arguments: stateMap)
        
        // Discover services immediately
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let uuidStr = peripheral.identifier.uuidString
        print("BLE Manager: Failed to connect to \(uuidStr)")
        let stateMap: [String: Any] = ["address": uuidStr, "state": 0]
        channel?.invokeMethod("onConnectionStateChanged", arguments: stateMap)
        connectionManager?.removePeripheral(uuidString: uuidStr)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let uuidStr = peripheral.identifier.uuidString
        print("BLE Manager: Disconnected from \(uuidStr)")
        let stateMap: [String: Any] = ["address": uuidStr, "state": 0]
        channel?.invokeMethod("onConnectionStateChanged", arguments: stateMap)
        connectionManager?.removePeripheral(uuidString: uuidStr)
    }
}
