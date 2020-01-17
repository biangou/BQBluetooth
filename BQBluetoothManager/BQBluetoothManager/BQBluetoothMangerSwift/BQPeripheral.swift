//
//  BQPeripheral.swift
//  BlueToothManager
//
//  Created by 边齐 on 2019/10/21.
//  Copyright © 2019 bubblelab. All rights reserved.
//

import UIKit
import CoreBluetooth

class BQPeripheral: NSObject {
    var peripheralName: String = ""
    var peripheralSN: String?

    var peripheral:CBPeripheral?
    
    
    
    
    //单次传输数据包 单位字节
    let MAX_COUNT = 2048

    
    //AMRK: - 蓝牙使用方法
    
    /// 向蓝牙外设发送数据 默认向默认的serverUUID和 writeUUid发数据
    /// - Parameter data: 待发送的数据
    func sendAsync(data: Data){
        DispatchQueue.global().async {
            self.send(data: data)
        }
    }
    
    //MARK: - private
    //设备中的所有服务
    private var serviceArray: [CBService]?
    
    //默认的写特征值和读特征值 默认为nil
    private var characteristicWrite: CBCharacteristic?
    private var characteristicNotify: CBCharacteristic?
    
    //传递数据
    private func send(data: Data) {
        guard characteristicWrite != nil  else {
            return
        }
        var data = data
        //本设备单次传输最大字节值 ，跟手机型号有关，不同手机型号各不相同
        let mtu:Int = self.peripheral?.maximumWriteValueLength(for: .withResponse) ?? 20
        //如果单次数据过大则分开传递
        var bufferData:[UInt8] = []
        while data.count > 0 {
            while bufferData.count < mtu && data.count > 0 {
                bufferData.append(data.removeFirst())
            }
        }
        self.peripheral?.writeValue(data, for: characteristicWrite!,type: .withResponse)
    }
    
    
    
    init(peripheral:CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        peripheral.delegate = self

    }
}

extension BQPeripheral:CBPeripheralDelegate{
    //发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        self.serviceArray = peripheral.services
        for service in peripheral.services! {
            BQPrint("外设中的服务有\(service)")
            // 设备搜索所有服务中的特征值
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    //发现特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            BQPrint("外设中的特征有：\(characteristic)")
            if characteristic.uuid == CBUUID(string: BQBluetooth.characteristicWriteUUID!) {
                characteristicWrite = characteristic
            }else if characteristic.uuid == CBUUID(string: BQBluetooth.characteristicReadUUID!) {
                characteristicNotify = characteristic
            }
        }
        // 读取特征中数据
        peripheral.readValue(for: self.characteristicNotify!)
        // 订阅
        peripheral.setNotifyValue(true, for: self.characteristicNotify!)
    }
    
    //订阅状态
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    
        if let error = error {
            BQPrint("订阅失败: \(error)")
            return
        }
        if characteristic.isNotifying {
            BQPrint("订阅成功")
            for delegate in BQBluetoothManager.share.BLEDelegateArray {
                 //  isRady = true
                delegate.bluetoothReady?(peripheral: peripheral)
               }
           } else {
            for listener in BQBluetoothManager.share.BLEDelegateArray {
            }
            BQPrint("取消订阅")
        }
    }
    
    
    // 接收到数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    //写入数据响应
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        
    }
    
}
