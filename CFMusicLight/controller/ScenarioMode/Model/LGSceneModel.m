//
//  LGSceneModel.m
//  CFMusicLight
//
//  Created by 金港 on 16/7/5.
//
//

#import "LGSceneModel.h"
#import "LGModelBsaViewController.h"

@implementation LGSceneModel

-(void)setOpen:(BOOL)isOpen andFunction:(NSInteger)function{

     _bleManager = [JRBLESDK getSDKToolInstance];
    
    
    if ([_bleManager isConnected]) {
      
        int red = 0;
        Byte byte[] = {red};
        NSData *data = [NSData dataWithBytes:byte length:1];
        [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.ledCharacteristic andValue:data andResponseWriteType:CBCharacteristicWriteWithResponse];
        
    }else{
        
        
        
        
        
    
        NSLog(@"蓝牙未连接");
    }
}
#pragma mark 警告框 消失的方法


#pragma BLE SDK Notification
-(void)addBLEObserver{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectPeripheralNotification:) name:BLEConnectPeripheralNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectPeripheralNotification:) name:BLEConnectFailPeripheralNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectPeripheralNotification:) name:BLEDisconnectPeripheralNotification object:nil];
}
- (void)connectPeripheralNotification:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    CBPeripheral * peripheral = ( CBPeripheral *)[dict objectForKey:@"peripheral"];
    //    NSString * imageName = nil;
    if (peripheral.state == CBPeripheralStateConnected) {
        
        
        
        NSLog(@"%s\n %@",__FUNCTION__,dict);
        
    }
}


@end
