//
//  BQBluetoothDelegate.swift
//  BQBluetoothManager
//
//  Created by 边齐 on 2019/10/23.
//  Copyright © 2019 bubblelab. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc enum peripheralStatus:Int {
    case connnetSuccesed = 0
    case connnetFaild = 1
    case disConnnet = 2
}

//MARK: - delegate
@objc protocol BLEDelegate:NSObjectProtocol {
    // 用来区分不同的代理 ，通常用当前类的类名代替
    func tag() -> String;
    
    //MARK:  常用方法
    
    /// 状态变更
    /// - Parameter peripheral: 当前状态变更的设备
    /// - Parameter status: 变更的状态
    @objc optional func bluetoothPeripheralStateChange(peripheral:CBPeripheral,state:peripheralStatus);
    
    
    /// 发现新外设
    /// - Parameter peripheral: 蓝牙外设
    /// - Parameter RSSI: 蓝牙外设信号强度
    /// - Parameter advertisementData: 蓝牙外设广播附带数据
    /// 有时候外设修改名字后因为缓存原因 peripheral.name不会变动，此时可以用advertisementData["kCBAdvDataLocalName"]来区分设备
    @objc optional func bluetoothNewPeripheral(peripheral:CBPeripheral,advertisementData:[String : Any],RSSI:NSNumber)
        
    /// 外设已经就绪，可以向外设发送指令
    /// - Parameter peripheral: 蓝牙外设
    @objc optional func bluetoothPeripheralReady(peripheral:CBPeripheral)
    
    
    /// 蓝牙外设收到的数据
    /// - Parameter data: 收到的数据
    @objc optional func bluetoothPeripheral(_ peripheral: CBPeripheral, didReadData data: Data)
    
    //MARK:  详细方法
    
    @objc optional func bluetoothCentralManagerDidUpdateState(states: CBManagerState)

}

//MARK: - block

//MARK:  常用方法

/// 状态变更
/// - Parameter peripheral: 当前状态变更的设备
/// - Parameter status: 变更的状态
typealias BQPeripheralStateChangeBlock = (_ peripheral: CBPeripheral,_ state:peripheralStatus) -> Void

/// 发现新外设
/// - Parameter peripheral: 蓝牙外设
/// - Parameter RSSI: 蓝牙外设信号强度
/// - Parameter localName:  蓝牙外设广播附带数据
/// 有时候外设修改名字后因为缓存原因 peripheral.name不会变动，此时可以用advertisementData["kCBAdvDataLocalName"]来区分设备
typealias BQNewPeripheralBlock = (_ peripheral: CBPeripheral,_ advertisementData:[String : Any], _ RSSI:NSNumber) -> Void

/// 外设已经就绪，可以向外设发送指令
/// - Parameter peripheral: 蓝牙外设
typealias BQPeripheralReadyBlock = (_ peripheral: CBPeripheral) -> Void

/// 蓝牙外设收到的数据
/// - Parameter data: 收到的数据
typealias BQbluetoothReadDataBlock = (_ peripheral: CBPeripheral,_ data: Data) -> Void

class BQBlock: NSObject {
    // 用来区分不同的代理 ，通常用当前类的类名代替
    typealias BQTagBlock = () -> String

    //蓝牙外设状态改变
    var blockOnPeripheralStateChange: BQPeripheralStateChangeBlock?
    //发现新外设
    var blockOnNewPeripheral: BQNewPeripheralBlock?
    //新外设已就绪，可以发送数据
    var blockOnPeripheralReady: BQPeripheralReadyBlock?
    //蓝牙外设收到的数据
    var blockOnBluetoothReadData: BQbluetoothReadDataBlock?
}
    
