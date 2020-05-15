//
//  BQConfiguration.swift
//  BQBluetoothManager
//
//  Created by 边齐 on 2020/5/8.
//  Copyright © 2020 bubblelab. All rights reserved.
//

import UIKit
import CoreBluetooth

class BQConfiguration: NSObject {
    // MARK: Properties
    
    //待连接蓝牙外设的serverUUID
    var serviceUUID: CBUUID? = nil
    // 待连接蓝牙外设的写入UUID
    var characteristicWriteUUID: CBUUID? = nil
    // 待连接蓝牙外设的读取UUID 
    var characteristicNotifyUUID: CBUUID? = nil
    // 待连接蓝牙外设的写入type，默认为.withResponse
    var writeType: CBCharacteristicWriteType = CBCharacteristicWriteType.withResponse
    
    var serviceUUIDs: [CBUUID]? {
        guard let serviceUUID = serviceUUID else {
            return nil
        }
        let serviceUUIDs = [ serviceUUID ]
        return serviceUUIDs
        
    }
    
    // MARK: Initialization
    
    /*
     为方便操作serverUUID可以设为nil
     但是添加serverUUID可以在scan时完成第一步的筛选，同时如果外设中server不唯一时请务必传入serverid，否则可能监听到错误的characteristicNotifyUUID
     */
    public init(serviceUUID: String? = nil, characteristicNotifyUUID: String? = nil, characteristicWriteUUID:String? = nil, writeType: CBCharacteristicWriteType = .withResponse) {
        
        if let serviceUUID = serviceUUID {
            self.serviceUUID = CBUUID(string: serviceUUID)
        }
        
        if let characteristicNotifyUUID = characteristicNotifyUUID {
            self.characteristicNotifyUUID = CBUUID(string: characteristicNotifyUUID)
        }
        
        if let characteristicWriteUUID = characteristicWriteUUID  {
            self.characteristicWriteUUID = CBUUID(string: characteristicWriteUUID)
        }
        
        self.writeType = writeType
        
    }


}
