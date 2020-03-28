# BQBluetooth
swift写的蓝牙工具类
#### 可以实现针对蓝牙外设的扫描，连接，收发命令和自动重连等功能
e.g
#### 添加代理
```
BQBluetooth.addDelegate(delegate: self)
```
#### 开始连接
```
BQBluetooth.autoConnect(peripheralName: "Your peripheral name")
```
