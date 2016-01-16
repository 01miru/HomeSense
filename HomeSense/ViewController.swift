//
//  ViewController.swift
//  HomeSense
//
//  Created by Dorian Nowak on 09.01.2016.
//  Copyright © 2016 Dorian Nowak. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{

    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var connectionStatus: UILabel!
    
    var dataShown = false
    var centralManager:CBCentralManager!
    var sensorPeripheral: CBPeripheral!
    var bluetoothReady = false
    let serviceUUID = CBUUID(string: "0000ffe0-0000-1000-8000-00805f9b34fb")        // Default HM-10 service UUID
    let characteristicUUID = CBUUID(string: "0000ffe1-0000-1000-8000-00805f9b34fb") // Default HM-10 characteristic UUID
    let deviceName = "HMSoft"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let view: UIView = UIView(frame: CGRectMake(0.0, 0.0, self.view.bounds.width, self.view.bounds.height))
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 253 / 255, green: 197 / 255, blue: 108/255, alpha: 1.0).CGColor, UIColor(red: 241/255, green: 106/255, blue: 150/255, alpha: 1.0).CGColor]
        self.view.layer.insertSublayer(gradient, atIndex: 0)
        startUpCentralManager()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return UIStatusBarStyle.LightContent
        
    }

    func startUpCentralManager(){
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func sensorTagFound (advertisementData: [NSObject : AnyObject]!) -> Bool {
        
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        return (nameOfDeviceFound == self.deviceName)
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if self.sensorTagFound(advertisementData) == true {
            self.centralManager.stopScan()
            self.sensorPeripheral = peripheral
            self.sensorPeripheral.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        else {
            // print("Not Found")
        }
        
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        self.connectionStatus.text = "Discovering peripheral services"
        peripheral.discoverServices(nil)
        
    }
    
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        self.connectionStatus.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        self.connectionStatus.text = "Looking at peripheral services"
        for service in peripheral.services! {
            let thisService = service as CBService
            if thisService.UUID == self.serviceUUID {
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        self.connectionStatus.text = "Waiting for data"
               
        for charateristic in service.characteristics! {
            let thisCharacteristic = charateristic as CBCharacteristic
            if thisCharacteristic.UUID == self.characteristicUUID {
                self.sensorPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        self.connectionStatus.text = "Connected"
        
        let humidity = HomeSense.getHumidity(characteristic.value!)
        let temperature = HomeSense.getTemperature(characteristic.value!)
        
        self.humidity.text = "\(humidity) %"
        self.temperature.text = "\(temperature) °C"
        
        // Eye candy ;-)
        
        if !self.dataShown {
            
            UIView.animateWithDuration(0.5, animations: {
                self.humidityLabel.alpha = 1.0
            })
            
            UIView.animateWithDuration(0.5, delay: 0.1, options: [], animations: {
                self.humidity.alpha = 1.0
            }, completion: nil)
            
            UIView.animateWithDuration(0.5, delay: 0.2, options: [], animations: {
                self.temperatureLabel.alpha = 1.0
            }, completion: nil)
            
            UIView.animateWithDuration(0.5, delay: 0.3, options: [], animations: {
                self.temperature.alpha = 1.0
                }, completion: nil)
            
            self.dataShown = true
        }
        
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        var msg = ""
        switch (central.state) {
        case .PoweredOff:
            msg = "BLE hardware is powered off"
        case .PoweredOn:
            msg = "BLE hardware is ready"
            bluetoothReady = true;
        case .Resetting:
            msg = "BLE hardware is resetting"
        case .Unauthorized:
            msg = "BLE state is unauthorized"
        case .Unknown:
            msg = "BLE state is unknown"
        case .Unsupported:
            msg = "BLE hardware is unsupported on this platform"
        }

        self.connectionStatus.text = msg
        
        if bluetoothReady {
            central.scanForPeripheralsWithServices(nil, options: nil)
        }
        
    }
}

