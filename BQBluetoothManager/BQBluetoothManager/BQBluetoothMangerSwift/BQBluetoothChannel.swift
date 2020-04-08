//
//  BQBluetoothChannel.swift
//  BQBluetoothManager
//
//  Created by 边齐 on 2020/4/3.
//  Copyright © 2020 bubblelab. All rights reserved.
//  通过Channel 区分 delegate 和 block


import Foundation

class BQBluetoothChannel: NSObject {
    //所有频道tag
    var channelArray: [String] = []
    var currentChannel: String = "defaultChannel"
    //监听的delegate列表
    var delegateArray: [BLEDelegate] = []
    //已经实现的 Blcok 列表 key为频道tag
    var blockArray: [String: BQBlock] = ["default":BQBlock()]
    
    //MARK: - initialize
    override init() {
        super.init()
    }
       
    //MARK: - 代理相关
    
    /// 添加监听接口，如果之前有就覆盖
    /// - Parameter delegate: 蓝牙使用回调
    func addDelegate(delegate:BLEDelegate) {
        //判断当前是否已经实现过该代理
        let isContain = delegateArray.contains {$0.tag() == delegate.tag()}
        guard isContain == false else {
            return
        }
        delegateArray.append(delegate)
    }
       
    /// 清空所有代理
    func clearDelegate() {
        delegateArray.removeAll()
    }
       
    /// 根据Tag删除指定的代理
    /// - Parameter tag: 每个delegate的唯一标识
    func removeDelegateByTag(tag:String) {
        delegateArray = delegateArray.filter({$0.tag() == tag})
    }
    
    //MARK: - block相关
    
    /// 切换频道
    func switchChannel(_ channel: String) {
        //如果已经有的频道不包含切换的频道 直接返回默认频道
        guard channelArray.contains(channel) else{
            currentChannel = "default"
            return
        }
        
        currentChannel = channel
    }
    
    func currentChannelCallback(_ channel: String? = nil) -> BQBlock{
        
        return BQBlock()
    }
    
}



