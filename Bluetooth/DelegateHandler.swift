//
//  DelegateHandler.swift
//  Bluetooth
//
//  Created by bnulo on 2/20/22.
//

//import Foundation
import CoreBluetooth
import SwiftUI

class DelegateHandler: NSObject, ObservableObject {
    /*
    let temperature = CBUUID(string: "0x2A6E")
    let digital = CBUUID(string: "0x2A56")
    var ledMask: UInt8    = 0
    let digitalBits = 2 // each digital uses two bits
    let environmentalSensing = CBUUID(string: "0x181A")
    let automationIO = CBUUID(string: "0x1815")
    */
    @Published var statusList = ["👋🏻 Hey There!"]
    var cbCentralManager: CBCentralManager?
    var peripheral : CBPeripheral?

    static let shared = DelegateHandler()
    override init() {
        super.init()
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
}
// MARK: - CBCentralManagerDelegate
extension DelegateHandler: CBCentralManagerDelegate {

    // MARK: - Central Manager did Update State
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        statusList.append("\n✳️ CentralManagerDidUpdateState:")
        switch central.state {
        case .poweredOn:
            // Bluetooth is enabled, authorized, and ready for app use
            // MARK: - start Scan for Peripherals
            central.scanForPeripherals(withServices: nil, options: nil)
            withAnimation {
                statusList.append(".poweredOn")
                statusList.append("\n🔎 Scanning For Peripherals...")
            }
        case .poweredOff:
            // The user has toggled Bluetooth off and will need to turn it back on from Settings or the Control Center.
            // Alert user to turn on Bluetooth
            statusList.append(".poweredOff")
            break
        case .resetting:
            // The connection with the Bluetooth service was interrupted.
            // Wait for next state update and consider logging interruption of Bluetooth service
            statusList.append(".resetting")
            break
        case .unauthorized:
            // The user has refused the app permission to use Bluetooth.
            // The user must re-enable it from the app’s Settings menu.
            // Alert user to enable Bluetooth permission in app Settings
            statusList.append(".unauthorized")
            break
        case .unsupported:
            // The iOS device does not support Bluetooth.
            // Alert user their device does not support Bluetooth and app will not work as expected
            statusList.append(".unsupported")
            break
        case .unknown:
            // The state of the manager and the app’s connection to the Bluetooth service is unknown.
            // Wait for next state update
            statusList.append(".unknown")
            break
        @unknown default:
            break
        }
    }
    // MARK: - Central Manager did Discover Advertisement Data
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        guard peripheral.name != nil else {return}
//         if peripheral.name! == "Thunder Sense #33549" {
        withAnimation {
            statusList.append("\n✅ Sensor Found!")
        }
        //stopScan
        cbCentralManager?.stopScan()
        withAnimation {
            statusList.append("\n✋🏻 Scan stopped")
        }
        //connect
        cbCentralManager?.connect(peripheral, options: nil)
        self.peripheral = peripheral
//        }
    }
    // MARK: - Central Manager did Connect Peripheral
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        withAnimation {
            statusList.append("\n📱 Connected: \(peripheral.name ?? "No Name")")
        }
        //it' discover all service
        peripheral.discoverServices(nil)
        withAnimation {
            statusList.append("\n🔎 Discovering the Services Started")
        }
        //discover EnvironmentalSensing,AutomationIO
//        peripheral.discoverServices([AutomationIO,EnvironmentalSensing])
     
        peripheral.delegate = self
    }
    // MARK: - Central Manager did Disconnect Peripheral
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        withAnimation {
            statusList.append("\n❌ Disconnected : \(peripheral.name ?? "No Name")")
        }
        cbCentralManager?.scanForPeripherals(withServices: nil, options: nil)
        withAnimation {
            statusList.append("\n🔎 Scan for Peripherals Started")
        }
    }
}
// MARK: - CBPeripheralDelegate
extension DelegateHandler: CBPeripheralDelegate {
    // MARK: - Peripheral did Discover Services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
 
        if let services = peripheral.services {
            withAnimation {
                statusList.append("\n🔧 \(services.count) Service(s) found 👇🏻\n")
            }
            //discover characteristics of services
            for (index, service) in services.enumerated() {
              peripheral.discoverCharacteristics(nil, for: service)
                withAnimation {
                    statusList.append("----------------------------")
                    statusList.append("🔧 Service \(index+1)")
                    statusList.append("\n\nService Id\n 👉🏻 \(service.uuid)")
                    statusList.append("\nService Description\n 👉🏻 \(service.description)")
                    statusList
                        .append("\n🔫 discover Characteristics triggered\n")
                }
          }
        }
    }
    // MARK: - Peripheral did Discover Characteristics for Service
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        
        if let characteristics = service.characteristics {
            let serviceId = service.uuid
            let count = characteristics.count
            withAnimation {
                statusList.append("----------------------------")
                statusList
                    .append("\n🔧 Service \(serviceId) has \(count) characteristic(s) 👇🏻")
            }
            for characteristic in characteristics {
                withAnimation {
                    statusList
                        .append("\n\n😀 characteristic Id\n 👉🏻 \(characteristic.uuid)")
                    statusList
                        .append("\ncharacteristic Description\n 👉🏻 \(characteristic.description)")
                }
                /*
                //MARK:- Light Value
                if characteristic.uuid == digital {
                      //write value
                    setDigitalOutput(1, on: true, characteristic: characteristic)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                        self.setDigitalOutput(1, on: false, characteristic: characteristic)
                    })
                    
                }
                    
                //MARK:- Temperature Read Value
                else if characteristic.uuid == temperature {
                    //read value
                    //peripheral.readValue(for: characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
               */
            }
        }
        
    }
    // MARK: - Peripheral didUpdate value for characteristic
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        /*
        if characteristic.uuid == temperature {
                           print("Temp : \(characteristic)")
                let temp = characteristic.tb_uint16Value()

                print(Double(temp!) / 100)
        }
        */
    }
    // MARK: - Peripheral did Write value  for characteristic
    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        print("WRITE VALUE : \(characteristic)")
    }
    
    // MARK: - Helper func to write the value to a characteristic
    /*
    fileprivate func setDigitalOutput(_ index: Int,
                                      on: Bool,
                                      characteristic  :CBCharacteristic) {
           
        let shift = UInt(index) * UInt(digitalBits)
        var mask = ledMask
           
       if on {
           mask = mask | UInt8(1 << shift)
       }
       else {
           mask = mask & ~UInt8(1 << shift)
       }
        let data = Data([mask])
        self.peripheral?.writeValue(data, for: characteristic, type: .withResponse)
           //self.bleDevice.writeValueForCharacteristic(CBUUID.Digital, value: data)
           
           // *** Note: sending notification optimistically ***
           // Since we're writing the full mask value, LILO applies here,
           // and we *should* end up consistent with the device. Waiting to
           // read back after write causes rubber-banding during fast write sequences. -tt
           ledMask = mask
          // notifyLedState()
       }
    */
}
// MARK: - CBCharacteristic
extension CBCharacteristic  {
   func tb_int16Value() -> Int16? {
        if let data = self.value {
            var value: Int16 = 0
            (data as NSData).getBytes(&value, length: 2)
            return value
        }
        return nil
    }
    func tb_uint16Value() -> UInt16? {
        if let data = self.value {
            var value: UInt16 = 0
            (data as NSData).getBytes(&value, length: 2)
            return value
        }
        return nil
    }
}

