//
//  BQBluetoothUtil.swift
//  BQBluetoothManager
//
//  Created by 边齐 on 2019/12/24.
//  Copyright © 2019 bubblelab. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    /// 将四个int8转为一个int32
    ///
    /// - Parameters:
    ///   - i1: 高位
    ///   - i2:
    ///   - i3:
    ///   - i4: 低位
    /// - Returns: 转换后的Int32
    public static func convertInt(i1:Int,i2:Int,i3:Int,i4:Int) ->Int32{
        var val:Int
        val = ((i1 << 24))
        val = val | (i2 << 16)
        val = val | (i3 << 8)
        val = val | i4
        return (Int32)(val)
    }
    
    /// 将四个int8转为一个int32
    ///
    /// - Parameters:
    ///   - i1: 高位
    ///   - i2:
    ///   - i3:
    ///   - i4: 低位
    /// - Returns: 转换后的Int32
     public static func convertUInt(i1:UInt8,i2:UInt8,i3:UInt8,i4:UInt8) ->UInt32{
        return UInt32(i1) << 24 | UInt32(i2) << 16 | UInt32(i3) << 18 | UInt32(i4)
     }
    
    /// 将四个int按照高低位转换为Float
    ///
    /// - Parameters:
    ///   - i1: 高位
    ///   - i2:
    ///   - i3:
    ///   - i4: 低位
    /// - Returns: 转换后的字符
    public static func convertFloat(i1:UInt8,i2:UInt8,i3:UInt8,i4:UInt8) -> Float {
        var float32value:Float32 = 0
        let data:[UInt8] = [i4,i3,i2,i1]
        memcpy(&float32value, data, 4)
        return float32value
    }
    
    /// 将两个Int8转为一个int
    ///
    /// - Parameters:
    ///   - i1: 高位
    ///   - i2: 低位
    /// - Returns:
    public static func convertUShort(i1:UInt8,i2:UInt8) -> UInt16 {
        return UInt16(i1) << 8 | UInt16(i2)

     //   return UInt16((i1  << 8) | (i2 & 0x00ff))
    }
    /// 将两个Int8转为一个int
    ///
    /// - Parameters:
    ///   - i1: 高位
    ///   - i2: 低位
    /// - Returns:
    public static func convertShort(i1:UInt8,i2:UInt8) -> Int16 {
        return Int16((i1  << 8) | (i2 & 0x00ff))
    }
    // MARK: - Constants
    
    // This is used by the byteArrayToHexString() method
    private static let CHexLookup : [Character] =
        [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ]
    private static let CHexLookupNo0 : [Character] =
        [ " ", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ]
    
    // Mark: - Public methods
    ///将一个数组转换为16进制的字符串 中间用空格分隔
    public static func byteArrayToHexString(_ byteArray : [UInt8]) -> String {
        var stringToReturn = ""
        for oneByte in byteArray {
            let asInt = Int(oneByte)
            stringToReturn.append(Utils.CHexLookup[asInt >> 4])
            stringToReturn.append(Utils.CHexLookup[asInt & 0x0f])
            stringToReturn.append(" ")
        }
        return stringToReturn
    }
    
    // Mark: - Public methods
    ///将一个数组转换为16进制的字符串 中间用 . 分隔
    ///仅用做获取版本号
    public static func byteArrayToHexStringPoint(_ byteArray : [UInt8]) -> String {
        var stringToReturn = ""
        for oneByte in byteArray {
            let asInt = Int(oneByte)
            if Utils.CHexLookup[asInt >> 4] != "0" {
                stringToReturn.append(Utils.CHexLookup[asInt >> 4])
            }
            stringToReturn.append(Utils.CHexLookup[asInt & 0x0f])
            stringToReturn.append(".")
        }
        stringToReturn.removeLast()
        return stringToReturn
    }
    
    // Mark: - Public methods
    ///将一个数组转换为16进制的字符串
    public static func byteArrayToHexStringTrim(_ byteArray : [UInt8]) -> String {
        var stringToReturn = ""
        for oneByte in byteArray {
            let asInt = Int(oneByte)
            stringToReturn.append(Utils.CHexLookup[asInt >> 4])
            stringToReturn.append(Utils.CHexLookup[asInt & 0x0f])
        }
        return stringToReturn
    }
}

//跳转到设置页面
func showAlert() {
//    let alertController = UIAlertController(title: "系统提示",message: "请前往设置打开蓝牙", preferredStyle: UIAlertController.Style.alert)
//    let cancelAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil)
//    let OKAction = UIAlertAction(title: "设置", style: .default) { (action) in
//        let bluetoothUrl = URL(string: UIApplication.openSettingsURLString)
//        if let url = bluetoothUrl,UIApplication.shared.canOpenURL(url){
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            BQPrint("进入设置页面故障")
//        }
//    }
//    alertController.addAction(cancelAction)
//    alertController.addAction(OKAction)
//    UIApplication.shared.windows[0].rootViewController?.present(alertController, animated: true, completion: nil)
}

func BQPrint(_ string:String) {
    print(string)
}


//MARK: - 常用数据转换
extension Int16 {
    func toBytes() -> Data {
        var data = Data()
        data.append((UInt8)(self >> 8 & 0x00ff))
        data.append((UInt8)(self & 0x00ff))
        return data
    }
}

extension UInt16{
    func toBytes() -> Data {
        var data = Data()
        data.append((UInt8)(self >> 8 & 0x00ff))
        data.append((UInt8)(self & 0x00ff))
        return data
    }
}

extension UInt32 {
    func toBytes() -> Data {
        var data = Data()
        data.append((UInt8)(self >> 24 & 0x00ff))
        data.append((UInt8)(self >> 16 & 0x00ff))
        data.append((UInt8)(self >> 8 & 0x00ff))
        data.append((UInt8)(self & 0x00ff))
        return data
    }
}

extension Data {
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    func toString() -> String {
        return String(format: "%@", self as CVarArg)
    }
    
    init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }
    
    func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }
    
    mutating func append(uint16value:UInt16) {
        self.append(uint16value.toBytes())
    }
    
    mutating func append(int16value:Int16) {
        self.append(int16value.toBytes())
    }
    
    mutating func append(uint32value:UInt32) {
        self.append(uint32value.toBytes())
    }
    mutating func append(float32value:Float32) {
        let data = Data(from:float32value)
        let temp:[UInt8] = data.toArray(type: UInt8.self)
        self.append(contentsOf:temp.reversed())
    }
    
    /// 从Data中读取一个UInt8数据
    ///
    /// - Returns: success 是否读取成功   uint8vale 读取到的值
    mutating func readUInt8() -> (success:Bool, uint8value:UInt8) {
        var uint8value:UInt8 = 0
        var success:Bool = false
        if(self.count < 1) {
            success = false
        }
        else {
            uint8value = self.first!
            success = true
            self.removeFirst()
        }
        return (success,uint8value)
    }
    
    mutating func subdata(in range: CountableClosedRange<Data.Index>) -> Data
    {
        return self.subdata(in: range.lowerBound..<range.upperBound + 1)
    }
    
    /// 从Data中读取一个UInt16数据
    ///
    /// - Returns: success 是否读取成功   uint16value 读取到的值
    mutating func readUInt16() -> (success:Bool, uint16value:UInt16) {
        var uint16value:UInt16 = 0
        var success:Bool = false
        if(self.count >= 2) {
            let bytes: [UInt8] = self.subdata(in: 0...1).toArray(type: UInt8.self)
            self.removeSubrange(0...1)
            let u0:UInt16 = UInt16(bytes[0])
            let u1:UInt16 = UInt16(bytes[1])
            uint16value = UInt16((u0  << 8) | (u1 & 0x00ff))
            success = true
        }
        return (success,uint16value)
    }
    
    /// 从Data中读取一个UInt32数据
    ///
    /// - Returns: success 是否读取成功   uint32value 读取到的值
    mutating func readUInt32() -> (success:Bool, uint32value:UInt32) {
        var uint32value:UInt32 = 0
        var success:Bool = false
        if(self.count >= 4) {
            let bytes: [UInt8] = self.subdata(in: 0...3).toArray(type: UInt8.self)
            self.removeSubrange(0...3)
            let u0:UInt32 = UInt32(bytes[0])
            let u1:UInt32 = UInt32(bytes[1])
            let u2:UInt32 = UInt32(bytes[2])
            let u3:UInt32 = UInt32(bytes[3])
            print("\(u0)\(u1)\(u2)\(u3)")
            uint32value = UInt32( (u0 << 24) | (u1 << 16) | (u2 << 8) | u3)
            success = true
        }
        return (success,uint32value)
    }
    
    /// 从Data中读取一个Float32数据
    ///
    /// - Returns: success 是否读取成功   float32value 读取到的值
    mutating func readFloat32() -> (success:Bool, float32value:Float32) {
        var float32value:Float32 = 0
        let success:Bool = false
        if(self.count >= 4) {
            let bytes: [UInt8] = self.subdata(in: 0...3).toArray(type: UInt8.self)
            self.removeSubrange(0...3)
            memcpy(&float32value, bytes, 4)
        }
        return (success,float32value)
    }
    
    mutating func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
    
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    
    /// 根据当前数据返回CRC校验值
    /// - Parameter start: CRC校验的数据从当前数据位开始
    /// 比如协议规定命令表头不参与校验，命令表头占两位，则start 为2
    func toCRCresult(start:Int = 2) -> [UInt8] {
        let data:[UInt8] = self.toArray(type: UInt8.self)
        var crcArr: [UInt8] = [0,0]
        
        var crc:UInt16 = 0
        for i in start ..< data.count {
            crc = update(crc0:Int(crc), b:data[i])
        }
        
        crc = update(crc0:Int(crc), b:0)
        crc = update(crc0:Int(crc), b:0)
        crcArr[1] = UInt8(crc & 0xff)
        crcArr[0] = UInt8(crc>>8 & 0xff)
        return crcArr
    }
    
    private func update(crc0:Int, b:UInt8) -> UInt16{
        var i:Int32 = Int32(UInt(b) & 0xff | 0x100);
        var crc = crc0
        repeat {
            crc <<= 1;
            i <<= 1;
            if ((i & 0x100) > 0) {
                crc = crc+1
            }
            if ((crc & 0x10000) > 0) {
                crc ^= 0x1021
            }
        } while ((i & 0x10000) <= 0);
           
        return UInt16(crc & 0xffff);
    }
}

extension String {
    func toInt() -> Int {
        let string = NSString.init(string: self)
        return Int(string.intValue)
    }
    
    func toUInt() -> UInt {
        let string = NSString.init(string: self)
        return UInt(string.intValue)
    }
    
    func toFloat() -> Float {
        let string = NSString.init(string: self)
        return Float(string.floatValue)
    }
    
    func UTF8ToGB2312(str: String) -> (NSData?, UInt) {
        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        let data = str.data(using: String.Encoding(rawValue: enc), allowLossyConversion: false)
        
        return (data! as NSData, enc)
    }
    
    //部分国内嵌入式软件String编码格式为GBK
    func toGBK2312() -> (Data?) {
        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        let data =  self.data(using: String.Encoding(rawValue: enc), allowLossyConversion: false)
        return data
    }
    
    /// 十六进制字符串转data
    ///
    /// - Returns: data
    func toData() -> Data {
        let bytes = self.toBytes()
        return Data(bytes)
    }

    // 将16进制字符串转化为 [UInt8]
    // 使用的时候直接初始化出 Data
    // Data(bytes: Array<UInt8>)
    func toBytes() -> [UInt8] {
        assert(self.count % 2 == 0, "输入字符串格式不对，8位代表一个字符")
        var bytes = [UInt8]()
        var sum = 0
        // 整形的 utf8 编码范围
        let intRange = 48...57
        // 小写 a~f 的 utf8 的编码范围
        let lowercaseRange = 97...102
        // 大写 A~F 的 utf8 的编码范围
        let uppercasedRange = 65...70
        for (index, c) in self.utf8CString.enumerated() {
            var intC = Int(c.byteSwapped)
            if intC == 0 {
                break
            } else if intRange.contains(intC) {
                intC -= 48
            } else if lowercaseRange.contains(intC) {
                intC -= 87
            } else if uppercasedRange.contains(intC) {
                intC -= 55
            } else {
                assertionFailure("输入字符串格式不对，每个字符都需要在0~9，a~f，A~F内")
            }
            sum = sum * 16 + intC
            // 每两个十六进制字母代表8位，即一个字节
            if index % 2 != 0 {
                bytes.append(UInt8(sum))
                sum = 0
            }
        }
        return bytes
    }

    
    /// 是否包含字符 无视大小写
    ///
    /// - Parameter str: 原字符
    /// - Returns: 被包含字符
    func containsNOCase(str:String) -> Bool {
        let lowSrting = self.lowercased()
        let lowStr = str.lowercased()
        return lowSrting.contains(lowStr)
    }
}
