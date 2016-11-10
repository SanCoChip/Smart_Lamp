//
//  LGAlarmViewController.h
//  CFMusicLight
//
//  Created by 金港 on 16/5/10.
//  Copyright © 2016年 cfans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGFMBaseViewController.h"
@interface LGAlarmViewController : LGFMBaseViewController
- (IBAction)AutoLight_SW:(UISwitch *)sender;
- (IBAction)Autoplay_SW:(UISwitch *)sender;
- (IBAction)Timeo_SW:(UISwitch *)sender;

- (IBAction)TimeT_SW:(UISwitch *)sender;

-(void)adjustbyte:(NSData *)valueData;
//fen设置闹钟等 封装方法
-(void)setAlarmClockTimeWithType:(NSInteger)type Switch:(NSInteger)switchValue PowerOn:(NSInteger)powerOn OpenHour:(NSInteger)openHour OpenMin:(NSInteger)openMin CloseHour:(NSInteger)closeHour CloseMin :(NSInteger)closeMin;

@property (weak, nonatomic) IBOutlet UISwitch *BT_Switch;//闹钟1开关
@property (weak, nonatomic) IBOutlet UISwitch *BT_Switch2;//闹钟二
@property (weak, nonatomic) IBOutlet UISwitch *sw_AutomaticPlay;//自动播放属性开关
@property (weak, nonatomic) IBOutlet UISwitch *sw_AutomaticLamp;//自动灯光开关属性


@end
