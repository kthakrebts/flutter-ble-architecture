import CoreBluetooth
import Foundation

/// Manages connections to CoreBluetooth Peripherals.
class BLEConnectionManager: NSObject, CBPeripheralDelegate {
    private var centralManager: CBCentralManager?
    private var activePeripherals = [String: CBPeripheral]()
    
    private var onConnectionChanged: ((String, String) -> Void)?
    private var onServicesDiscovered: ((String, [String]) -> Void)?

    init(
        centralManager: CBCentralManager?,
        onConnectionChanged: @escaping (String, String) -> Void,
        onServicesDiscovered: @escaping (String, [String]) -> Void
    ) {
        self.centralManager = centralManager
        self.onConnectionChanged = onConnectionChanged
        self.onServicesDiscovered = onServicesDiscovered
        super.init()
    }

    func connect(peripheral: CBPeripheral) {
        let uuidStr = peripheral.identifier.uuidString
        activePeripherals[uuidStr] = peripheral
        peripheral.delegate = self
        
        print("BLE Connection Manager: Connecting to \(uuidStr)")
        centralManager?.connect(peripheral, options: nil)
    }

    func disconnect(uuidString: String) {
        guard let peripheral = activePeripherals[uuidString] else {
            print("BLE Connection Manager: No peripheral found for UUID \(uuidString)")
            return
        }
        print("BLE Connection Manager: Disconnecting from \(uuidString)")
        centralManager?.cancelPeripheralConnection(peripheral)
    }

    func getPeripheral(uuidString: String) -> CBPeripheral? {
        return activePeripherals[uuidString]
    }

    func removePeripheral(uuidString: String) {
        activePeripherals.removeValue(forKey: uuidString)
    }

    // MARK: - CBPeripheralDelegate callbacks

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let uuidStr = peripheral.identifier.uuidString
        if let error = error {
            print("BLE Connection Manager: Service discovery error: \(error.localizedDescription)")
            onServicesDiscovered?(uuidStr, [])
            return
        }

        let services = peripheral.services?.map { $0.uuid.uuidString } ?? []
        print("BLE Connection Manager: Discovered services for \(uuidStr): \(services)")
        onServicesDiscovered?(uuidStr, services)
    }
}
