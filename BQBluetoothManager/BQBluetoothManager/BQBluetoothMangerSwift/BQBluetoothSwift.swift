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
    
    // 配置连接外设的参数，如service，character
    var configuration = BQConfiguration()
        
    //是否需要打印日志  默认为可打印
    var isLogEnabled: Bool = true
    
    // 推荐在断开连接处自己实现重连操作
    // 断开自动重连次数  0表示不需要 -1表示无限次重连
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
    var bluetoothChannel =  BQBluetoothChannel()
    
    //返回可用设备
    func validPeripheral(_ BQPeripheral:BQPeripheral?) -> BQPeripheral? {
        //如果传入设备为空
        guard BQPeripheral == nil else {
            return BQPeripheral
        }
        //则返回已连接设备的第一个设备
        return centralManager.connectedPeripherals.first
    
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        centralManager = BQCentralManager()
    }
    
    /*
    CBCentralManagerOptionShowPowerAlertKey对应的BOOL值，当设为YES时，表示CentralManager初始化时，如果蓝牙没有打开，将弹出Alert提示框
    CBCentralManagerOptionRestoreIdentifierKey对应的是一个唯一标识的字符串，用于蓝牙进程被杀掉恢复连接时用的。
     */
   
    init(queue:DispatchQueue = .main, configuration: BQConfiguration , options:[String:Any]? = nil) {
        super.init()
        centralManager = BQCentralManager(queue: queue, options: options)
        self.configuration = configuration
    }
    
    
    //MARK: - 回调数据
    
    /// 蓝牙外设状态改变
    /// - Parameter channel: 频道名称
    /// - Parameter block: block
    func blockOnPeripheralStateChange(_ channel: String? = nil,block: @escaping BQPeripheralStateChangeBlock)  {
        bluetoothChannel.currentChannelCallback().blockOnPeripheralStateChange = block
    }
    
    /// 发现新外设
    func blockOnNewPeripheral(_ channel: String? = nil,block: @escaping BQNewPeripheralBlock)  {
        bluetoothChannel.currentChannelCallback().blockOnNewPeripheral = block
    }
    
    /// 新外设已就绪，可以接收数据
    func blockOnPeripheralReady(_ channel: String? = nil,block: @escaping BQPeripheralReadyBlock)  {
        bluetoothChannel.currentChannelCallback().blockOnPeripheralReady = block
    }

    /// 蓝牙外设收到的数据
    func blockOnBluetoothReadData(_ channel: String? = nil,block: @escaping BQbluetoothReadDataBlock)  {
        bluetoothChannel.currentChannelCallback().blockOnBluetoothReadData = block
    }
    
    ///判断一个设备是否已经蓝牙连接并可以操作
    open func isPeripheralReady(_ peripheralName: String) -> Bool {
        return centralManager.isPeripheralReady(peripheralName)
    }
    
    //MARK: - 蓝牙操作
    /*
     CBCentralManagerScanOptionAllowDuplicatesKey设置为NO表示不重复扫瞄已发现设备，为YES就是允许。
     CBCentralManagerOptionShowPowerAlertKey设置为YES就是在蓝牙未打开的时候显示弹框
     */
    /// 蓝牙开始扫描周围外设
    func scan(withDuration duration: TimeInterval? = nil,
              filter: BQFilterPeripheralHandler? = nil,
              options: [String:Any]? = [CBCentralManagerScanOptionAllowDuplicatesKey: false],
              progressHandler: BQScanProgressHandler? = nil,
              completionHandler: BQScanCompletionHandler? = nil)
    {
         
        centralManager.scan(withDuration: duration,filter: filter, options: options, progressHandler: progressHandler, completionHandler: completionHandler)
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
    /// 蓝牙连接
    /// - Parameter peripheral: 蓝牙外设
    func connect(BQPeripheral:BQPeripheral? = nil) {
        centralManager.connect(peripheral: BQPeripheral)
    }
    

    /// 蓝牙连接 指定筛选方式的蓝牙外设
    func connect(peripheral: BQPeripheral,
                 filter: BQFilterPeripheralHandler? = nil,
                 options: [String: Any]? = nil,
                 completionHandler: BQConnectPeripheralCompletionHandler? = nil)
    {
        centralManager.connect(peripheral: peripheral, filter: filter,options: options, completionHandler: completionHandler)
    }
    
    /// 根据设备名称连接设备 推荐使用
    /// - Parameter peripheralName: 蓝牙外设名称
    func autoConnect(peripheralName: String, scantime: TimeInterval = 5, completionHandler: BQConnectPeripheralCompletionHandler? = nil){
        centralManager.autoConnect(peripheralName: peripheralName,scantime:scantime, completionHandler: completionHandler)
    }
    
    /// 扫描并连接符合筛选条件的第一个设备 推荐使用
    /// - Parameter filter: 筛选条件
    /// - Parameter scantime: 扫描时间
    /// - Parameter completionHandler: 操作回调
    func autoConnect(filter: @escaping BQFilterPeripheralHandler, scantime: TimeInterval = 5, connectOptions: [String: Any]? = nil, completionHandler: BQConnectPeripheralCompletionHandler? = nil){
        centralManager.autoConnect(filter: filter, scantime: scantime, connectOptions: connectOptions, completionHandler: completionHandler)
    }
    
    
    /// 断开蓝牙外设
    /// - Parameter peripheral: 需要断开的蓝牙外设
    func disConnect(peripheral: CBPeripheral) {
        centralManager.disConnect(peripheral: peripheral)
    }
    
    /// 断开蓝牙外设
    /// - Parameter peripheralName: 需要断开的蓝牙外设名称
    func disConnect(peripheralName:String) {
        let peripheral = periphralByName(periPheralName: peripheralName)
        guard let _ = peripheral else {
            return
        }
        disConnect(peripheral: peripheral!.peripheral)
    }
    
    //MARK: - 蓝牙读写操作
    
    /// 向蓝牙外设的写入数据    返回数据在blockOnBluetoothReadData
    /// - Parameter peripheral: 要写入数据的蓝牙外设   nil时会为所有已连接设备发送数据
    /// - Parameter data: 发送给蓝牙外设的数据（也可以说是命令）
    /// - Parameter serviceUUID: 服务UUID，咨询硬件工程师提供  nil时会向默认serviceUUID发送
    /// - Parameter writeUUID: 写入UUID，咨询硬件工程师提供    nil时会向默认writeUUID发送
    func sendData(peripheral:BQPeripheral? = nil,
                   data:Data,
                   serviceUUID: String? = nil,
                   writeUUID:String? = nil,
                   type:CBCharacteristicWriteType? = nil,
                   completionHandler: BQSendDataCompletionHandler? = nil)
    {
        guard let sendPeripheral = validPeripheral(peripheral), sendPeripheral.peripheral.state == .connected else{
            //设备未连接
            completionHandler?(peripheral, data, BQError.notConnectPeripheral)
            return
        }

        assert(writeUUID != nil || BQBluetooth.configuration.characteristicWriteUUID != nil , "characteristicWriteUUID Could not be nil")
        //向设备写入数据
        sendPeripheral.send(data: data,serviceUUID: serviceUUID,writeUUID: writeUUID, type: type,completionHandler:completionHandler)
    }
    
    /// 订阅蓝牙外设的指定特征值     订阅结果在blockOnPeripheralReady
    /// - Parameter peripheral: 要监听数据返回的蓝牙外设   nil时会为所有已连接设备发送数据
    /// - Parameter serviceUUID: 服务UUID，咨询硬件工程师提供  nil时会默认serviceUUID
    /// - Parameter notifyUUID: 监听UUID，咨询硬件工程师提供    nil时会监听默认notifyUUID
    func notify(peripheral:BQPeripheral? = nil,serviceUUID: String? = nil,notifyUUID:String? = nil, completionHandler: BQNotifyCharacteristicCompletionHandler?) {
        let nofifyPeripheral = validPeripheral(peripheral)
        guard nofifyPeripheral != nil else{
            //抛出异常 无可用设备
            completionHandler?(peripheral, nil, .failure(.notConnectPeripheral))
            return
        }

        assert(notifyUUID != nil || BQBluetooth.configuration.characteristicNotifyUUID != nil , "characteristicWriteUUID Could not be nil")
        // 订阅设备
        nofifyPeripheral?.notify(serviceUUID: serviceUUID, notifyUUID: notifyUUID, completionHandler: completionHandler)
    }
    
    
}



