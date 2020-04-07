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
    var isRady: Bool = false //设备是否处于就绪状态
    var writeType:CBCharacteristicWriteType = .withResponse
    
    
    
    //单次传输数据包 单位字节
    let MAX_COUNT = 2048

    
    //AMRK: - 蓝牙使用方法
    
    /// 向蓝牙外设发送数据 向指定的serverUUID和 writeUUID发数据
    /// - Parameter data: 待发送的数据
    /// - Parameter serviceUUID: serviceUUID
    /// - Parameter writeUUID: writeUUID
    /// - Parameter type: 发送需不需要回复该消息是否发送成功
    func send(data: Data,serviceUUID:String?,writeUUID:String?,type:CBCharacteristicWriteType?){
        let characteristic = searchWriteCharacteristic(serviceUUID: serviceUUID, writeUUID: writeUUID)
        let writeType = type == nil ? BQBluetooth.writeType : type

        //没有符合条件的特征值则直接返回
        guard let _ = characteristic else{
            return
        }
        DispatchQueue.global().async {
            self.sendAsync(data: data, characteristic: characteristic!,type:writeType!)
        }
    }

    //MARK: - private
    //设备中的所有服务
    private var serviceDic: [String:CBService] = [:]
    
    //默认的写特征值和读特征值 默认为nil
    private var characteristicWrite: CBCharacteristic?
    private var characteristicNotify: CBCharacteristic?
    
    //特征值列表
    private var characteristicDic: [CBService:[CBCharacteristic]] = [:]

    //传递数据
    private func sendAsync(data: Data, characteristic: CBCharacteristic,type:CBCharacteristicWriteType) {
        var data = data
        //本设备单次传输最大字节值 ，跟手机型号有关，不同手机型号各不相同
        let mtu:Int = self.peripheral?.maximumWriteValueLength(for: type) ?? 20
        //如果单次数据过大则分开传递
        var bufferData:[UInt8] = []
        while data.count > 0 {
            while bufferData.count < mtu && data.count > 0 {
                bufferData.append(data.removeFirst())
            }
            self.peripheral?.writeValue(Data(bufferData), for: characteristic,type: type)
        }
    }
    
    //MARK: Characteristic
    /// 根据service 和writeUUID 找出特征值
    /// - Parameter serviceUUID: serviceUUID
    /// - Parameter writeUUID: 写的UUID
    func searchWriteCharacteristic(serviceUUID:String? = nil , writeUUID:String? = nil) -> CBCharacteristic?{
        guard writeUUID != nil else {
            return characteristicWrite
        }
        return  searchCharacteristic(serviceUUID: serviceUUID, operationUUID: writeUUID!)
    }
     
    /// 根据service 和notifyUUID 找出特征值
    /// - Parameter serviceUUID: serviceUUID
    /// - Parameter notifyUUID: 读的UUID
    func searchNotifyCharacteristic(serviceUUID:String? = nil , notifyUUID:String? = nil) -> CBCharacteristic?{
        guard notifyUUID != nil else {
            return characteristicNotify
        }
        return  searchCharacteristic(serviceUUID: serviceUUID, operationUUID: notifyUUID!)
    }
    
    /// 根据service 和特征值UUID 找出特征值
    /// - Parameter serviceUUID: serviceUUID
    /// - Parameter operationUUID: 读或写的UUID
    func searchCharacteristic(serviceUUID:String? = nil , operationUUID:String) -> CBCharacteristic?{
        var characteristicArray:[CBCharacteristic]
        //如果serviceUUID有值，则只取对应的uuid的service内特征值做比对
        if let serviceUUID = serviceUUID{
            let service = serviceDic[serviceUUID]!
            characteristicArray = characteristicDic[service]!
        }else {
            //否则取出所有的service的特征值比对
            characteristicArray = characteristicDic.flatMap({ $0.value})
        }
        //从储存的特征值列表中根据给定特征值的UUID找出符合的特征值
        return  characteristicArray.filter { $0.uuid == CBUUID(string: operationUUID)}.first
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
        for service in peripheral.services! {
            BQPrint("外设中的服务有\(service)")
            serviceDic[service.uuid.uuidString] = service
            // 设备搜索所有服务中的特征值
            peripheral.discoverCharacteristics(nil, for: service)
            
//            //只对需要的特征值搜索
//            if let writeUUID = BQBluetooth.characteristicWriteUUID,
//                let NotifyUUID = BQBluetooth.characteristicNotifyUUID{
//                let CBUUIDArray = [CBUUID(string:writeUUID),CBUUID(string: NotifyUUID)]
//                peripheral.discoverCharacteristics(CBUUIDArray, for: service)
//            }
        }
    }
    
    //发现特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        var array: [CBCharacteristic] = []
        print("ssssss")
        for characteristic in service.characteristics! {
            BQPrint("外设中的特征有：\(characteristic)")
            //记录写特征
            if let UUIDStr = BQBluetooth.characteristicWriteUUID{
                if characteristic.uuid == CBUUID(string: UUIDStr) {
                    characteristicWrite = characteristic
                }
            }
            //记录读特征
            if let UUIDStr = BQBluetooth.characteristicNotifyUUID{
                if characteristic.uuid == CBUUID(string: UUIDStr) {
                    characteristicNotify = characteristic
                    // 订阅
                    peripheral.setNotifyValue(true, for: self.characteristicNotify!)
                }
            }
            //记录所有的特征值
            array.append(characteristic)
        }
        
        characteristicDic[service] = array
    }

    //订阅状态
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    
        if let error = error {
            BQPrint("订阅失败: \(error)")
            return
        }
        
        if characteristic.isNotifying {
            BQPrint("订阅成功")
            for delegate in BQBluetooth.channels.delegateArray {
                isRady = true
                delegate.bluetoothReady?(peripheral: peripheral)
            }
        } else {
            for _ in BQBluetooth.channels.delegateArray {
            }
            BQPrint("取消订阅")
        }
    }
    
    
    // 接收到数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        BQPrint("已经接收到数据")
        //返回数据如果为nil直接返回
        guard characteristic.value != nil else {
            return
        }

        BQBluetooth.channels.delegateArray.forEach { (delegate) in
            delegate.bluetoothPeripheral?(peripheral, didReadData: characteristic.value!)
        }
    }
    
    //写入数据响应
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        BQPrint("已经写入数据")

    }
    
}
