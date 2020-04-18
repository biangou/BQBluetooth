//
//  BQCenterManager.swift
//  BQBluetoothManager
//
//  Created by 边齐 on 2020/1/17.
//  Copyright © 2020 bubblelab. All rights reserved.
//

import UIKit
import CoreBluetooth

class BQCentralManager: NSObject {


    //MARK: - private
    private var centralManager: CBCentralManager!
    
    //所有等待连接的设备
    private var waitConnectPeripheralNamesArray = [String]()
    
    //当前手机蓝牙设备状态,默认为可使用状态
    private var centralManagerState:CBManagerState = .poweredOff
    
    //扫描到的设备的集合
    private var scanDevices = [BQPeripheral]()
    
    //已经连接的设备的集合
    var connectedPeripherals = [BQPeripheral]()

    
    var isWaitScan: Bool = false
    var scanTime: Int? = 0


    //MARK: - init
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    init(queue:DispatchQueue = .main,options:[String:Any]? = nil) {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: queue,options: options)
    }
    
    //MARK: 扫描，添加设备
    /// 蓝牙开始扫描周围外设
    func scan(time:Int? = nil) {
        //蓝牙处于未启动状态
        guard centralManagerState != .poweredOff else {
            self.scanTime = time
            //等待2s，2s内如启动则可继续使用
            self.isWaitScan = true
            DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 2,execute:{
                self.isWaitScan = false
            })
            return
        }
        
        //蓝牙处于不可用状态则展示弹窗
        guard centralManagerState == .poweredOn else {
            showAlert()
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
        if let serverUUID = BQBluetooth.serverUUID {
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
        BQPrint("结束 扫描")
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
    func removePeripheral(peripheral:CBPeripheral) {
        connectedPeripherals.removeAll {$0.peripheralName == peripheral.name}
    }
    
    /// 根据蓝牙外设名称返回一个蓝牙外设
    /// - Parameter periPheralName: 蓝牙外设名字
    func periphralByName(periPheralName:String) -> BQPeripheral? {
        return connectedPeripherals.first {$0.peripheralName == periPheralName}
    }
    
    ///判断一个设备是否已经蓝牙连接并可以操作
    open func isPeripheralReady(_ peripheralName: String) -> Bool {
        return connectedPeripherals.contains { $0.peripheralName == peripheralName && $0.isRady == true}
    }
    
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
    func autoConnect(peripheralName:String,scantime:Int = 5){
        //开始扫描
        scan(time: scantime)
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
        let peripheral = BQBluetooth.periphralByName(periPheralName: peripheralName)
        guard let _ = peripheral else {
            //抛出异常，该设备不存在或已经断开连接
            return
        }
        disConnect(peripheral: peripheral!.peripheral!)
    }
      
}


extension BQCentralManager: CBCentralManagerDelegate{
    
    //手机设备蓝牙状态变化
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if centralManagerState != central.state  {
            centralManagerState = central.state
        }

        switch central.state {
        case .poweredOn:
            BQPrint("可用")
            isWaitScan == true ? scan(time: self.scanTime) : nil
        case .resetting:
            BQPrint("重置中")
        case .unsupported:
            BQPrint("不支持")
        case .unauthorized:
            BQPrint("未验证")
        case .poweredOff:
            BQPrint("未启动")
        case .unknown:
            BQPrint("未知的")
        default:break
        }
        
        for delegate in BQBluetooth.channels.delegateArray{
            delegate.bluetoothCentralManagerDidUpdateState?(states: central.state)
        }
    }
    
    //发现符合要求的蓝牙外设
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        BQPrint("发现 \(peripheral.name ?? "nil name")")
        //加入已经发现的设备列表
        if(!scanDevices.contains {$0.peripheral == peripheral}){
            scanDevices.append(BQPeripheral.init(peripheral, advertisementData, RSSI))
            for delegate in BQBluetooth.channels.delegateArray{
                delegate.bluetoothNewPeripheral?(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
            }
        }
        BQBluetooth.bluetoothChannel.currentChannelCallback().blockOnNewPeripheral?(peripheral, advertisementData, RSSI)

        //如果扫描到的设备有当前待连接设备，则开始连接
        if  waitConnectPeripheralNamesArray.contains(peripheral.name ?? "") {
            connect(peripheral: peripheral)
            waitConnectPeripheralNamesArray.removeAll { $0 == peripheral.name!}
        }
    }
    
    //连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        BQPrint("\(peripheral.name ?? "nil name") 连接成功")
        //停止扫描
        stopScan()
        addPeripheral(peripheral: scanDevices.first {$0.peripheral == peripheral}!)
        //继续发现服务
        //如果只需要扫描某种 serverUUID的蓝牙外设
        if let serverUUID = BQBluetooth.serverUUID {
            peripheral.discoverServices([CBUUID(string:serverUUID)])
        }else{
            //扫描所有蓝牙外设
            peripheral.discoverServices(nil)
        }
        
        for delegate in BQBluetooth.channels.delegateArray{
            delegate.bluetoothPeripheralStateChange?(peripheral: peripheral, state: .connnetSuccesed)
        }

        BQBluetooth.bluetoothChannel.currentChannelCallback().blockOnPeripheralStateChange?(peripheral, .connnetSuccesed)
    }
    
    //连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        BQPrint("\(peripheral.name ?? "nil name") 连接失败")
        for delegate in BQBluetooth.channels.delegateArray{
            delegate.bluetoothPeripheralStateChange?(peripheral: peripheral, state: .connnetFaild)
        }
        BQBluetooth.bluetoothChannel.currentChannelCallback().blockOnPeripheralStateChange?(peripheral, .connnetFaild)

    }
    
    //断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        BQPrint("\(peripheral.name ?? "nil name ") 断开连接")
        removePeripheral(peripheral:peripheral)
        //继续发现服务
        for delegate in BQBluetooth.channels.delegateArray{
            delegate.bluetoothPeripheralStateChange?(peripheral: peripheral, state: .disConnnet)
        }
        BQBluetooth.bluetoothChannel.currentChannelCallback().blockOnPeripheralStateChange?(peripheral, .disConnnet)

    }
}
