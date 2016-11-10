//
//  JRBLESDK.m
//  CFMusicLight
//
//  Created by cfans on 5/5/16.
//  Copyright © 2016 cfans. All rights reserved.
//

#import "JRBLESDK.h"

NSString  * const kBLEServiceUUIDString = @"FFF0";
NSString  * const kBLECTRL_UUIDString = @"FFF1";
NSString  * const kBLEACK_UUIDString = @"FFF3";
NSString  * const kLEDCTRL_UUIDString = @"FFF4";
NSString  * const kVOLUME_UUIDString = @"FFF5";
NSString  * const kFM_UUIDString = @"FFF6";
NSString  * const KBLESD_UUIDString=@"FFF7";
NSString  * const KBLEALARM_UUIDString=@"FFF8";
NSString  * const KBLECHANGENAME_UUIDString=@"FFFA";


@implementation JRBLESDK

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bleTool=[BLE_Tool sharedTool];
    }
    return self;
}


#pragma mark - 蓝牙工具对象单例
+(JRBLESDK *)getSDKToolInstance
{
    static JRBLESDK *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[JRBLESDK alloc] init];
    });
    return instance;
}

-(BOOL)isConnected{
    return  _peripheral.state == CBPeripheralStateConnected;
}


@end
