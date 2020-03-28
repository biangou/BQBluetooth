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
    let peripheralName = "Drop_4CD09E"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBluetooth()
    }

    //设置蓝牙
    func setupBluetooth() {
        //添加代理
        BQBluetooth.addDelegate(delegate: self)
        BQBluetooth.serverUUID = "A002"
        BQBluetooth.characteristicNotifyUUID = "C305"
        //开始连接
        BQBluetooth.autoConnect(peripheralName: peripheralName)
    }

    @IBAction func sendData(_ sender: UIButton) {
        let data = Data()
        BQBluetooth.writeData(data: data)
        
    }
}

extension ViewController: BLEDelegate{
    func tag() -> String {
        return "ViewController"
    }
    
    func bluetoothPeripheralStateChange(peripheral: CBPeripheral, state: peripheralStatus) {
        print("设备名为\(peripheral.name ?? "没有名字") 状态变为\(state)")
        switch state {
        case .connnetSuccesed:
            print("")
        case .connnetFaild:
            print("")
        case .disConnnet:
            print("")
        default:
            break
        }
    }
    
    //收到此回调后代表该peripheral可以发送数据
    func bluetoothReady(peripheral: CBPeripheral) {
        print("\(peripheral.name ?? "没有名字")已经就绪，可以发送数据")
        
    }
    
    //收到的数据在此处理
    func bluetoothPeriphe(_ peripheral: CBPeripheral, didReadData data: [Any]){
        print("收到的数据为 \(data)")
    }
}
