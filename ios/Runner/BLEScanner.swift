import CoreBluetooth
import Foundation

/// Manages BLE peripheral scanning using CoreBluetooth.
class BLEScanner: NSObject {
    private var centralManager: CBCentralManager?
    private var onDeviceDiscovered: (([String: Any]) -> Void)?
    private var isScanning = false

    init(centralManager: CBCentralManager?, onDeviceDiscovered: @escaping ([String: Any]) -> Void) {
        self.centralManager = centralManager
        self.onDeviceDiscovered = onDeviceDiscovered
        super.init()
    }

    func startScan() {
        guard let central = centralManager, central.state == .poweredOn else {
            print("BLE Scanner: centralManager not ready or powered on")
            return
        }
        
        guard !isScanning else { return }
        
        print("BLE Scanner: Starting scan...")
        // Scan for all services (passing nil) or select services
        central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        isScanning = true
    }

    func stopScan() {
        guard isScanning else { return }
        print("BLE Scanner: Stopping scan...")
        centralManager?.stopScan()
        isScanning = false
    }

    /// Handles CB Central Manager updates forwarded by the BLEManager.
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unknown Device"
        let deviceMap: [String: Any] = [
            "name": name,
            "address": peripheral.identifier.uuidString,
            "rssi": rssi.intValue
        ]
        onDeviceDiscovered?(deviceMap)
    }
}
