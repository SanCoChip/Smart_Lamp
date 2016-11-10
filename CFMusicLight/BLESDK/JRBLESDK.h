//
//  JRBLESDK.h
//  CFMusicLight
//
//  Created by cfans on 5/5/16.
//  Copyright © 2016 cfans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLE Tool.h"

extern  NSString * const kBLEServiceUUIDString;
extern  NSString * const kBLECTRL_UUIDString;
extern  NSString * const kBLEACK_UUIDString;
extern  NSString * const kLEDCTRL_UUIDString;
extern  NSString * const kVOLUME_UUIDString;
extern  NSString * const kFM_UUIDString;
extern  NSString * const KBLESD_UUIDString;
extern  NSString * const KBLMUSIC_UUIDString;
extern  NSString * const KBLEALARM_UUIDString;
extern  NSString * const KBLECHANGENAME_UUIDString;
@interface JRBLESDK : NSObject 


/**;
 *  BLE_Tool 对象
 */
@property (nonatomic,strong) BLE_Tool * bleTool;

/**
 *  当前操作的蓝牙设备
 */
@property (nonatomic,strong) CBPeripheral * peripheral;

/**
 *  当前操作的服务
 */
@property (nonatomic,strong) CBService * service;


/**
 *  当前操作的特征
 */
@property (nonatomic,strong) CBCharacteristic * ctrlCharacteristic;
@property (nonatomic,strong) CBCharacteristic * ackCharacteristic;
@property (nonatomic,strong) CBCharacteristic * ledCharacteristic;
@property (nonatomic,strong) CBCharacteristic * volumeCharacteristic;
@property (nonatomic,strong) CBCharacteristic * fmCharacteristic;
@property (nonatomic,strong) CBCharacteristic * musicCharacteristic;
@property (nonatomic,strong) CBCharacteristic * alarmCharacteristics;
@property (nonatomic,strong) CBCharacteristic * changeNameCharacteristics;

/**
 *  BLE TOOl 封装后的对象
 *
 *  @return JRBLESDK
 */
+(JRBLESDK *)getSDKToolInstance;

/**
 *  判断蓝牙设备连接成功
 *
 *  @return YES 连接成功，NO连接不成功
 */
-(BOOL)isConnected;



@end
