//
//  BLE Tool.m
//  Test
//
//  Created by user on 15/11/13.
//  Copyright © 2015年 user. All rights reserved.
//



#import "BLE Tool.h"
#import "LGDeviceTableViewController.h"
#import "LGAlarmViewController.h"
LGDeviceTableViewController *disconnect;
NSString *const BLEUpdateStateNotification=@"BLEUpdateStateNotification";

NSString *const BLEUpdateNotificationStateNotification=@"BLEUpdateNotificationStateNotification";

NSString *const BLESearchPeripheralNotification=@"BLESearchPeripheralNotification";
NSString *const BLEConnectPeripheralNotification=@"BLEConnectPeripheralNotification";
NSString *const BLEConnectFailPeripheralNotification=@"BLEConnectFailPeripheralNotification";
NSString *const BLEDisconnectPeripheralNotification=@"BLEDisconnectPeripheralNotification";
NSString *const BLEDiscoverServiceNotification=@"BLEDiscoverServiceNotification";
NSString *const BLEDiscoverCharacteristicNotification=@"BLEDiscoverCharacteristicNotification";
NSString *const BLEReadCharacteristicValueNotification=@"BLEReadCharacteristicValueNotification";
NSString *const BLEDiscoverDescriptorNotification=@"BLEDiscoverDescriptorNotification";
NSString *const BLEReadDescriptorValueNotification=@"BLEReadDescriptorValueNotification";
NSString *const BLEWriteCharacteristicValueNotification=@"BLEWriteCharacteristicValueNotification";
NSString *const BLEReadRSSIValueNotification=@"BLEReadRSSIValueNotification";
NSString *const BLEStatePowerOffNotification=@"BLEStatePowerOffNotification";


NSString *const BLEIsConnectingNotification=@"BLEIsConnectingNotification";
BOOL isFirstInto=FALSE;



@implementation BLE_Tool

#pragma mark - 初始化对象
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.centralManager=[[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        
    }
    return self;
}



#pragma mark - 蓝牙工具对象单例
+(BLE_Tool *)sharedTool
{
    static BLE_Tool *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[BLE_Tool alloc] init];
    });
    return instance;
}


#pragma mark - 检测蓝牙状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    NSDictionary *dict=@{@"central": central};
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEUpdateStateNotification object:nil userInfo:dict];
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
        
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            break;
        default:
            break;
    }
}


#pragma mark - 开始搜索
-(void)startDiscoverWithServices:(NSArray *)services andOptions:(NSDictionary *)option
{
    
    NSLog(@"start scan peripheral");
    [self.centralManager scanForPeripheralsWithServices:services options:option];
    
    
}

#pragma mark - 扫描到外设
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{

    
    NSString *localName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
    if (localName!=nil) {
        NSDictionary *dict=@{@"central": central,@"peripheral": peripheral,@"advertisementData": advertisementData,@"RSSI": RSSI,@"localName":localName};
        /**
         *  发送通知
         */
        [[NSNotificationCenter defaultCenter] postNotificationName:BLESearchPeripheralNotification object:nil userInfo:dict];
        
        NSLog(@"Discover Peripheral %@-----%@------%@",peripheral.name,advertisementData,RSSI);
        
    }
    
    
    
    
    
    
    
    
    
//    if (peripheral.name!=nil) {
//        NSDictionary *dict=@{@"central": central,@"peripheral": peripheral,@"advertisementData": advertisementData,@"RSSI": RSSI,};
//        /**
//         *  发送通知
//         */
//        [[NSNotificationCenter defaultCenter] postNotificationName:BLESearchPeripheralNotification object:nil userInfo:dict];
//        NSLog(@"Discover Peripheral %@-----%@------%@",peripheral.name,advertisementData,RSSI);
//        
//    }
    
}

-(void)setfirstinto:(BOOL)first{
    
    isFirstInto =first;
    
    
}
#pragma mark - 连接目标外设
-(void)connectPeripheral:(CBPeripheral *)peripheral andOptions:(NSDictionary <NSString *,id>*)options
{
    
    [[BLE_Tool sharedTool].centralManager connectPeripheral:peripheral options:options];
    
    
    [self.centralManager stopScan];
    NSLog(@"start connect periperal");
    
    
    
    
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEIsConnectingNotification object:peripheral userInfo:nil];
    
}








#pragma mark - 成功连接外设
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connect Succed %@",peripheral.name);
    
    NSDictionary *dict=@{@"central": central,@"peripheral": peripheral};
    
    /**
     *  设置外设代理
     */
    [peripheral setDelegate:self];
    
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEConnectPeripheralNotification object:nil userInfo:dict];
    
    //存
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:peripheral.identifier.UUIDString forKey:@"ConnectedBLEDevice"];
    
    
    
    
}


#pragma mark - 连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Connect Fail %@ Error: %@",peripheral.name,error);
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:@{@"central": central,@"peripheral": peripheral}];
    
    if (error) {
        [dict setObject:error forKey:error];
    }
    
    
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEConnectFailPeripheralNotification object:nil userInfo:dict];
    
    
}



#pragma mark - 外设断开连接
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Disconnect %@  Error :%@",peripheral.name,error);
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:@{@"central": central,@"peripheral": peripheral}];
    
    if (error) {
        [dict setObject:error forKey:error];
    }
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEDisconnectPeripheralNotification object:nil userInfo:dict];
    
    
    
}


#pragma mark - 搜索外设服务
-(void)discoverServicesWithPeripheral:(CBPeripheral *)peripheral andArray:(NSArray <CBUUID *>*)array
{
    
    NSLog(@"start discover service");
    [peripheral discoverServices:array];
    
}

#pragma mark - 搜索到外设服务
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    NSLog(@"Discover %@  Services %@",peripheral.name,peripheral.services);
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:@{@"peripheral": peripheral}];
    
    if (error) {
        [dict setObject:error forKey:error];
        NSLog(@"Discover Services %@ Error : %@",peripheral.name,error);
    }
    
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEDiscoverServiceNotification object:nil userInfo:dict];
    
    
}

#pragma mark - 搜索外设服务特征
-(void)discoverCharacteristicsWithPeripheral:(CBPeripheral *)peripheral andConditionalArray:(NSArray <CBUUID *>*)array andService:(CBService *)service
{
    
    NSLog(@"start search peripheral characteristics");
    [peripheral discoverCharacteristics:array forService:service];
    
}


#pragma mark - 搜索到服务特征
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:@{@"service": service,@"peripheral": peripheral}];
    
    if (error) {
        [dict setObject:error forKey:error];
        NSLog(@"Discover Character Error :%@",error);
    }
    
    
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEDiscoverCharacteristicNotification object:nil userInfo:dict];
    
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        NSLog(@"Service UUID :%@-----Characteristic UUID :%@------Property:%lu",service.UUID,characteristic.UUID,(unsigned long)characteristic.properties);
    }
    
}

#pragma mark - 读取目标特征值
-(void)readValueWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"read characteristic value");
    [peripheral readValueForCharacteristic:characteristic];
}

#pragma mark - 读取到特征值以及获取到通知
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:@{@"characteristic": characteristic,@"peripheral": peripheral}];
    
    if (error) {
        [dict setObject:error forKey:error];
        NSLog(@"UpdateValue Error :%@",error);
    }
    
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEReadCharacteristicValueNotification object:nil userInfo:dict];
    
    NSString *notificationName = [NSString stringWithFormat:@"value.%@.%@",characteristic.service.UUID.UUIDString,characteristic.UUID.UUIDString];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dict];
    
    NSLog(@"获取数据！！！！！！！！！！！！！！！！Characteristic UUID :%@ ----Value:%@",characteristic.UUID,characteristic.value);
    NSString *str= [NSString stringWithFormat:@"%@",characteristic.value];
    
    NSLog(@"打印数据!!!!!!!!!!!!!!!!%@",str);
    //    [str dataUsingEncoding:NSASCIIStringEncoding];
    
    
    ////    NSData *data = [str dataUsingEncoding:NSASCIIStringEncoding];
    //    NSLog(@"1111Value:%@",str);
    
    
    
    self.charactorValue = characteristic.value;
    
}



#pragma mark - 搜索目标特征描述
-(void)discoverDescriptorsWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic
{
    
    NSLog(@"discover Descriptors");
    [peripheral discoverDescriptorsForCharacteristic:characteristic];
}

#pragma mark - 搜索到特征描述
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:@{@"characteristic": characteristic,@"peripheral": peripheral}];
    
    if (error) {
        [dict setObject:error forKey:error];
        NSLog(@"Characteristic UUID: %@----Discover Descriptors Error :%@",characteristic.UUID,error);
    }
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEDiscoverDescriptorNotification object:nil userInfo:dict];
    
    
}



#pragma mark - 读取目标特征描述
-(void)readDescriptorValueWithPeripheral:(CBPeripheral *)peripheral andDescriptor:(CBDescriptor *)descriptor
{
    NSLog(@"read descriptor");
    [peripheral readValueForDescriptor:descriptor];
}


#pragma mark - 读取到外设特征描述值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:@{@"descriptor": descriptor,@"peripheral": peripheral}];
    
    if (error) {
        [dict setObject:error forKey:error];
        NSLog(@"Descriptor UpdateValue Error:%@",error);
    }
    
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEReadDescriptorValueNotification object:nil userInfo:dict];
    
    
    NSLog(@"Characteristic UUID:%@--------Descriptor UUID :%@ ---- Value :%@",descriptor.characteristic.UUID,descriptor.UUID,[[NSString alloc] initWithData:descriptor.value encoding:NSUTF8StringEncoding]);
    
}

#pragma mark - 向指定特征写入数据
-(void)writeValueWithCharacteristic:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic andValue:(NSData *)value andResponseWriteType:(CBCharacteristicWriteType)responseWriteType
{
    
    NSLog(@"Charateristic properties %lu",(unsigned long)characteristic.properties);
    
    
    [peripheral writeValue:value forCharacteristic:characteristic type:responseWriteType];
    
}




#pragma mark - 特征值写入数据回调
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    
    NSLog(@"write value complete characteristic :%@",characteristic);
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:@{@"characteristic": characteristic,@"peripheral": peripheral}];
    
    if (error) {
        [dict setObject:error forKey:error];
        NSLog(@"Charateristic UUID:%@ -------write Value Error:%@",characteristic.UUID,error);
    }
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEWriteCharacteristicValueNotification object:nil userInfo:dict];
    
}



#pragma mark - 设置通知
-(void)notifyCharacteristicWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic
{
    if (characteristic.properties & CBCharacteristicPropertyNotify) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        NSLog(@"Notify Characteristic succesd");
    }
}

#pragma mark - 更新通知状态
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    NSDictionary *tempdict=@{@"peripheral": peripheral,@"characteristic":characteristic};
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:tempdict];
    
    if (error) {
        [dict setObject:error forKey:@"error"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEUpdateNotificationStateNotification object:nil userInfo:dict];
    
    
    NSLog(@"Notification state characteristic %@",characteristic);
}


#pragma mark - 取消通知
-(void)cancelNotifyCharacteristicWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic
{
    if (characteristic.properties & CBCharacteristicPropertyNotify) {
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
    }
}


#pragma mark - 停止搜索
-(void)stopDiscover
{
    NSLog(@"Stop scan peripheral");
    
    [self.centralManager stopScan];
}

#pragma mark - 断开连接
-(void)disconnectWithPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral is disconnect");
    if (peripheral==nil) {
        return;
    }
    [self.centralManager cancelPeripheralConnection:peripheral];
}



#pragma mark - 读取RSSI回调
-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:@{@"RSSI": RSSI,@"peripheral": peripheral}];
    
    if (error) {
        [dict setObject:error forKey:error];
        NSLog(@"UpdateValue Error :%@",error);
    }
    
    /**
     *  发送通知
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:BLEReadRSSIValueNotification object:nil userInfo:dict];
}



#pragma mark -  获取特征值
-(NSData *)getValue
{
    return self.charactorValue;

}
@end
