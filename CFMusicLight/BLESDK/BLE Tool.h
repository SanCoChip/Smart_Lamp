//
//  BLE Tool.h
//
//  Created by user on 15/11/13.
//  Copyright © 2015年 user. All rights reserved.
//

//本工具基于iOS核心蓝牙框架封装，使用单例对象和centralManager对蓝牙外设进行操作与管理，回调方法执行后使用通知中心传递消息，回调参数存在note.userinfo该变量中

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "LGDeviceTableViewController.h"

/**
 *  蓝牙状态更新通知
 */
extern NSString *const BLEUpdateStateNotification;

/**
 *  蓝牙通知设置回调
 */
extern NSString *const BLEUpdateNotificationStateNotification;
/**
 *  搜索到外设通知
 */
extern NSString *const BLESearchPeripheralNotification;
/**
 *  连接到外设通知
 */
extern NSString *const BLEConnectPeripheralNotification;
/**
 *  外设连接失败通知
 */
extern NSString *const BLEConnectFailPeripheralNotification;
/**
 *  断开外设通知
 */
extern NSString *const BLEDisconnectPeripheralNotification;
/**
 *  搜索到服务通知
 */
extern NSString *const BLEDiscoverServiceNotification;
/**
 *  搜索到特征通知
 */
extern NSString *const BLEDiscoverCharacteristicNotification;
/**
 *  读取到特征值通知
 */
extern NSString *const BLEReadCharacteristicValueNotification;
/**
 *  写入特征值通知
 */
extern NSString *const BLEWriteCharacteristicValueNotification;

/**
 *  搜索到描述通知
 */
extern NSString *const BLEDiscoverDescriptorNotification;
/**
 *  读取到描述值通知
 */
extern NSString *const BLEReadDescriptorValueNotification;

/**
 *  读取RSSI值通知 该方法仅支持iOS 9.0及以上
 */
extern NSString *const BLEReadRSSIValueNotification;

//BLE电源关闭状态通知
extern NSString *const BLEStatePowerOffNotification;

//正在连接蓝牙设备
extern NSString *const BLEIsConnectingNotification;



@interface BLE_Tool : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate,UIAlertViewDelegate>
/**
 *  CBCentralManager管理对象
 */
@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic,strong) NSData * charactorValue;

extern  BOOL isFirstInto;

/**
 *  BLE TOOl单例对象
 *
 *  @return BLE_Tool
 */
+(BLE_Tool *)sharedTool;



/**
 *  开始搜索外设
 *
 *  @param services 条件数组
 *  @param option   指定选项
 *  @param block    搜索完成回调Block
 */
-(void)startDiscoverWithServices:(NSArray <CBUUID *> *)services andOptions:(NSDictionary <NSString *,id>*)option;


/**
 *  连接目标外设
 *
 *  @param peripheral 目标外设
 *  @param options    连接设置
 *  @param block      连接后回调Block
 */
-(void)connectPeripheral:(CBPeripheral *)peripheral andOptions:(NSDictionary <NSString *,id>*)options;
/**
 *  搜索目标外设服务
 *
 *  @param peripheral 目标外设
 *  @param array      筛选条件
 *  @param block      搜索服务回调block
 */
-(void)discoverServicesWithPeripheral:(CBPeripheral *)peripheral andArray:(NSArray <CBUUID *>*)array;
/**
 *  搜索外设服务特征
 *
 *  @param peripheral 目标外设
 *  @param array      条件数组
 *  @param service    目标服务
 *  @param block      搜索回调block
 */
-(void)discoverCharacteristicsWithPeripheral:(CBPeripheral *)peripheral andConditionalArray:(NSArray <CBUUID *>*)array andService:(CBService *)service;
/**
 *  搜索目标特征描述
 *
 *  @param peripheral     外设
 *  @param characteristic 特征
 *  @param block          搜索回调block
 */
-(void)discoverDescriptorsWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic;
/**
 *  读取目标特征描述值
 *
 *  @param peripheral 外设
 *  @param descriptor 描述
 *  @param block      读取回调block
 */
-(void)readDescriptorValueWithPeripheral:(CBPeripheral *)peripheral andDescriptor:(CBDescriptor *)descriptor;


/**
 *  读取目标特征值
 *
 *  @param peripheral     目标外设
 *  @param characteristic 目标特征
 *  @param block          读取回调block
 */
-(void)readValueWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic;
/**
 *  向目标特征写入值
 *
 *  @param peripheral     目标外设
 *  @param characteristic 目标特质
 *  @param value          要写入的值
 *  @param responseWriteType 写值方式 是否有应答
 */
-(void)writeValueWithCharacteristic:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic andValue:(NSData *)value andResponseWriteType:(CBCharacteristicWriteType)responseWriteType;




/**
 *  订阅通知
 *
 *  @param peripheral     要订阅通知的外设
 *  @param characteristic 要订阅的特征
 */
-(void)notifyCharacteristicWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  取消订阅的通知
 *
 *  @param peripheral     订阅的外设
 *  @param characteristic 要取消订阅的外设特征
 */
-(void)cancelNotifyCharacteristicWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic;

/**
 *  停止搜索
 */
-(void)stopDiscover;

/**
 *  断开连接
 *
 *  @param peripheral 要断开的外设
 */
-(void)disconnectWithPeripheral:(CBPeripheral *)peripheral;


-(void)setfirstinto:(BOOL)first;



-(NSData *)getValue;


@end
