//
//  BaseViewController.m
//  DrawerControllerDemo
//
//  Created by cfans on 4/29/16.
//  Copyright © 2016 cfans. All rights reserved.
//

#import "BaseViewController.h"
#import "MMDrawerBarButtonItem.h"

@interface BaseViewController ()<UIAlertViewDelegate>

@end

@implementation BaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _bleManager = [JRBLESDK getSDKToolInstance];
//    [self initTopMenuButton];
//    [self initImageBLE];
//    self.navigationItem.title = @"Title Device";

}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self addBLEObserver];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



-(void)initTopMenuButton{
    MMDrawerBarButtonItem * leftButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftButtonPress:)];
    
//    [leftButton setImage:[UIImage imageNamed:@"search"]];
    leftButton .tintColor =[UIColor greenColor];
    [self.navigationItem setLeftBarButtonItem:leftButton animated:YES];
    
//    MMDrawerBarButtonItem * rightButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(rightButtonPress:)];
//    [rightButton setImage:[UIImage imageNamed:@"volume"]];
//    [self.navigationItem setRightBarButtonItem:rightButton animated:YES];
}

//-(void)initImageBLE{
//    CGRect rect = CGRectMake(10, 88, 80, 80);
//    _imageBLE = [[UIButton alloc]initWithFrame:rect];
//    [_imageBLE setImage:[UIImage imageNamed:@"ble_nor"] forState:UIControlStateNormal];
//    [_imageBLE addTarget:self action:@selector(onConfigureAlert) forControlEvents:(UIControlEventTouchUpInside)];
//    _imageBLE.enabled = NO;
//    [self.view addSubview:_imageBLE];
//}



#pragma Alert

-(void)onConfigureAlert {
    
    NSString * message =  NSLocalizedString(@"Whether to disconnnect the curent Bluetooth connection", nil);
    NSString * strOK =  NSLocalizedString(@"Yes", nil);
    NSString * strCancel =  NSLocalizedString(@"Cancel", nil);

    
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
    {
        UIAlertController  * alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * sure = [UIAlertAction actionWithTitle:strOK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self doBLEDisconnect];
        }];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:strCancel style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:sure];
        [alertController addAction:cancel];

        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:strOK
                                              otherButtonTitles:strCancel, nil];
        [alert show];
    }
}

-(void)doBLEDisconnect{
    [_bleManager.bleTool disconnectWithPeripheral:_bleManager.peripheral];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self doBLEDisconnect];
    }
}



#pragma mark - Button Handlers
-(void)leftButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES
                                    completion:nil];


}
//右面侧滑
-(void)rightButtonPress:(id)sender{
    
    
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
    NSString * imageName = nil;
    if (peripheral.state == CBPeripheralStateConnected) {
        
        
        imageName = @"ble_sel";
        _imageBLE.enabled = YES;
    }else{
        
        
        imageName = @"ble_nor";
        
        _imageBLE.enabled = NO;
    }
    [_imageBLE setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

    NSLog(@"%s\n %@",__FUNCTION__,dict);
    
}


@end
