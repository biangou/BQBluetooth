//
//  BQBluetoothSwift.swift
//  BlueToothManager
//
//  Created by 边齐 on 2019/10/21.
//  Copyright © 2019 bubblelab. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

//全局变量，方便调用
let BQBluetooth = BQBluetoothManager.share

class BQBluetoothManager: NSObject {

    // 待连接蓝牙外设的serverUUID,默认为空
    var serverUUID: String? = nil
    // 待连接蓝牙外设的写入UUID，默认为空
    var characteristicWriteUUID: String? = nil
    // 待连接蓝牙外设的读取UUID，默认为空
    var characteristicNotifyUUID: String? = nil
    // 待连接蓝牙外设的写入type，默认为.withResponse
    var writeType: CBCharacteristicWriteType = .withResponse
    
    //是否需要打印日志  默认为可打印
    var isLogEnabled:Bool = true
    
    //推荐在断开连接处自己实现重连操作
    //断开自动重连次数  0表示不需要 -1表示无限次重连
    // var reConnectTime:Int = 3
    
    // 外部调用单例
    static let share = BQBluetoothManager()
    
    //当前手机蓝牙设备状态,默认为可使用状态
    var centralManagerState:CBManagerState = .poweredOff
    
    
    //实现该方法的代理的集合
    var channels = BQBluetoothChannel()
    
    //添加一个新的蓝牙回调监听
    func addChannel(delegate:BLEDelegate) {
        channels.addDelegate(delegate: delegate)
    }
    
    
    //MARK: - private
    private var centralManager: BQCentralManager!
    private var bluetoothCahnnel =  BQBluetoothChannel()
    
    //返回可用设备
    func validPeripheral(_ BQPeripheral:BQPeripheral?) -> BQPeripheral? {
        //如果传入设备为空
        guard BQPeripheral == nil else {
            return BQPeripheral
        }
        //则返回已连接设备的第一个设备
        return centralManager.connectedPeripherals.first
    }
    
    
    //MARK: - initialize
    override init() {
        super.init()
        centralManager = BQCentralManager()
    }
    
    init(queue:DispatchQueue = .main,options:[String:Any]? = nil) {
        super.init()
        centralManager = BQCentralManager(queue: queue, options: options)
    }
    
    
    //MARK: - 使用代理方法回调时调用
    
    
    /// 蓝牙外设状态改变的回调
    /// - Parameter channel: 频道名称
    /// - Parameter block: block
    func blockOnPeripheralStateChange(_ channel: String? = nil,block: @escaping BQPeripheralStateChangeBlock)  {
        bluetoothCahnnel.currentChannelCallback().blockOnPeripheralStateChange = block
    }
    
    
    
    
    ///判断一个设备是否已经蓝牙连接并可以操作
    open func isPeripheralReady(_ peripheralName: String) -> Bool {
        return centralManager.isPeripheralReady(peripheralName)
    }
    
    //MARK: - 蓝牙操作
    
    /// 蓝牙开始扫描周围外设
    func scan(time:Int? = nil) {
        centralManager.scan(time: time)
    }
    
    /// 蓝牙停止扫描周围外设
    func stopScan() {
        centralManager.stopScan()
    }
    
    /// 根据蓝牙外设名称返回一个蓝牙外设
    /// - Parameter periPheralName: 蓝牙外设名字
    func periphralByName(periPheralName:String) -> BQPeripheral? {
       return centralManager.periphralByName(periPheralName: periPheralName)
    }
    
    /// 返回当前连接的所有蓝牙外设
    func findConnectedPeriphrals() -> [BQPeripheral] {
        return centralManager.connectedPeripherals
    }
    
    //MARK: - Rssi 读取蓝牙外设rssi
    
    //MARK: - 蓝牙连接，断开，重连等操作
    /// 蓝牙连接操作
    /// - Parameter peripheral: 蓝牙外设
    func connect(BQPeripheral:BQPeripheral? = nil) {
        centralManager.connect(BQPeripheral: BQPeripheral)
    }
    
    /// 蓝牙连接操作
    /// - Parameter peripheral: 蓝牙外设
    func connect(peripheral:CBPeripheral?) {
        centralManager.connect(peripheral: peripheral)
    }
    
    /// 根据设备名称连接设备 推荐使用
    /// - Parameter peripheralName: 蓝牙外设名称
    func autoConnect(peripheralName:String){
        centralManager.autoConnect(peripheralName: peripheralName)
    }
    
    /// 断开蓝牙外设
    /// - Parameter peripheral: 需要断开的蓝牙外设
    func disConnect(peripheral:CBPeripheral) {
        centralManager.disConnect(peripheral: peripheral)
    }
    
    /// 断开蓝牙外设
    /// - Parameter peripheralName: 需要断开的蓝牙外设名称
    func disConnect(peripheralName:String) {
        let peripheral = periphralByName(periPheralName: peripheralName)
        guard let _ = peripheral else {
            return
        }
        disConnect(peripheral: peripheral!.peripheral!)
    }
    
    //MARK: - 蓝牙读写操作
    
    /// 向蓝牙外设的写入数据操作
    /// - Parameter peripheral: 要写入数据的蓝牙外设   nil时会为所有已连接设备发送数据
    /// - Parameter data: 发送给蓝牙外设的数据（也可以说是命令）
    /// - Parameter serviceUUID: 服务UUID，咨询硬件工程师提供  nil时会向默认serviceUUID发送
    /// - Parameter writeUUID: 写入UUID，咨询硬件工程师提供    nil时会向默认writeUUID发送
    func writeData(peripheral:BQPeripheral? = nil, data:Data,serviceUUID: String? = nil,writeUUID:String? = nil,type:CBCharacteristicWriteType? = nil) {
        
        let sendPeripheral = validPeripheral(peripheral)
        guard sendPeripheral != nil else{
            //抛出异常 无可用设备
            return
        }
        
        //如果该设备不处于就绪状态则直接返回 ，通常见于连接成功但还没有订阅完成或订阅失败
        guard sendPeripheral!.isRady == true else{
            return
        }

        assert(writeUUID == nil || BQBluetooth.characteristicWriteUUID == nil , "characteristicWriteUUID Could not be nil")
        //向设备写入数据
        sendPeripheral!.send(data: data,serviceUUID: serviceUUID,writeUUID: writeUUID, type: type)
    }
    
    /// 监听蓝牙外设的返回的数据
    /// - Parameter peripheral: 要监听数据返回的蓝牙外设   nil时会为所有已连接设备发送数据
    /// - Parameter serviceUUID: 服务UUID，咨询硬件工程师提供  nil时会默认serviceUUID
    /// - Parameter notifyUUID: 监听UUID，咨询硬件工程师提供    nil时会监听默认notifyUUID
    func notifyData(peripheral:BQPeripheral? = nil,serviceUUID: String? = nil,notifyUUID:String? = nil) {
        
        let nofifyPeripheral = validPeripheral(peripheral)
        guard nofifyPeripheral != nil else{
            //抛出异常 无可用设备
            return
        }

        assert(notifyUUID == nil || BQBluetooth.characteristicNotifyUUID == nil , "characteristicWriteUUID Could not be nil")
        // 订阅设备
        nofifyPeripheral?.notify(serviceUUID: serviceUUID, notifyUUID: notifyUUID)
    }
    
    
}



