//
//  LGAlarmViewController.m
//  CFMusicLight
//
//  Created by 金港 on 16/5/10.
//  Copyright © 2016年 cfans. All rights reserved.
//

#import "LGAlarmViewController.h"
#import "PickerBackView.h"
#import "MASUtilities.h"
#import "MASConstraintMaker.h"
#import "View+MASAdditions.h"
#import "Factory.h"
#import "BLE Tool.h"
#import "JRBLESDK.h"
#import "SVProgressHUD.h"
#import "LGSynchronizationTime.h"

NSString *const InvalidTime=@"99:99";
NSString *const LightOpenTime = @"lightopenTime";
NSString *const LightCloseTime = @"lightcloseTime";






@interface LGAlarmViewController ()

@property (nonatomic, strong) PickerBackView * backView;//背景View

@property (nonatomic, strong) UIView * pickerDateView;//pickerDate的父视图

@property (nonatomic, strong) UIDatePicker * pickerDate;//日期选择器
//@property (nonatomic, strong) UIDatePicker *picker;//日期选择器

@property (nonatomic, strong) UIButton * button;//弹出时间选择 闹钟时间
@property (nonatomic,strong)  UIButton * button1;
//自动灯光
@property (nonatomic,strong)  UIButton * Auto_Lig_Close;
@property (nonatomic,strong)  UIButton * Auto_Lig_Open;
//自动播放
@property (nonatomic,strong)  UIButton * Auto_PLay_Close;
@property (nonatomic,strong)  UIButton * Auto_PLay_Open;

@property (weak, nonatomic) IBOutlet UILabel *LightLabel;//自动灯光

@property (weak, nonatomic) IBOutlet UILabel *PlayerLable;//自动播放

@property (weak, nonatomic) IBOutlet UILabel *AlaemLabel;//闹钟

@property (weak, nonatomic) IBOutlet UILabel *OpenLable;//自动灯光的打开时间
@property (weak, nonatomic) IBOutlet UILabel *CloseLabel;//自动关闭时间

@property (weak, nonatomic) IBOutlet UILabel *Play_openLable;//自动播放的打开时间
@property (weak, nonatomic) IBOutlet UILabel *Play_CloseLabel;//自动播放的关闭时间

//闹钟标签
@property (weak, nonatomic) IBOutlet UILabel *Alaem_oneLable;

@property (weak, nonatomic) IBOutlet UILabel *Alaem_twoLable;

//图标
@property (weak, nonatomic) IBOutlet UIImageView *lightImageView;

@property (weak, nonatomic) IBOutlet UIImageView *playImageView;

@property (weak, nonatomic) IBOutlet UIImageView *alramImageView;

//自动适配
//light
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *superlightViewHeght;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightSiwtchView;

//play
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *superPlayViewHeght;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playSwitchView;

//naozhong

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alrmSwitchView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alramOneLabelTopLayout;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alramTwoLabelTopLayout;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alramOneLabelLeadLayout;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alramTwoLabelLeadLayout;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BTSwithOneTrailLayout;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BTSwithTwoTrailLayout;







@property (weak, nonatomic) IBOutlet UIButton *lightOpenBtn;
@property (weak, nonatomic) IBOutlet UIButton *lightCloseBtn;

@property (weak, nonatomic) IBOutlet UIButton *playOpenBtn;

@property (weak, nonatomic) IBOutlet UIButton *playCloseBtn;

@property (weak, nonatomic) IBOutlet UIButton *alarmBtn_1;
@property (weak, nonatomic) IBOutlet UIButton *alarmBtn_2;








@end

@implementation


LGAlarmViewController
{
    NSInteger _currentDateTag;
}



#pragma mark -  生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLayout];
    
    [self createLabel];
    
    self.navigationController.tabBarItem.selectedImage = [[UIImage imageNamed:@"定时-点击"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"导航背景"]forBarMetrics:UIBarMetricsDefault];
    
    //    页面背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:198/255.0 blue:175/255.0 alpha:1.0f];
    
    //标题颜色和字体
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.button.hidden  =  NO;
    [[_pickerDate.subviews objectAtIndex:1] setHidden:TRUE];
    
    self.button1.hidden =  NO;
    [[_pickerDate.subviews objectAtIndex:1] setHidden:TRUE];
    
    self.Auto_Lig_Close.hidden =  NO;
    [[_pickerDate.subviews objectAtIndex:1] setHidden:TRUE];
    
    self.Auto_Lig_Open.hidden =  NO;
    [[_pickerDate.subviews objectAtIndex:1] setHidden:TRUE];
    
    self.Auto_PLay_Close.hidden = NO;
    [[_pickerDate.subviews objectAtIndex:1] setHidden:TRUE];
    
    self.Auto_PLay_Open.hidden = NO;
    [[_pickerDate.subviews objectAtIndex:1] setHidden:TRUE];
    
}





-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:@(_sw_AutomaticLamp.on) forKey:@"LampIsOn"];
    [[NSUserDefaults standardUserDefaults] setObject:@(_sw_AutomaticPlay.on) forKey:@"PlayIsOn"];
    [[NSUserDefaults standardUserDefaults] setObject:@(_BT_Switch.on) forKey:@"Alarm1"];
    [[NSUserDefaults standardUserDefaults] setObject:@(_BT_Switch2.on) forKey:@"Alarm2"];

}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //同步时间
    
    [self sendSystemTimer];
    
    
    
 
    _sw_AutomaticLamp.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LampIsOn"] boolValue];
    
    _sw_AutomaticPlay.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PlayIsOn"] boolValue];
    
    _BT_Switch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Alarm1"] boolValue];
    
    _BT_Switch2.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Alarm2"] boolValue];
    

    
}
















-(void)initLayout{
    
    //英文适配
    NSLocale *locale = [NSLocale currentLocale];
    
    NSString *currentLangue = [locale localeIdentifier];
    NSLog(@"currentLangue=%@",currentLangue);
    
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        
        self.superlightViewHeght.constant = 120;
        self.lightSiwtchView.constant =35;
        
        self.superPlayViewHeght.constant = 120;
        self.playSwitchView.constant = 35;
        
        //naozhong Label
        self.alramOneLabelTopLayout.constant = 20;
        
        self.alramTwoLabelTopLayout.constant = 25;
        
        self.alramOneLabelLeadLayout.constant = 104;
        self.alramTwoLabelLeadLayout.constant = 85;
        
        
        self.BTSwithOneTrailLayout.constant = 12;
        self.BTSwithTwoTrailLayout.constant = 12;
        
        
    }
    
    if ([UIScreen mainScreen].bounds.size.height == 736) {
        self.superPlayViewHeght.constant = 180;
        self.superlightViewHeght.constant = 180;
        
        // en_CN  zh_CN
        if ([currentLangue isEqualToString:@"en_CN"]) {
            
            self.alramTwoLabelLeadLayout.constant = 90;
            
        }
        
    }
    
    
    if ([UIScreen mainScreen].bounds.size.height == 667) {
        self.superlightViewHeght.constant = 160;
        self.superPlayViewHeght.constant = 160;
        
        if ([currentLangue isEqualToString:@"en_CN"]) {
            
            self.alramTwoLabelLeadLayout.constant = 90;
        }
    }
    
}












#pragma mark -  pickerView
- (PickerBackView *)backView {
    if(_backView == nil) {
        _backView = [[PickerBackView alloc] init];
        //        _backView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        [self.view addSubview:_backView];
        [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        //放置pickerDate的View
        _pickerDateView = [[UIView alloc] init];
        _pickerDateView.backgroundColor = [UIColor whiteColor];
        _pickerDateView.layer.cornerRadius = 5.0f;
        
        [_backView addSubview:_pickerDateView];
        [_pickerDateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(300, 300));
        }];
        
        _pickerDate = [[UIDatePicker alloc] init];
        _pickerDate.tintColor= [UIColor whiteColor];
        _pickerDate.datePickerMode = UIDatePickerModeTime;
        [_pickerDateView addSubview:_pickerDate];
        [_pickerDate mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(250);
        }];
        
        UIView* lineVIew1 = [[UIView alloc] init];
        lineVIew1.backgroundColor = [UIColor lightGrayColor];
        [_pickerDateView addSubview:lineVIew1];
        [lineVIew1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.top.mas_equalTo(_pickerDate.mas_bottom).mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        
        
        
        //取消按钮
        UIButton* cancelBtn = [[UIButton alloc] init];
        [cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(ciickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
        [_pickerDateView addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(lineVIew1.mas_bottom).mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(149.5);
        }];
        
        UIView* lineVIew2 = [[UIView alloc] init];
        //        lineVIew2.backgroundColor = [UIColor lightGrayColor];
        [_pickerDateView addSubview:lineVIew2];
        [lineVIew2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(cancelBtn.mas_right).mas_equalTo(0);
            make.top.mas_equalTo(lineVIew1.mas_bottom).mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(1);
        }];
        
        //确定按钮
        UIButton* comfirmBtn = [[UIButton alloc] init];
        [comfirmBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
        [comfirmBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [comfirmBtn addTarget:self action:@selector(ciickComfirmBtn) forControlEvents:UIControlEventTouchUpInside];
        [_pickerDateView addSubview:comfirmBtn];
        
        [comfirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(lineVIew1.mas_bottom).mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(149.5);
        }];
        
        
    }
    return _backView;
}





#pragma mark -  确定按钮
-(void)ciickComfirmBtn
{
    
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"HH:mm"];
    NSString* strdate = [formatter stringFromDate:_pickerDate.date];//使用系统的转换会考虑时区问题
    
    
    switch (_currentDateTag) {
            //闹钟1
        case 10:
        {
            self.button.selected = YES;
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:strdate forKey:@"dateStr"];
            
            [self.button setTitle:[strdate substringWithRange:NSMakeRange(0, 5)] forState:UIControlStateNormal];
            [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            //选择一次就将开关设置为关
            [_BT_Switch setOn:YES];
            [self Timeo_SW:_BT_Switch];
        }
            break;
            
            //闹钟2
        case 20:
        {
            self.button1.selected = YES;
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:strdate forKey:@"CanceldateStr"];
            
            [self.button1 setTitle:[strdate substringWithRange:NSMakeRange(0, 5)] forState:UIControlStateNormal];
            [_button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            //选择一次就将开关设置为关
            [_BT_Switch2 setOn:YES];
            [self TimeT_SW:_BT_Switch2];
            
        }
            break;
            
            
            
            
            
            
            //自动灯光关闭时间
        case 30:
        {
            self.Auto_Lig_Close.selected = YES;
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:strdate forKey:@"lightcloseTime"];
            
            [self.Auto_Lig_Close setTitle:[strdate substringWithRange:NSMakeRange(0, 5)] forState:UIControlStateNormal];
            [_Auto_Lig_Close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            
            
            [_sw_AutomaticLamp setOn:YES];
            [self AutoLight_SW:_sw_AutomaticLamp];
            
        }
            break;
            
            //自动灯光打开时间
        case 40:
        {
            self.Auto_Lig_Open.selected = YES;
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:strdate forKey:@"lightopenTime"];
            
            [self.Auto_Lig_Open setTitle:[strdate substringWithRange:NSMakeRange(0, 5)] forState:UIControlStateNormal];
            [_Auto_Lig_Open setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            
            [_sw_AutomaticLamp setOn:YES];
            [self AutoLight_SW:_sw_AutomaticLamp];
            
            
            
            
        }
            break;
            
            
            
            
            
            //自动播放关闭
        case 50:
        {
            self.Auto_PLay_Close.selected =YES;

            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:strdate forKey:@"playcloseTime"];
            
            [self.Auto_PLay_Close setTitle:[strdate substringWithRange:NSMakeRange(0, 5)] forState:UIControlStateNormal];
            [_Auto_PLay_Close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sw_AutomaticPlay setOn:YES];
            [self Autoplay_SW:_sw_AutomaticPlay];
            
        }
            break;
            
            //自动打开
        case 60:
        {
            self.Auto_PLay_Open.selected =YES;
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:strdate forKey:@"playopenTime"];
            
            [self.Auto_PLay_Open setTitle:[strdate substringWithRange:NSMakeRange(0, 5)] forState:UIControlStateNormal];
            [_Auto_PLay_Open setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sw_AutomaticPlay setOn:YES];
            [self Autoplay_SW:_sw_AutomaticPlay];
            
        }
            break;
    }
    
    self.backView.hidden = YES;
    
}














#pragma mark -  自动灯光
//自动灯光打开时间
- (UIButton *)Auto_Lig_Open {
    
    if(_Auto_Lig_Open == nil) {
        _Auto_Lig_Open = [[UIButton alloc] init];
        _Auto_Lig_Open.titleLabel.font=[UIFont systemFontOfSize:15.0];
        
        [_Auto_Lig_Open setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        
        _Auto_Lig_Open.tag = 40;
        
        
        
        

        NSUserDefaults *userDefaalt = [NSUserDefaults standardUserDefaults];
        NSString *cancelstr = [userDefaalt stringForKey:@"lightopenTime"];
        if (![cancelstr isEqualToString:NSLocalizedString(@"AddTime", nil)]) {
            [_Auto_Lig_Open setTitle:cancelstr forState:UIControlStateNormal];
            [_Auto_Lig_Open setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if (cancelstr == nil) {
                [_Auto_Lig_Open setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
                [_Auto_Lig_Open setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            }
            
        } else{
            
            [_Auto_Lig_Open setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            [_Auto_Lig_Open setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        }
        
        [_Auto_Lig_Open addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        [_lightOpenBtn addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        UILongPressGestureRecognizer *longPressGR =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(long_Lig_bt2:)];
        UILongPressGestureRecognizer *longPressGRB =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(long_Lig_bt2:)];
        longPressGR.minimumPressDuration = 0.5;
        longPressGRB.minimumPressDuration = 0.5;
        [_Auto_Lig_Open addGestureRecognizer:longPressGR];
        [_lightOpenBtn addGestureRecognizer:longPressGRB];
        
        
        
        [self.view addSubview:_Auto_Lig_Open];
//        [self.view bringSubviewToFront:_lightOpenBtn];
        
        
        [_Auto_Lig_Open mas_makeConstraints:^(MASConstraintMaker *make) {
            //            make.center.mas_equalTo(0);
            make.centerY.mas_equalTo(_OpenLable.mas_centerY );
            make.left.mas_equalTo(_OpenLable.mas_right).with.offset(20);
            make.size.mas_equalTo(CGSizeMake(70, 30));
            
        }];
    }
    return _Auto_Lig_Open;
}






// 自动灯光！  关闭时间的按钮
- (UIButton *)Auto_Lig_Close {
    if(_Auto_Lig_Close == nil) {
        _Auto_Lig_Close = [[UIButton alloc] init];
        _Auto_Lig_Close.titleLabel.font=[UIFont systemFontOfSize:15.0];
        
        [_Auto_Lig_Close setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        
        
        _Auto_Lig_Close.tag = 30;
        
        
        
        
        NSUserDefaults *userDefaalt = [NSUserDefaults standardUserDefaults];
        NSString *cancelstr = [userDefaalt stringForKey:@"lightcloseTime"];
        
        if (![cancelstr isEqualToString:NSLocalizedString(@"AddTime", nil)]) {
            [_Auto_Lig_Close setTitle:cancelstr forState:UIControlStateNormal];
            [_Auto_Lig_Close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if (cancelstr == nil) {
                [_Auto_Lig_Close setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
                [_Auto_Lig_Close setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            }
            
        } else{
            
            [_Auto_Lig_Close setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            [_Auto_Lig_Close setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        }
        
        [_Auto_Lig_Close addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        [_lightCloseBtn addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UILongPressGestureRecognizer *longPressGR =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longLig_bt1:)];
        UILongPressGestureRecognizer *longPressGRB =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longLig_bt1:)];
        longPressGR.minimumPressDuration = 0.5;
        longPressGRB.minimumPressDuration = 0.5;
        [_Auto_Lig_Close addGestureRecognizer:longPressGR];
        [_lightCloseBtn addGestureRecognizer:longPressGRB];
        
        
        
        
        
        
        [self.view addSubview:_Auto_Lig_Close];
        [_Auto_Lig_Close mas_makeConstraints:^(MASConstraintMaker *make) {
            //            make.center.mas_equalTo(0);
            make.centerY.mas_equalTo(_CloseLabel.mas_centerY);
            
            make.left.mas_equalTo(self.Auto_Lig_Open.mas_left);
            make.left.mas_equalTo(_CloseLabel.mas_right).with.offset(20);
            
            make.size.mas_equalTo(CGSizeMake(70, 30));
            
        }];
    }
    return _Auto_Lig_Close;
}







-(void)long_Lig_bt2:(UILongPressGestureRecognizer*)long_Lig_bt2{
    
    if (long_Lig_bt2.state == UIGestureRecognizerStateBegan) {
        
        // 1.创建alertController实例,并说明样式
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"DeleteTime", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        // 2.创建按钮行为
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            

            //如果关闭时间有值
            if (_Auto_Lig_Close.selected) {
                [self sendCharacterialRecvieLightTimeWithButton:_Auto_Lig_Open withCloseBtn:_Auto_Lig_Close WithDateString:InvalidTime withCloseStr:[self getTime:@"lightcloseTime"]];
            }else{
                
                [self.sw_AutomaticLamp setOn:NO];
                [self sendCharacterialRecvieLightTimeWithButton:_Auto_Lig_Open withCloseBtn:_Auto_Lig_Close WithDateString:InvalidTime withCloseStr:InvalidTime];
            }
            
            
            
            
            _Auto_Lig_Open.selected =NO;
            

            NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
            [userdefault setObject:NSLocalizedString(@"AddTime", nil) forKey:@"lightopenTime"];
       
            
            [_Auto_Lig_Open setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            
            [_Auto_Lig_Open setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
            
        }];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"点击了NO按钮");
            
        }];
        // 3.添加行为到控制器中
        [alertController addAction:yesAction];
        [alertController addAction:noAction];
        
        // 5.推出控制器,显示界面
        // 两个控制器之间的切换,方法一就是使用present方法
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
}




-(void)longLig_bt1:(UILongPressGestureRecognizer*)longLig_bt1{
    if (longLig_bt1.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按开始");
        // 1.创建alertController实例,并说明样式
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"DeleteTime", nil)preferredStyle:UIAlertControllerStyleAlert];
        
        // 2.创建按钮行为
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            
            
            //如果打开时间有值
            if (_Auto_Lig_Open.selected) {
                [self sendCharacterialRecvieLightTimeWithButton:_Auto_Lig_Open withCloseBtn:_Auto_Lig_Close WithDateString:[self getTime:@"lightopenTime"] withCloseStr:InvalidTime];
            }else{
                
                [self.sw_AutomaticLamp setOn:NO];
                [self sendCharacterialRecvieLightTimeWithButton:_Auto_Lig_Open withCloseBtn:_Auto_Lig_Close WithDateString:InvalidTime withCloseStr:InvalidTime];
            }
            
            _Auto_Lig_Close.selected =NO;
            
#pragma mark - 长按删除NSUserdefault
            NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
            [userdefault setObject:NSLocalizedString(@"AddTime", nil) forKey:@"lightcloseTime"];
          
            [_Auto_Lig_Close setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            
            [_Auto_Lig_Close setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        }];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            NSLog(@"点击了NO按钮");
            
        }];
        
        // 3.添加行为到控制器中
        [alertController addAction:yesAction];
        [alertController addAction:noAction];
        
        // 5.推出控制器,显示界面
        // 两个控制器之间的切换,方法一就是使用present方法
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
    
}


















#pragma mark -  自动播放
//自动播放打开时间
- (UIButton *)Auto_PLay_Open {
    if(_Auto_PLay_Open == nil) {
        _Auto_PLay_Open = [[UIButton alloc] init];
        _Auto_PLay_Open.titleLabel.font=[UIFont systemFontOfSize:15.0];
        
        [_Auto_PLay_Open setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        
        _Auto_PLay_Open.tag = 60;
        
        
        [_Auto_PLay_Open setTintColor:[UIColor blueColor]];

        
        NSUserDefaults *userDefaalt = [NSUserDefaults standardUserDefaults];
        NSString *openstr = [userDefaalt stringForKey:@"playopenTime"];
        
        
        if (![openstr isEqualToString:NSLocalizedString(@"AddTime", nil)]) {
            [_Auto_PLay_Open setTitle:openstr forState:UIControlStateNormal];
            [_Auto_PLay_Open setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if (openstr == nil) {
                [_Auto_PLay_Open setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
                [_Auto_PLay_Open setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            }
            
        } else{
            
            [_Auto_PLay_Open setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            [_Auto_PLay_Open setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        }
        
        [_Auto_PLay_Open addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        [_playOpenBtn addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        
        
        
        
        
        
        
        //        [_button addTarget:self action:@selector(<#selector#>) forControlEvents:<#(UIControlEvents)#>]
        UILongPressGestureRecognizer *longPressGR =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(long_Play_bt2:)];
        UILongPressGestureRecognizer *longPressGRB =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(long_Play_bt2:)];
        longPressGR.minimumPressDuration = 0.5;
        longPressGRB.minimumPressDuration = 0.5;
        [_Auto_PLay_Open addGestureRecognizer:longPressGR];
        [_playOpenBtn addGestureRecognizer:longPressGRB];
        
        
        
        [self.view addSubview:_Auto_PLay_Open];
        [_Auto_PLay_Open mas_makeConstraints:^(MASConstraintMaker *make) {
            //            make.center.mas_equalTo(0);
            make.centerY.mas_equalTo(_Play_openLable.mas_centerY);
            make.left.mas_equalTo(_Play_openLable.mas_right).with.offset(20);
            make.size.mas_equalTo(CGSizeMake(70, 30));
            
        }];
    }
    return _Auto_PLay_Open;
}



-(void)long_Play_bt2:(UILongPressGestureRecognizer*)long_Play_bt2{
    if (long_Play_bt2.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按开始");
        // 1.创建alertController实例,并说明样式
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"DeleteTime", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        // 2.创建按钮行为
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil)   style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            
            
            
            
            
            //如果关闭时间有值
            if (_Auto_PLay_Close.selected) {
                [self sendCharacterialRecviePlayTimeWithButton:_Auto_PLay_Open withCloseBtn:_Auto_PLay_Close WithDateString:InvalidTime withCloseStr:[self getTime:@"playcloseTime"]];
            }else{
                
                [self.sw_AutomaticPlay setOn:NO];
                [self sendCharacterialRecviePlayTimeWithButton:_Auto_PLay_Open withCloseBtn:_Auto_PLay_Close WithDateString:InvalidTime withCloseStr:InvalidTime];
            }
            
            _Auto_PLay_Open.selected =NO;
            
            
      
            
            
#pragma mark - 新增内容
            NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
           [userdefault setObject:NSLocalizedString(@"AddTime", nil) forKey:@"playopenTime"];
            
            [_Auto_PLay_Open setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            
            [_Auto_PLay_Open setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        }];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"点击了NO按钮");
            
        }];
        
        // 3.添加行为到控制器中
        [alertController addAction:yesAction];
        [alertController addAction:noAction];
        
        // 5.推出控制器,显示界面
        // 两个控制器之间的切换,方法一就是使用present方法
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}








//自动播放 关闭时间Button
- (UIButton *)Auto_PLay_Close {
    if(_Auto_PLay_Close == nil) {
        _Auto_PLay_Close = [[UIButton alloc] init];
        _Auto_PLay_Close.titleLabel.font=[UIFont systemFontOfSize:15.0];
        
        [_Auto_PLay_Close setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        
        _Auto_PLay_Close.tag = 50;
        
        
        [_Auto_PLay_Close setTintColor:[UIColor blueColor]];
#pragma mark - 新增内容
        NSUserDefaults *userDefaalt = [NSUserDefaults standardUserDefaults];
        NSString *cancelstr = [userDefaalt stringForKey:@"playcloseTime"];
        
        
        if (![cancelstr isEqualToString:NSLocalizedString(@"AddTime", nil)]) {
            [_Auto_PLay_Close setTitle:cancelstr forState:UIControlStateNormal];
            [_Auto_PLay_Close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if (cancelstr == nil) {
                [_Auto_PLay_Close setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
                [_Auto_PLay_Close setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            }
            
        } else{
            
            [_Auto_PLay_Close setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            [_Auto_PLay_Close setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        }
        
        
        
        [_Auto_PLay_Close addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        [_playCloseBtn addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        UILongPressGestureRecognizer *longPressGR =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(long_Play_bt1:)];
        UILongPressGestureRecognizer *longPressGRB =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(long_Play_bt1:)];
        longPressGR.minimumPressDuration = 0.5;
        longPressGRB.minimumPressDuration = 0.5;
        [_Auto_PLay_Close addGestureRecognizer:longPressGR];
        [_playCloseBtn addGestureRecognizer:longPressGRB];
        
        
        
        
        [self.view addSubview:_Auto_PLay_Close];
        [_Auto_PLay_Close mas_makeConstraints:^(MASConstraintMaker *make) {
            //            make.center.mas_equalTo(0);
            make.centerY.mas_equalTo(_Play_CloseLabel.mas_centerY);
            make.left.mas_equalTo(_Play_CloseLabel.mas_right).with.offset(20);
            make.size.mas_equalTo(CGSizeMake(70, 30));
            
        }];
    }
    return _Auto_PLay_Close;
}



-(void)long_Play_bt1:(UILongPressGestureRecognizer*)long_Play_bt1{
    
    if (long_Play_bt1.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按开始");
        // 1.创建alertController实例,并说明样式
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"DeleteTime", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        // 2.创建按钮行为
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            

            //如果关闭时间有值
            if (_Auto_PLay_Open.selected) {
                [self sendCharacterialRecviePlayTimeWithButton:_Auto_PLay_Open withCloseBtn:_Auto_PLay_Close WithDateString:[self getTime:@"playopenTime"] withCloseStr:InvalidTime];
            }else{
                
                [self.sw_AutomaticPlay setOn:NO];
                [self sendCharacterialRecviePlayTimeWithButton:_Auto_PLay_Open withCloseBtn:_Auto_PLay_Close WithDateString:InvalidTime withCloseStr:InvalidTime];
            }
            
            _Auto_PLay_Close.selected =NO;
            
            

            NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
            [userdefault setObject:NSLocalizedString(@"AddTime", nil) forKey:@"playcloseTime"];
            
            
            [_Auto_PLay_Close setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            
            [_Auto_PLay_Close setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        }];
        
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"点击了NO按钮");
            
        }];
        
        // 3.添加行为到控制器中
        [alertController addAction:yesAction];
        [alertController addAction:noAction];
        
        // 5.推出控制器,显示界面
        // 两个控制器之间的切换,方法一就是使用present方法
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

























#pragma mark -  自动灯光SWITCH
- (IBAction)AutoLight_SW:(UISwitch *)sender {
    if ([_bleManager isConnected]) {
        
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSString *dataStr = [userdefault stringForKey:@"lightopenTime"];
        NSString *lightCloseStr =[userdefault stringForKey:@"lightcloseTime"];
        
        //第一次打开
//        if (!dataStr && !lightCloseStr) {
//            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请设置打开时间", nil)];
//            sender.on = NO;
//        }
//        
        
        
        
        //第一次打开
        if (!dataStr) {
            dataStr = NSLocalizedString(@"AddTime", nil);
        }
        
        if (!lightCloseStr) {
            lightCloseStr = NSLocalizedString(@"AddTime", nil);
        }
        
        
        if ([dataStr isEqualToString:NSLocalizedString(@"AddTime", nil)] && [lightCloseStr isEqualToString:NSLocalizedString(@"AddTime", nil)] ) {
            
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请设置打开时间", nil)];
            sender.on = NO;
            
            
        }
        
        else{
        

        
        if (![dataStr isEqualToString:NSLocalizedString(@"AddTime", nil)]&&!(dataStr == nil)&&![lightCloseStr isEqualToString:NSLocalizedString(@"AddTime", nil)]&&!(lightCloseStr==nil)) {
            
            
            
            [self sendCharacterialRecvieLightTimeWithButton:self.Auto_Lig_Open withCloseBtn:self.Auto_Lig_Close WithDateString:dataStr withCloseStr:lightCloseStr];
            
            
        }else if (_Auto_Lig_Open.selected){
            
            
            
            
            [self sendCharacterialRecvieLightTimeWithButton:_Auto_Lig_Open withCloseBtn:_Auto_Lig_Close WithDateString:[self getTime:LightOpenTime] withCloseStr:InvalidTime];
            
            
            
            
        }else if(_Auto_Lig_Close.selected){
            
            
            [self sendCharacterialRecvieLightTimeWithButton:_Auto_Lig_Open withCloseBtn:_Auto_Lig_Close WithDateString:InvalidTime withCloseStr:[self getTime:LightCloseTime]];
            
            
            
        }else{
 
            
            [self sendCharacterialRecvieLightTimeWithButton:self.Auto_Lig_Open withCloseBtn:self.Auto_Lig_Close WithDateString:InvalidTime withCloseStr:InvalidTime];

        }
        
        
        
        }
        
        
        
        
        
    }else{
        [sender setOn:NO];
        self.lightImageView.image = [UIImage imageNamed:@"自动灯光-点击"];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }
    
    
    
}










#pragma mark -  自动播放switch
- (IBAction)Autoplay_SW:(UISwitch *)sender {
    
    if ([_bleManager isConnected]) {
        
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSString *dataStr = [userdefault stringForKey:@"playopenTime"];
        
        
        NSString *playCloseStr =[userdefault stringForKey:@"playcloseTime"];
        
        
        //第一次打开
//        if (!dataStr && !playCloseStr) {
//            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请设置打开时间", nil)];
//            sender.on = NO;
//        }
        
        
        
        //第一次打开
        if (!dataStr) {
            dataStr = NSLocalizedString(@"AddTime", nil);
        }
        
        if (!playCloseStr) {
            playCloseStr = NSLocalizedString(@"AddTime", nil);
        }
        
        
        //如果两个都没有值
        if ([dataStr isEqualToString:NSLocalizedString(@"AddTime", nil)] && [playCloseStr isEqualToString:NSLocalizedString(@"AddTime", nil)]) {
            
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请设置打开时间", nil)];
            sender.on = NO;
            
            
        }
        
        else{
        
         
            if (![dataStr isEqualToString:NSLocalizedString(@"AddTime", nil)]&&!(dataStr == nil)&&![playCloseStr isEqualToString:NSLocalizedString(@"AddTime", nil)]&&!(playCloseStr==nil)){
                
                
                
                [self sendCharacterialRecviePlayTimeWithButton:self.Auto_PLay_Open withCloseBtn:self.Auto_PLay_Close WithDateString:dataStr withCloseStr:playCloseStr];
                
                
            }else if (_Auto_PLay_Open.selected) {
                
                
                [self sendCharacterialRecviePlayTimeWithButton:self.Auto_PLay_Open withCloseBtn:self.Auto_PLay_Close WithDateString:dataStr withCloseStr:InvalidTime];
                
            }else if(_Auto_PLay_Close.selected){
                
                [self sendCharacterialRecviePlayTimeWithButton:self.Auto_PLay_Open withCloseBtn:self.Auto_PLay_Close WithDateString:InvalidTime withCloseStr:playCloseStr];
                
                
            }else{
                
                [self sendCharacterialRecviePlayTimeWithButton:self.Auto_PLay_Open withCloseBtn:self.Auto_PLay_Close WithDateString:InvalidTime withCloseStr:InvalidTime];
                
                
            }
        
        }
        
        
        

        
        
    }else{
        [sender setOn:NO];
        self.playImageView.image = [UIImage imageNamed:@"自动播放"];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }
    
}
















//按钮1
#pragma 闹钟按钮
- (UIButton *)button {
    if(_button == nil) {
        
        
        _button = [[UIButton alloc] init];
        _button.titleLabel.font=[UIFont systemFontOfSize:15.0];
        
        [_button setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        
        _button.tag = 10;
#pragma mark - 取NSUserDefault的数据
        NSUserDefaults *userDefaalt = [NSUserDefaults standardUserDefaults];
        NSString *str = [userDefaalt stringForKey:@"dateStr"];
        
        
        if (![str isEqualToString:NSLocalizedString(@"AddTime", nil)]) {
            [_button setTitle:str forState:UIControlStateNormal];
            [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if (!str) {
                [_button setTitleColor:[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1] forState:UIControlStateNormal];
                [_button setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            }
        
        }else{
            [_button setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            [_button setTitleColor:[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1] forState:UIControlStateNormal];
        }
        
       
      
        
        
        [_button addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        [_alarmBtn_1 addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UILongPressGestureRecognizer *longPressGR =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longPress:)];
        UILongPressGestureRecognizer *longPressGRB =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longPress:)];
        longPressGR.minimumPressDuration = 0.5;
        longPressGRB.minimumPressDuration = 0.5;
        [_button addGestureRecognizer:longPressGR];
        [_alarmBtn_1 addGestureRecognizer:longPressGRB];
        
        
        
        
        
        [self.view addSubview:_button];
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.mas_equalTo(0);
            make.top.mas_equalTo(_Alaem_oneLable.mas_top);
            make.left.mas_equalTo(_Alaem_oneLable.mas_left).with.offset(97);
            make.size.mas_equalTo(CGSizeMake(80, 20));
            
            NSLocale *locale = [NSLocale currentLocale];
            NSString *currentLangue = [locale localeIdentifier];
            if ([currentLangue isEqualToString:@"en_CN"]) {
                
                make.left.mas_equalTo(_Alaem_oneLable.mas_left).with.offset(97);
            }
            
            if ([UIScreen mainScreen].bounds.size.height == 568) {
              
                make.left.mas_equalTo(_Alaem_oneLable.mas_left).with.offset(80);
                make.size.mas_equalTo(CGSizeMake(80, 20));
            }
            
            
            
            
        }];
    }
    return _button;
}



- (UIButton *)button1 {
    if(_button1 == nil) {
        _button1 = [[UIButton alloc] init];
        _button1.titleLabel.font=[UIFont systemFontOfSize:15.0];
        
        [_button1 setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        [_button1 addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        [_alarmBtn_2 addTarget:self action:@selector(clickPickerDate:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        
        _button1.tag = 20;
#pragma mark - 新增加内容
        
        NSUserDefaults *userDefaalt = [NSUserDefaults standardUserDefaults];
        NSString *cancelstr = [userDefaalt stringForKey:@"CanceldateStr"];
        
        
        if (![cancelstr isEqualToString:NSLocalizedString(@"AddTime", nil)]) {
            [_button1 setTitle:cancelstr forState:UIControlStateNormal];
            [_button1 setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
            if (!cancelstr) {
                [_button1 setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
                [_button1 setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            }
            
        } else{
            
            [_button1 setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            [_button1 setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        }
        
        
        
        UILongPressGestureRecognizer *longPressGR =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longSecond:)];
        UILongPressGestureRecognizer *longPressGRB =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(longSecond:)];
        longPressGR.minimumPressDuration = 0.5;
        longPressGRB.minimumPressDuration = 0.5;
        [_button1 addGestureRecognizer:longPressGR];
        [_alarmBtn_2 addGestureRecognizer:longPressGRB];
        
        
        
        
        [self.view addSubview:_button1];
        [_button1 mas_makeConstraints:^(MASConstraintMaker *make) {
            //            make.center.mas_equalTo(0);
            make.top.mas_equalTo(_Alaem_twoLable.mas_top );
            make.left.mas_equalTo(_Alaem_twoLable.mas_left).with.offset(97);
            make.size.mas_equalTo(CGSizeMake(80, 20));
            
            //英文适配
            NSLocale *locale = [NSLocale currentLocale];
            NSString *currentLangue = [locale localeIdentifier];
            if ([currentLangue isEqualToString:@"en_CN"]) {
                
                make.left.mas_equalTo(_Alaem_twoLable.mas_left).with.offset(97);
                
            }
            
            
            if ([UIScreen mainScreen].bounds.size.height == 568) {
                
                make.left.mas_equalTo(_Alaem_twoLable.mas_left).with.offset(80);
                make.size.mas_equalTo(CGSizeMake(80, 20));
            }
            
            
        }];
    }
    return _button1;
}






#pragma mark 按钮闹钟长按事件
-(void)longPress:(UILongPressGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        // 1.创建alertController实例,并说明样式
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"DeleteAlarmFirst", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        // 2.创建按钮行为
          UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            
            [self.BT_Switch setOn:NO];
            
            _button.selected = NO;
              
   
            [self sendCharacterialRecvieOpenTimeWithButton:_button WithDateString:InvalidTime];
#pragma mark - 长按去除 NSuserDefault数据
              NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
              
              [userdefault setObject:NSLocalizedString(@"AddTime", nil) forKey:@"dateStr"];
              
              
              [_button setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
            
              [_button setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
              
        }];
        
        
        
        
        
          UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            
            
        }];
        // 3.添加行为到控制器中
        [alertController addAction:yesAction];
        [alertController addAction:noAction];
        
        // 5.推出控制器,显示界面
        // 两个控制器之间的切换,方法一就是使用present方法
        [self presentViewController:alertController animated:YES completion:nil];
    }


}





-(void)longSecond:(UILongPressGestureRecognizer*)longSecond{
    if (longSecond.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按开始");
        // 1.创建alertController实例,并说明样式
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"DeleteAlarmSecond", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        // 2.创建按钮行为
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            [self.BT_Switch2 setOn:NO];
            
            _button1.selected = NO;

            [self sendCharacterialRecvieTimeWithButton:_button1 WithDateString:InvalidTime];

 
            NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
            
            [userdefault setObject:NSLocalizedString(@"AddTime", nil) forKey:@"CanceldateStr"];
            [_button1 setTitle:NSLocalizedString(@"AddTime", nil) forState:UIControlStateNormal];
           
            [_button1 setTitleColor:[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1] forState:UIControlStateNormal];
        }];
        
         UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            
            
        }];
        // 3.添加行为到控制器中
        [alertController addAction:yesAction];
        [alertController addAction:noAction];
        
        // 5.推出控制器,显示界面
        // 两个控制器之间的切换,方法一就是使用present方法
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
}






//闹钟设置1
- (IBAction)Timeo_SW:(UISwitch *)sender {
    
    if ([_bleManager isConnected]) {
        
        //重新启动App 点击开关下发数据
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSString *dataStr = [userdefault stringForKey:@"dateStr"];
        
        
        
        //第一次打开
//        if (!dataStr ) {
//            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请设置打开时间", nil)];
//            sender.on = NO;
//        }

        
        
        if (!dataStr) {
            dataStr = NSLocalizedString(@"AddTime", nil);
        }
        
        
        if ([dataStr isEqualToString:NSLocalizedString(@"AddTime", nil)] ) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请设置闹钟1", nil)];
            sender.on = NO;
        }
        
        else{
            if (![dataStr isEqualToString:@"AddTime"]&&!(dataStr == nil) && sender.on) {
                
                
                
                [self sendCharacterialRecvieOpenTimeWithButton:self.button WithDateString:dataStr];
                
                
                
            } else if(![dataStr isEqualToString:@"AddTime"] && dataStr){
                
                
                
                [self sendCharacterialRecvieOpenTimeWithButton:self.button WithDateString:dataStr];
                
                
                
            }
        
        }
        
        
        

        


        
    }else{
        [sender setOn:NO];
        self.alramImageView.image = [UIImage imageNamed:@"闹钟-点击"];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }
    
}


//闹钟设置2
- (IBAction)TimeT_SW:(UISwitch *)sender {
    if ([_bleManager isConnected]) {
#pragma mark - 如果NSUserdefault里面有数据则可以下发
        //重新启动App 点击开关下发数据
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSString *dataStr = [userdefault stringForKey:@"CanceldateStr"];
        
        
        //第一次打开
//        if (!dataStr) {
//            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请设置打开时间", nil)];
//            sender.on = NO;
//        }
        
        
        if (!dataStr) {
            dataStr = NSLocalizedString(@"AddTime", nil);
        }
        
        
        if ([dataStr isEqualToString:NSLocalizedString(@"AddTime", nil)] ) {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"请设置闹钟2", nil)];
            sender.on = NO;
        }
        else
        {
        
            if (![dataStr isEqualToString:@"AddTime"]&&!(dataStr == nil)  && sender.on) {
                
                
                [self sendCharacterialRecvieTimeWithButton:self.button1 WithDateString:dataStr];
                
            }else if(![dataStr isEqualToString:@"AddTime"] && dataStr){
                
                
                [self sendCharacterialRecvieTimeWithButton:self.button1 WithDateString:dataStr];
                
            }

        }
        
        

    
        
    }else{
        [sender setOn:NO];
        
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }
}











#pragma mark ---触发响应---
-(void)clickPickerDate:(UIButton*)button
{
    
    NSLog(@"点击了弹出按钮");
    
    _currentDateTag = button.tag;
    self.backView.hidden = NO;
}


-(void)ciickCancelBtn
{
    NSLog(@"点击了取消按钮");
    self.backView.hidden = YES;
}
























#pragma mark - label的字体颜色
-(void)createLabel{
    
    _LightLabel.textColor=[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1];
    
    _PlayerLable.textColor=[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1];
    _AlaemLabel.textColor=[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1];
 //设置字体大小
    self.LightLabel.font = [UIFont systemFontOfSize:18];
    self.PlayerLable.font =[UIFont systemFontOfSize:18];
    self.AlaemLabel.font = [UIFont systemFontOfSize:18];
    
    _OpenLable.textColor=[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    _CloseLabel.textColor=[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    
    _Play_openLable.textColor=[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    _Play_CloseLabel.textColor=[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    _Alaem_oneLable.textColor=[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    _Alaem_twoLable.textColor=[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
    
    //设置时间Label的大小
    self.OpenLable.font = [UIFont systemFontOfSize:15];
    self.CloseLabel.font = [UIFont systemFontOfSize:15];
    self.Play_openLable.font = [UIFont systemFontOfSize:15];
    self.Play_CloseLabel.font =[UIFont systemFontOfSize:15];
    self.Alaem_oneLable.font = [UIFont systemFontOfSize:15];
    self.Alaem_twoLable.font = [UIFont systemFontOfSize:15];
}

















#pragma 封装 设置自动灯光的时间

-(void)sendCharacterialRecvieLightTimeWithButton:(UIButton*)openBtn withCloseBtn:(UIButton*)closeBtn WithDateString:(NSString*)openDateStr     withCloseStr:(NSString*)CloseDateStr{
    
    
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"HH:mm"];

    NSDate *date = [formatter dateFromString:openDateStr];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitHour | NSCalendarUnitMinute;
    
    NSDateComponents *comps = [calendar components:unit fromDate:date];
    
    NSInteger hour = comps.hour;
    NSInteger minute = comps.minute;
    
    
    
    
    
    NSDateFormatter* formatterPLayClose = [[NSDateFormatter alloc] init];
    [formatterPLayClose setDateFormat: @"HH:mm"];
    
    
    
    NSDate *datePLayClose = [formatterPLayClose dateFromString:CloseDateStr];
    
    NSCalendar *calendarPLayClose = [NSCalendar currentCalendar];
    
    NSCalendarUnit unitPLayClose = NSCalendarUnitHour | NSCalendarUnitMinute;
    
    NSDateComponents *compsPLayClose = [calendarPLayClose components:unitPLayClose fromDate:datePLayClose];
    
    NSInteger hourPLayClose  = compsPLayClose.hour;
    NSInteger minutePLayClose = compsPLayClose.minute;

    
    
    
    if (!hour) {
        hour = 99;
    }
    
    if (!minute) {
        minute = 99;
    }
    
    
    if (!hourPLayClose) {
        hourPLayClose = 99;
    }
    
    if (!minutePLayClose) {
        minutePLayClose = 99;
    }
    
    [self setAlarmClockTimeWithType:1 Switch:self.sw_AutomaticLamp.isOn PowerOn:0 OpenHour:hour OpenMin:minute CloseHour:hourPLayClose CloseMin:minutePLayClose];
    
}




#pragma mark -音乐播放 下发指令设置时间
-(void)sendCharacterialRecviePlayTimeWithButton:(UIButton*)openBtn withCloseBtn:(UIButton*)closeBtn WithDateString:(NSString*)openDateStr     withCloseStr:(NSString*)CloseDateStr{
    
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"HH:mm"];
    NSDate *date = [formatter dateFromString:openDateStr];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitHour | NSCalendarUnitMinute;
    
    NSDateComponents *comps = [calendar components:unit fromDate:date];
    
    NSInteger hour = comps.hour;
    NSInteger minute = comps.minute;
    
    
    
    
    NSDateFormatter* formatterPLayClose = [[NSDateFormatter alloc] init];
    [formatterPLayClose setDateFormat: @"HH:mm"];
    
    
    NSDate *datePLayClose = [formatterPLayClose dateFromString:CloseDateStr];
    
    NSCalendar *calendarPLayClose = [NSCalendar currentCalendar];
    
    NSCalendarUnit unitPLayClose = NSCalendarUnitHour | NSCalendarUnitMinute;
    
    NSDateComponents *compsPLayClose = [calendarPLayClose components:unitPLayClose fromDate:datePLayClose];
    
    NSInteger hourPLayClose  = compsPLayClose.hour;
    NSInteger minutePLayClose = compsPLayClose.minute;
    
    
    
    if (!hour) {
        hour = 99;
    }
    
    if (!minute) {
        minute = 99;
    }
    
    
    if (!hourPLayClose) {
        hourPLayClose = 99;
    }
    
    if (!minutePLayClose) {
        minutePLayClose = 99;
    }
    
    
    
    
    
    [self setAlarmClockTimeWithType:2 Switch:self.sw_AutomaticPlay.isOn PowerOn:0 OpenHour:hour OpenMin:minute CloseHour:hourPLayClose CloseMin:minutePLayClose];

}





#pragma mark -封装发送时间 设置打开闹钟

-(void)sendCharacterialRecvieOpenTimeWithButton:(UIButton*)btn WithDateString:(NSString*)datestr{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"HH:mm"];
    
    NSDate *date = [formatter dateFromString:datestr];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitHour | NSCalendarUnitMinute;
    
    NSDateComponents *comps = [calendar components:unit fromDate:date];
    
    NSInteger hour = comps.hour;
    NSInteger minute = comps.minute;
    
    
    if (!hour) {
        hour = 99;
    }
    
    if (!minute) {
        minute = 99;
    }
    
    
    
    [self setAlarmClockTimeWithType:4 Switch:self.BT_Switch.isOn PowerOn:0 OpenHour:hour OpenMin:minute CloseHour:99 CloseMin:99];
    
    
}

#pragma 封装发送时间 设置关闭闹钟
//封装设置时间
-(void)sendCharacterialRecvieTimeWithButton:(UIButton*)btn WithDateString:(NSString*)datestr{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSDate *date = [formatter dateFromString:datestr];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitHour | NSCalendarUnitMinute ;
    
    NSDateComponents *comps = [calendar components:unit fromDate:date];
    
    NSInteger hour = comps.hour;
    NSInteger minute = comps.minute;
    
    
    if (!hour) {
        hour = 99;
    }
    
    if (!minute) {
        minute = 99;
    }
    
    
    [self setAlarmClockTimeWithType:5 Switch:self.BT_Switch2.isOn PowerOn:0 OpenHour:hour OpenMin:minute CloseHour:99 CloseMin:99];
    
}












#pragma 发送命令的方法

-(void)setAlarmClockTimeWithType:(NSInteger)type Switch:(NSInteger)switchValue PowerOn:(NSInteger)powerOn OpenHour:(NSInteger)openHour OpenMin:(NSInteger)openMin CloseHour:(NSInteger)closeHour CloseMin:(NSInteger)closeMin{
    
    Byte bytes[] = {type,switchValue,powerOn,openHour,openMin,closeHour,closeMin};
    
    NSData *data = [NSData dataWithBytes:bytes length:7];
    
    

    [self adjustbyte: data];
    
}


-(void)adjustbyte:(NSData *)valueData{
    
    //声明一个字符串
    NSString *str = [NSString stringWithFormat:@"ALARM"];
    //转成Data
    [str dataUsingEncoding:NSUTF8StringEncoding];
    
    //声明一个可变Data
    NSMutableData *mutableData = [NSMutableData alloc];
    //两个Data合并
    
    
    [mutableData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [mutableData appendData: valueData];
    
    [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.alarmCharacteristics andValue:mutableData andResponseWriteType:CBCharacteristicWriteWithResponse];
}







-(NSString *)getTime:(NSString *)name{
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    return [userdefault stringForKey:name];

}










#pragma mark -  同步系统时间


-(void)sendSystemTimer{
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"hh:mm:ss"];
    
    
    NSCalendarUnit unit = NSCalendarUnitHour | NSCalendarUnitMinute|kCFCalendarUnitSecond;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [calendar components:unit fromDate:currentDate];
    
    NSInteger hour = comps.hour;
    NSInteger minute = comps.minute;
    
    NSInteger second =comps.second;
    
    
    [self  setAlarmtype:6 Switch:0 powerOn:0 HourStart:hour minStart:minute Second:second power:0];
    
    
    //    //断开连接  销毁同步时间
    //    if ([_bleManager isConnected]) {
    //
    //    }else{
    //
    //        [_Systemtimer invalidate];
    //    }
    //
    
    
}
-(void)setAlarmtype:(NSInteger)type Switch:(NSInteger)switcherValue powerOn:(NSInteger)powerOn HourStart:(NSInteger)hourStart minStart:(NSInteger)minStart Second:(NSInteger)second power:(NSInteger)power{
    
    Byte bytes[] = {type,switcherValue,powerOn,hourStart,minStart,second,power};
    
    NSData *data = [NSData dataWithBytes:bytes length:7];
    
    
    [self SynchronizationTime:data];
    
    
    
}

-(void)SynchronizationTime:(NSData *)valueDate{
    //声明一个字符串
    NSString *str = [NSString stringWithFormat:@"ALARM"];
    //转成Data
    [str dataUsingEncoding:NSUTF8StringEncoding];
    
    //声明一个可变Data
    NSMutableData *mutableData = [NSMutableData alloc];
    //两个Data合并
    
    
    [mutableData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    [mutableData appendData: valueDate];
    
    [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.alarmCharacteristics andValue:mutableData andResponseWriteType:CBCharacteristicWriteWithResponse];
    
    
}









@end
