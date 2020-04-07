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
    let peripheralName = "Drop_6853EE"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBluetooth()

    }

    //设置蓝牙
    func setupBluetooth() {
        //添加代理
        BQBluetooth.addChannel(delegate: self)
        BQBluetooth.serverUUID = "A002"
        BQBluetooth.characteristicWriteUUID = "C304"
        BQBluetooth.characteristicNotifyUUID = "C305"

        //开始连接
        BQBluetooth.autoConnect(peripheralName: peripheralName)
    }

    @IBAction func sendData(_ sender: UIButton) {
        let data = Data([0x66,0xee,0x00,0x05,0x02,0x16,0x55,0x71,0xA0])
        BQBluetooth.writeData(data: data)
    }
    @IBAction func disConnectAction(_ sender: UIButton) {
        BQBluetooth.disConnect(peripheralName: peripheralName)
    }
}

extension ViewController: BLEDelegate{
    func tag() -> String {
        return "ViewController"
    }
     
    func bluetoothPeripheralStateChange(peripheral: CBPeripheral, state: peripheralStatus) {
        switch state {
        case .connnetSuccesed:
            print("连接成功")
        case .connnetFaild:
            print("连接失败")
        case .disConnnet:
            print("断开链接")
        default:break
        }
    }
    
    //收到此回调后代表该peripheral可以发送数据
    func bluetoothReady(peripheral: CBPeripheral) {
        print("\(peripheral.name ?? "没有名字")已经就绪，可以发送数据")
        
    }
    
    //收到的数据在此处理
    func bluetoothPeripheral(_ peripheral: CBPeripheral, didReadData data: Data){
        print(data)
    }
}
