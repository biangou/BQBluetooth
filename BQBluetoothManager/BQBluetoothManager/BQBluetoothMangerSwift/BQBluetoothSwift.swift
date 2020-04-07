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
    private var centralManager: CBCentralManager!
    
    //扫描到的设备的集合
    var scanDevices = [CBPeripheral]()
    //已经连接的设备的集合
    var connectedPeripherals = [BQPeripheral]()
    
    var scanTime: Int? = 0
    
    //等待连接的设备列表
    private var waitConnectPeripheralNamesArray = [String]()
    
    //MARK: - initialize
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)

    }
    
    init(queue:DispatchQueue = .main,options:[String:Any]? = nil) {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: queue,options: options)
    }
    
    
    //MARK: - 使用代理方法回调时调用
    
    ///判断一个设备是否已经蓝牙连接并可以操作
    open func isPeripheralReady(_ peripheralName: String) -> Bool {
        for blemodel in  BQBluetooth.connectedPeripherals {
            if blemodel.peripheralName == peripheralName && blemodel.isRady == true{
                return true
            }
        }
        return false
    }
    
    
    //MARK: - 蓝牙操作
    
    /// 蓝牙开始扫描周围外设
    func scan(time:Int? = nil) {
        //蓝牙处于不可用状态则展示弹窗
        guard centralManagerState == .poweredOn else {
            showAlert()
            self.scanTime = time
            return
        }
        //如果当前处于扫描状态,则停止扫描
        if centralManager.isScanning == true  {
            BQBluetooth.stopScan()
        }
        
        
        //删除之前扫描到的所有设备
        scanDevices.removeAll()
        //开始扫描
        BQPrint("开始扫描")
        if let serverUUID = serverUUID {
            centralManager?.scanForPeripherals(withServices: [CBUUID.init(string:serverUUID)], options: nil)
        }else{
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        //断开扫描 time 为空时默认不会自动停止，需手动停止
        guard let time = time else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + .seconds(time),execute:{
            self.stopScan()
            
        })
    }
    
    /// 蓝牙停止扫描周围外设
    func stopScan() {
        guard centralManager.isScanning == true else {
            return
        }
        centralManager.stopScan()
        BQPrint("停止扫描")
    }
    
    /// 添加一个蓝牙外设
    /// - Parameter peripheral: 蓝牙外设
    func addPeripheral(peripheral:BQPeripheral) {
        //如果连接设备中已经有该设备则不做处理
        guard !connectedPeripherals.contains(peripheral) else {
            return
        }
        connectedPeripherals.append(peripheral)
    }
    
    /// 删除一个蓝牙外设
    /// - Parameter peripheral: 蓝牙外设
    func removePeripheral(peripheral:BQPeripheral) {
        for (index,item) in connectedPeripherals.enumerated() {
            if item.peripheralName == peripheral.peripheralName {
                connectedPeripherals.remove(at: index)
            }
        }
    }
    
    /// 根据蓝牙外设名称返回一个蓝牙外设
    /// - Parameter periPheralName: 蓝牙外设名字
    func periphralByName(periPheralName:String) -> BQPeripheral? {
        for peripheral in connectedPeripherals{
            if peripheral.peripheralName == periPheralName {
                return peripheral
            }
        }
        return nil
    }
    
    /// 返回当前连接的所有蓝牙外设
    func findConnectedPeriphrals() -> [BQPeripheral] {
        return connectedPeripherals
    }
    
    //MARK: - Rssi 读取蓝牙外设rssi
    
    //MARK: - 蓝牙连接，断开，重连等操作
    /// 蓝牙连接操作
    /// - Parameter peripheral: 蓝牙外设
    func connect(BQPeripheral:BQPeripheral? = nil) {
        guard let _ = BQPeripheral else {
            //抛出异常
            return
        }
        centralManager.connect(BQPeripheral!.peripheral!, options: nil)
    }
    
    /// 蓝牙连接操作
    /// - Parameter peripheral: 蓝牙外设
    func connect(peripheral:CBPeripheral?) {
        guard let _ = peripheral  else {
            //抛出异常
            return
        }
        centralManager.connect(peripheral!, options: nil)
    }
    
    /// 根据设备名称连接设备 推荐使用
    /// - Parameter peripheralName: 蓝牙外设名称
    func autoConnect(peripheralName:String){
        //开始扫描
        scan(time: 10)
        waitConnectPeripheralNamesArray.append(peripheralName)
    }
    
    /// 断开蓝牙外设
    /// - Parameter peripheral: 需要断开的蓝牙外设
    func disConnect(peripheral:CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
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
        
        //向给定设备写入数据，如果没有则向已连接设备的第一个设备写入数据
        let sendPeripheral:BQPeripheral
        if let peripheral = peripheral {
            sendPeripheral = peripheral
        }else {
            if connectedPeripherals.count != 0 {
                sendPeripheral = connectedPeripherals.first!
            }else {
                return
            }
        }
        
        //如果该设备不处于就绪状态则直接返回 ，通常见于连接成功但还没有订阅完成或订阅失败
        guard sendPeripheral.isRady == true else{
            return
        }

        assert(writeUUID == nil || BQBluetooth.characteristicWriteUUID == nil , "characteristicWriteUUID Could not be nil")
        //向设备写入数据
        sendPeripheral.send(data: data,serviceUUID: serviceUUID,writeUUID: writeUUID, type: type)
    }
    
    
}



extension BQBluetoothManager: CBCentralManagerDelegate{
    
    //手机设备蓝牙状态变化
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if centralManagerState != central.state  {
        }

        centralManagerState = central.state
        
        guard centralManagerState != .unsupported  else {
            //alert 当前设备不支持
            return
        }
        
        switch central.state {
        case .poweredOn:
            print("可用")

            if  self.scanTime != 0 {
                scan(time: self.scanTime)
            }
        case .resetting:
            print("重置中")
        case .unsupported:
            print("不支持")
        case .unauthorized:
            print("未验证")
        case .poweredOff:
            print("未启动")
        case .unknown:
            print("未知的")
        default:break
        }
    }
    
    //发现符合要求的蓝牙外设
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        BQPrint(peripheral.name ?? "没有名字")
        //加入已经发现的设备列表
        if(!scanDevices.contains(peripheral)) {
            scanDevices.append(peripheral)
            for delegate in channels.delegateArray{
                delegate.bluetoothNewPeripheral?(peripheral: peripheral, RSSI: RSSI, localName: advertisementData["kCBAdvDataLocalName"] as! String)
            }
        }
        //如果扫描到的设备有当前待连接设备，则开始连接
        if  waitConnectPeripheralNamesArray.contains(peripheral.name ?? "") {
            connect(peripheral: peripheral)
            waitConnectPeripheralNamesArray.remove(at: waitConnectPeripheralNamesArray.firstIndex(of: peripheral.name!)!)
        }
    }
    
    //连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        BQPrint("\(peripheral.name ?? "暂无名字") 连接成功")
        //停止扫描
        stopScan()
        addPeripheral(peripheral: BQPeripheral(peripheral: peripheral))
        //继续发现服务
        //如果只需要扫描某种 serverUUID的蓝牙外设
        if let serverUUID = serverUUID {
            peripheral.discoverServices([CBUUID(string:serverUUID)])
        }else{
            //扫描所有蓝牙外设
            peripheral.discoverServices(nil)
        }
        
        for delegate in channels.delegateArray{
            delegate.bluetoothPeripheralStateChange?(peripheral: peripheral, state: .connnetSuccesed)
        }
    }
    
    //连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        BQPrint("\(peripheral.name ?? "暂无名字") 连接失败")
        for delegate in channels.delegateArray{
            delegate.bluetoothPeripheralStateChange?(peripheral: peripheral, state: .connnetFaild)
        }
    }
    
    //断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        BQPrint("\(peripheral.name ?? "暂无名字") 断开连接")
        removePeripheral(peripheral: BQPeripheral(peripheral: peripheral))
        //继续发现服务
        for delegate in channels.delegateArray{
            delegate.bluetoothPeripheralStateChange?(peripheral: peripheral, state: .disConnnet)
        }
    }
}
