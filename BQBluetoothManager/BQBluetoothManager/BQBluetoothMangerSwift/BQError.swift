//
//  BQError.swift
//  BQBluetoothManager
//
//  Created by 边齐 on 2020/5/8.
//  Copyright © 2020 bubblelab. All rights reserved.
//

import Foundation
public enum BQError: Error {

    //MARK: - 蓝牙权限 异常
    //没有蓝牙权限
    case failedScanUnauthorized
    
    //蓝牙没有启动
    case failedScanPoweredOff
    
    //iPhone(iPad,iWatch,Mac)不支持蓝牙
    case failedScanUnsupported
    
    
    //MARK: - 扫描 异常
    //扫描设备超时
    case failedScanTimeout
    
    
    //MARK: - 连接 异常
    // 不符合外设筛选条件
    case failedConnectFailedFilter
    
    // 系统返回的连接失败error
    case failedConnect(Error?)

    
    //连接设备超时 适当调整connect时间或确定信号强度
    case failedConnectTimeout
    
    //设备未连接
    case notConnectPeripheral
    
    //特征值无效
    case invalidCharacteristic
}
