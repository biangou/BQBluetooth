//
//  ViewController.swift
//  BQBluetoothManager
//
//  Created by 边齐 on 2019/12/23.
//  Copyright © 2019 bubblelab. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    //蓝牙外设名字
    let peripheralName = "Drop_409322"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBluetooth()
        
  
    }

    //设置蓝牙
    func setupBluetooth() {
        //添加代理
        BQBluetooth.isLogEnabled = false
        BQBluetooth.addChannel(delegate: self)
       // BQBluetooth.serverUUID = "A002"
       // BQBluetooth.characteristicWriteUUID = "A002"
       // BQBluetooth.characteristicNotifyUUID = ""A002""
        //开始连接
    
    
        //block回调
        
        //蓝牙设备改变
        /// 连接成功后一般情况下不能立即向外设发送数据
        /// 通常会在建立外设对应特征值的监听后发送数据，以避免收不到返回数据等意外发生 这一步放在blockOnPeripheralReady
        ///
        BQBluetooth.blockOnPeripheralStateChange { (peripheral, state) in
//            let peripherlName = peripheral.name ?? "nil name"
//            
//            switch state {
//            case .connnetSuccesed:
//                print("\(peripherlName) 连接成功")
//            case .connnetFaild:
//                print("\(peripherlName) 连接失败")
//            case .disConnnet:
//                print("\(peripherlName) 断开链接")
//            default:break
//            }
        }
        
        BQBluetooth.blockOnNewPeripheral { (peripheral, advertisementData, rssi) in
            let peripherlName = peripheral.name ?? "nil name"
            print("发现新设备 \(peripherlName) advertisementData \(advertisementData) rssi \(rssi)")
        }
        
        //监听已就绪
        BQBluetooth.blockOnPeripheralReady { (peripheral) in
            let peripherlName = peripheral.name ?? "nil name"
            print("已就绪 \(peripherlName)")
        }
        
        //收到数据
        BQBluetooth.blockOnBluetoothReadData { (peripheral, data) in
            print(data.toString())
        }
        
    }

    @IBAction func connectAction(_ sender: UIButton) {
     //   BQBluetooth.autoConnect(peripheralName: peripheralName)
        BQBluetooth.autoConnect(filter: { (preipheral) -> Bool in
            if preipheral.peripheralName == self.peripheralName
            {
                return true
            }
            return false
        }, scantime: 3) { (periPheral, result) in
            switch result {
            case .success:
                print("连接成功")
            case .failure(let error):
                print("连接失败\(error)")
            }
        }
    }
    @IBAction func sendData(_ sender: UIButton) {
        var data = Data([0x66,0xee,0x00,0x05,0x02,0xff,0xfd,0x02])
        data.append(contentsOf: data.toCRCresult())
        print("发送 string \(data.toString())")
       // BQBluetooth.sendeData(data: data)
        BQBluetooth.sendData(peripheral: nil, data: data, serviceUUID: nil, writeUUID: "C304") { (peripheral, data, error) in
            print("error\(error)")
        }
    
    }
    
    @IBAction func disConnectAction(_ sender: UIButton) {
        BQBluetooth.disConnect(peripheralName: peripheralName)
    }
}

extension ViewController: BLEDelegate{
    func tag() -> String {
        return "ViewController"
    }
     
    //设备连接状态改变
    func bluetoothPeripheralStateChange(peripheral: CBPeripheral, state: peripheralStatus) {
//        switch state {
//        case .connnetSuccesed:
//            print("连接成功")
//        case .connnetFaild:
//            print("连接失败")
//        case .disConnnet:
//            print("断开链接")
//        default:break
//        }
    }
    
    // 手机端蓝牙状态改变
    func bluetoothCentralManagerDidUpdateState(states: CBManagerState) {
      //  print(states.rawValue)
    }
    
    
    //收到此回调后代表该peripheral可以发送数据
    func bluetoothPeripheralReady(peripheral: CBPeripheral) {
        print("\(peripheral.name ?? "没有名字")已经就绪，可以发送数据")
        
    }
    
    //收到的数据在此处理
    func bluetoothPeripheral(_ peripheral: CBPeripheral, didReadData data: Data){
        print("收到数据 \(data.toString())")
    }
}
