//
//  LGDeviceTableViewController.h
//  CFMusicLight
//
//  Created by 金港 on 16/7/26.
//
//

#import <UIKit/UIKit.h>


@interface LGDeviceTableViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *Device_list;
@property (weak, nonatomic) IBOutlet UIImageView *ImageBG;
- (IBAction)Btn:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_Image_Bg;
@property(nonatomic, retain)  NSMutableArray * bleDevices;
//暂时注释掉
//@property (nonatomic,retain)NSMutableArray *deviceName;

-(void)disconnectWithBlueTooth;
-(void)SearchTime :(NSTimer *)timer;
//

//同步系统时间到板子方法
-(void)SynchronizationTime:(NSData*)valueDate;

//发送时间同步到板子
//-(void)SenderSystemTime :(NSTimer *)timer;

//设备定时器同步手机时间到板子
//-(void)setAlarmtype:(NSInteger)type  Switch:(NSInteger)switcherValue powerOn:(NSInteger)powerOn HourStart:(NSInteger)hourStart  minStart:(NSInteger)minStart;


@property (nonatomic,weak) NSTimer *Systemtimer;//定时同步系统时间到板子




@end
