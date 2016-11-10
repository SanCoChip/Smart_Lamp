//
//  LGModelBsaViewController.m
//  CFMusicLight
//
//  Created by 金港 on 16/7/6.
//
//

#import "LGModelBsaViewController.h"

@implementation LGModelBsaViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bleManager = [JRBLESDK getSDKToolInstance];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self addBLEObserver];
    
}

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
