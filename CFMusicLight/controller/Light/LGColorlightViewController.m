//
//  LGColorlightViewController.m
//  CFMusicLight
//
//  Created by 金港 on 16/9/27.
//
//

#import "LGColorlightViewController.h"
#import "MSColorWheelView.h"
#import "MSColorUtils.h"
#import "MSColorWheelView.h"
#import "MSColorUtils.h"
#import "Masonry.h"
#import "SVProgressHUD.h"
#import "SandBox.h"
#import "BLE Tool.h"
#import "LGSingleLight.h"

#import <MediaPlayer/MediaPlayer.h>


int redValue   ;
int greenValue ;
int blueValue  ;
int whiteValue ;
int YellowValue;

//static int RedTemp     = 0;
//static int GreenTemp   = 0;
//static int BLueTemp    = 0;
//static int WhiterTemp  = 0;
//static float Slide = 0.5 ;
//static BOOL  FLAG;


@interface LGColorlightViewController ()

@end

@implementation LGColorlightViewController{

    NSTimer *timer;
    NSTimer *timerLight;
    NSTimer *timeColorTemp;
    MSColorWheelView  * wheelView ;
    RGB        _rgb;
    
    NSArray * RedPoint;
    NSArray * GreenPoint;
    NSArray * BluenPoint;
    NSArray * orangepoint;
    NSArray * purplePoint;
    NSArray * cyanPoint;
    NSArray * YellowPoint;
//    BOOL _RgbSwState;
    
    NSDate *_oldTime;
    
    
    NSMutableArray *_saveColorArr;
    NSMutableArray *_saveLightArr;
    float tempSlideValue;
    float lightSliderValue;
    float colorSliderValue;
    
    
    //是否是第一次加载
    BOOL isFirst;
    
    
    
    
    
}
#pragma  mark ==== 视图  ====
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //旋律打开
    if ([LGSingleLight shareLight].isOn) {
        self.SW_state.on = YES;
        self.Rgb_SliderValue.enabled = YES;
        //彩灯打开关闭照明
        self.SW_lightAttribute.on = NO;
        self.ColorTempValue.enabled = NO;
    }
    
    //非旋律的其他打开
    if ([LGSingleLight shareLight].colorIsON) {
        self.SW_state.on = YES;
        self.ColorTempValue.enabled = NO;
        self.Rgb_SliderValue.enabled = YES;
        //彩灯打开关闭照明
        self.SW_lightAttribute.on = NO;
    }
    
 
    
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.SW_state.on) {
        [LGSingleLight shareLight].colorIsON = NO;
        
    }
    
    //强退前保存数据
    if(self.SW_state.on){
        self.SW_lightAttribute.on = NO;
        [self saveColorValue];
    }
    if (self.SW_lightAttribute.on) {
        [self saveLightvalue];
    }
    
    

    
    
    
    //保存发送最后一次的数据
    [[NSUserDefaults standardUserDefaults] setObject:_saveColorArr forKey:@"colorArr"];
    [[NSUserDefaults standardUserDefaults] setObject:_saveLightArr forKey:@"lightArr"];
    [[NSUserDefaults standardUserDefaults] setObject:@(tempSlideValue) forKey:@"tempValue"];
    [[NSUserDefaults standardUserDefaults] setObject:@(lightSliderValue) forKey:@"lightValue"];
    [[NSUserDefaults standardUserDefaults] setObject:@(colorSliderValue) forKey:@"colorValue"];

    
    
//    NSLog(@"%@-------------",_saveLightArr);
//    NSLog(@"%@-------------",_saveColorArr);
    
}

#pragma mark -  读取本地音乐库
-(void)loadMediaItemsForMediaType:(MPMediaType)mediaType{
    
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    NSNumber *mediaTypeNumber= [NSNumber numberWithInteger:mediaType];
    
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:mediaTypeNumber forProperty:MPMediaItemPropertyMediaType];
    //根据条件查找到本地的音乐数据
    [query addFilterPredicate:predicate];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //第一次进入界面就询问是否允许本地音乐
    [self loadMediaItemsForMediaType:MPMediaTypeMusic];
    
    
    
    _oldTime = [NSDate date];
    
    
    [self.Rgb_SliderValue addTarget:self action:@selector(Touch) forControlEvents:(UIControlEventValueChanged | UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];

    

    //初始化取色盘
    [self initColorPicker];
    
    UIColor *bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"背景"]];
    self.view.backgroundColor = bgColor;
    [self create];
    
    
    //获取沙盒数据
    [self getPersistMethod];
    
    
    isFirst = YES;
    
    
    
    
    [_ColorTempValue addTarget:self action:@selector(touchend) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

}

-(void)touchend{
    
    if (_ColorTempValue.value == 1) {
         [self adjustColorByteRed:0 Green:0 Blue:0 White:0xff * _Rgb_SliderValue.value Yellow:0];
    }
    
    if (_ColorTempValue.value == 0) {
         [self adjustColorByteRed:0 Green:0 Blue:0 White:0 Yellow:0xff * _Rgb_SliderValue.value];
    }
}






-(void)getPersistMethod{
    
    _saveLightArr = [NSMutableArray array];
    _saveColorArr = [NSMutableArray array];
    [_saveLightArr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"lightArr"]];
    [_saveColorArr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"colorArr"]];
    tempSlideValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tempValue"] floatValue];
    lightSliderValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lightValue"] floatValue];
    colorSliderValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"colorValue"] floatValue];
    
    
    
    //初始化这些值
    if (_saveColorArr.count!=0) {
        redValue = [_saveColorArr[0] intValue];
        greenValue = [_saveColorArr[1] intValue];
        blueValue = [_saveColorArr[2] intValue];
        whiteValue = [_saveColorArr[3] intValue];
        YellowValue = [_saveColorArr[4] intValue];
    }

    
//    NSLog(@"%@!!!!!!!!",_saveLightArr);
//    NSLog(@"%@!!!!!!!!",_saveColorArr);
    
}


-(void)create{
    
    self.navigationController.tabBarItem.selectedImage = [[UIImage imageNamed:@"彩灯-点击"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //底部bar颜色
    self.navigationController.tabBarController.tabBar.tintColor =[UIColor colorWithRed:0/255.0f green:198/255.0f blue:175/255.0f alpha:1];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"导航背景"]forBarMetrics:UIBarMetricsDefault];
    //标题颜色和字体
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
     NSLocalizedString(@"External", nil);
 
}
#pragma mark  =====  取色盘视图  =====
- (void)initColorPicker{

    //int width = screenW*0.7;
    int width=0;
    //CGRect rect = CGRectMake(0.15*screenW, 128, width, width);
    CGRect rect;
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        width = screenW*0.5;

        rect = CGRectMake((screenW-screenW*0.5)/2.0, 110, width, width);
        wheelView = [[MSColorWheelView alloc] initWithFrame:rect];
    }
    
    
    if ([UIScreen mainScreen].bounds.size.height == 667) {
        width = screenW*0.65;
        rect = CGRectMake((screenW-screenW*0.7)/1.74, 120, width, width);
        wheelView = [[MSColorWheelView alloc] initWithFrame:rect];
    }
    if ([UIScreen mainScreen].bounds.size.height == 736) {
        width = screenW*0.7;
        rect = CGRectMake((screenW-screenW*0.8)/1.5, 130, width, width);
        wheelView = [[MSColorWheelView alloc] initWithFrame:rect];
    }
    
    
    [wheelView addTarget:self action:@selector(TouchMove) forControlEvents:UIControlEventValueChanged];
    [wheelView addTarget:self action:@selector(Touch) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];

    
    
    
    UIView *myView = [UIView new];
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        
         width = screenW*0.53;
        myView = [[UIView alloc] initWithFrame:CGRectMake((screenW-screenW*0.5)/2.1-10, 95, width+20, width+20)];
    } else if ([UIScreen mainScreen].bounds.size.height == 667){
          width = screenW*0.7;
        
        myView = [[UIView alloc] initWithFrame:CGRectMake((screenW-screenW*0.72)/2.0-7, 100, width+20, width+20)];
    } else {
        
        width = screenW*0.75;

        myView = [[UIView alloc] initWithFrame:CGRectMake((screenW-screenW*0.8)/2-7, 110, width+20, width+20)];
    }
    
    UIImageView *igView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"色盘底纹"]];
    if ([UIScreen mainScreen].bounds.size.height == 667) {
        igView.frame = CGRectMake(0, 0, width+20, width+20);
    } else if ([UIScreen mainScreen].bounds.size.height == 568){
        
        igView.frame = CGRectMake(0, 0, width+20, width+20);
    } else {
        
        igView.frame = CGRectMake(0, 0, width+20, width+20);
        
    }
    
    [myView addSubview:igView];
    
    [self.view addSubview:myView];

    [self.view addSubview:wheelView];

    
}


#pragma mark =====  取色盘点击方法  =====
- (void)TouchMove {
    
    
    
    if ([_bleManager isConnected]) {
        
    
        
        //点击色盘开启彩灯
        if (!self.SW_state.on && !self.SW_lightAttribute.on) {
            self.SW_state.on = YES;
            self.Rgb_SliderValue.enabled = YES;
            
        }
        
        else if(!self.SW_state.on && self.SW_lightAttribute.on ){
            
            
            //关照明并且存储最后一次发送的数据
            self.SW_lightAttribute.on = NO;
            [self switchLightOff];
            
            
            
            self.SW_state.on = YES;
            self.Rgb_SliderValue.enabled = YES;

        }

       
        [self Touch];
    }
}



-(void)Touch{
    
    if ([_bleManager isConnected]) {
        if (-[_oldTime timeIntervalSinceNow] > 0.08) {
            _oldTime = [NSDate date];
            
            
            if(self.SW_state.on||self.SW_lightAttribute.on){
            
                [self ms_colorDidChangeValue];
            }
        }
        

    }else{
        [_SW_state setOn:NO];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];

    }
    
   
}






//-(void)stopyidong{
//
//    [timerLight invalidate];
//    timerLight = nil;
//
//}
#pragma mark 圆环变化
-(void)ms_colorDidChangeValue{

    if([_bleManager isConnected]){
        
        HSB hsb = { wheelView.hue, 1.0f,1.0f, 1.0f};
        
        RGB rgb = MSHSB2RGB(hsb);
        
//        BOOL Temp1,Temp2,Temp3,Temp4;
//        Temp1 =(BOOL)rgb.red*0xff;
//        Temp2 = (BOOL)rgb.green*0xff;
//        Temp3 = (BOOL)rgb.blue*0xff;
//        Temp4 = (BOOL)rgb.alpha*0xff;
//        
//        NSLog(@"redTemp %lf , greenTemp %lf , blueTemp %lf",rgb.red,rgb.green,rgb.blue);
//      
//            
//            RedTemp =Temp1;
//            GreenTemp =Temp2;
//            BLueTemp =Temp3;
//            WhiterTemp =Temp4;
        
            if (self.SW_state.on) {
                
//                if(FLAG)
//                    whiteValue = 0;
//                else{
//                    whiteValue = Slide*255;
//                }
//                FLAG = FALSE;
                
                
                
 
                CGFloat tempValue = _Rgb_SliderValue.value;
                
                [self adjustColorByteRed:rgb.red*0xff*tempValue Green:rgb.green*0xff*tempValue Blue:rgb.blue*0xff*tempValue White:0 Yellow:0];
                
                
 
            }
        
        
        
        if (self.SW_lightAttribute.on) {
            
            CGFloat tempValue = _Rgb_SliderValue.value;
            int whiteValue = self.ColorTempValue.value *tempValue * 0xff;
            int yellowValue = (1-self.ColorTempValue.value) * tempValue * 0xff;
            [self adjustColorByteRed:0 Green:0 Blue:0 White:whiteValue Yellow:yellowValue];
            
            
        }
        
        
    }

    
    
}


#pragma mark ===改变照明值开关===
- (IBAction)SW_light:(UISwitch *)sender {
    
    

    if ([_bleManager isConnected]) {
        
        if (sender.isOn ) {
            
            [self switchLightON];
            
           
            
        }else{
            
            [self switchLightOff];
            
            
        }
    }else{
    
        [sender setOn:NO];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }

}

-(void)switchLightON{
    
    self.SW_lightAttribute.on = YES;
    
    [_SW_state setOn:NO];
    //关闭彩灯开关
    //保存彩灯的值

    [self saveColorValue];
    
    
//    [self switchOff];
    
    
    _ColorTempValue.enabled=YES;
    self.Rgb_SliderValue.enabled = YES;

    
    //如果最后是彩灯关的则初始化灯
    if (_saveLightArr.count == 0 ) {
        [self adjustColorByteRed:0 Green:0 Blue:0 White:174 Yellow:174];
        self.ColorTempValue.value = 0.5;
        self.Rgb_SliderValue.value = 0.5;
    }
    
    else{
        
        int r = [_saveLightArr[0] intValue];
        int g = [_saveLightArr[1] intValue];
        int b = [_saveLightArr[2] intValue];
        int w = [_saveLightArr[3] intValue];
        int y = [_saveLightArr[4] intValue];
        
        [self adjustColorByteRed:r Green:g Blue:b White:w Yellow:y];
        self.ColorTempValue.value = tempSlideValue;
        self.Rgb_SliderValue.value = lightSliderValue;
    }
    
    
    
}


-(void)switchLightOff{

    self.SW_lightAttribute.on = NO;
    
    
    [self saveLightvalue];
    self.Rgb_SliderValue.enabled = NO;
    self.ColorTempValue.enabled = NO;
    
    
    [self adjustColorByteRed:0 Green:0 Blue:0 White:0 Yellow:0];
    
    
}




#pragma mark ===改变彩灯值开关===
- (IBAction)SW_colorLight:(UISwitch *)sender {
    
    
    
    if([_bleManager isConnected]){
        //连接蓝牙开关
        if (sender.isOn) {
            
            [self switchON];
            _ColorTempValue.enabled=NO;
            [_SW_state setOn:YES];
//            _RgbSwState=YES;
            
            self.Rgb_SliderValue.enabled = YES;
            
        }else {
            
            [self switchOff];
            [_SW_state setOn:NO];
//            _RgbSwState=NO;
            self.Rgb_SliderValue.enabled = NO;
        }
        
    }else{
        
        [sender setOn:NO];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }

}


-(void)switchON{
    
    if (self.SW_lightAttribute.on) {
        [self switchLightOff];
    }
    
    [self.SW_state setOn:YES];
    self.SW_lightAttribute.on = NO;
    

    //如果最后是灯关的则初始化彩灯
    if (_saveColorArr.count == 0 ) {
        [self adjustColorByteRed:174 Green:174 Blue:174  White:0 Yellow:0];
        _Rgb_SliderValue.value =0.5;
        
        
    }else
    {
        
        int r = [_saveColorArr[0] intValue];
        int g = [_saveColorArr[1] intValue];
        int b = [_saveColorArr[2] intValue];
        int w = [_saveColorArr[3] intValue];
        int y = [_saveColorArr[4] intValue];

        RGB rgb = {r,g,b,1.0f};
        HSB hsb = MSRGB2HSB(rgb);
        
        //设置点击位置的数值
        wheelView.hue = hsb.hue;
        //设置点击的位置
//        wheelView.saturation = 0.5;
        
        
        [self adjustColorByteRed:r Green:g Blue:b White:w Yellow:y];
        self.Rgb_SliderValue.value = colorSliderValue;
    }
    
    
    
    
}
-(void)switchOff{
    
    [self saveColorValue];
    [self.SW_state setOn:NO];
    [self adjustColorByteRed:0 Green:0 Blue:0 White:0 Yellow:0];
    
    [LGSingleLight shareLight].isOn = NO;
    
    
    
}


#pragma mark=====   外控开关  =====
- (IBAction)SW_ExternalControl:(UISwitch *)sender {
    [self adjustPeriphral:sender.on];
}



#pragma mark ===== 亮度滑块 =====
- (IBAction)changeRgbValue:(UISlider *)sender {
    
    if (_SW_state.on||_SW_lightAttribute.on) {
        
        [self slideMove];
        

    }
    
    
  
    
}

#pragma mark -  滑块滑动调用
-(void)slideMove{
    
    
    [self Touch];
    
    
}





//- (void)stopWrite:(UISlider *)slider
//{
//    [timer invalidate];
//    timer = nil;
//}

//-(void)write{
//    
//    
//    
//    Byte byte[] = {self.Rgb_SliderValue.value*redValue,self.Rgb_SliderValue.value*greenValue,self.Rgb_SliderValue.value*blueValue,0,0};
//    
//    Slide = self.Rgb_SliderValue.value;
//    NSLog(@"%f",_Rgb_SliderValue.value);
//    NSData * data = [NSData dataWithBytes:byte length:5];
//    NSLog(@"data %@",data);
//    [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.ledCharacteristic andValue:data andResponseWriteType:CBCharacteristicWriteWithResponse];
//
//}
#pragma  mark =====  色温滑块 =====

- (IBAction)slider_changeColorTempValue:(UISlider *)sender {
    
    if (self.SW_lightAttribute.on) {
        [self slideMove];
    }
}













#pragma mark =====  RGB按钮  =====
- (IBAction)white_Btn:(UIButton *)sender {
    if ([_bleManager isConnected]) {
        
//    [self adjustColorByteRed:0 Green:0 Blue:0 White:255 Yellow:0];
        self.SW_lightAttribute.on = YES;
        [self switchLightON];
        
        self.ColorTempValue.value = 1;
        self.Rgb_SliderValue.value = 1;
        [self Touch];
        
        
        
    }else{
         [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    
    }
    
//    isFirstInto=TRUE;
//    
//    //    NSLog(@"%d",);
//    //    _RgbSwState=YES;
//    if([_bleManager isConnected]){
//        
//        [_SW_state setOn:YES];
//        [_SW_lightAttribute setOn:NO];
//        
//        //        _Rgb_SliderValue.value=1;
//        _ColorTempValue.enabled=NO;
//        _Rgb_SliderValue.value = 1;
//        _Rgb_SliderValue.enabled = YES;
//        
//        //        [self adjustColorByteRed:255 Green:0 Blue:0 White:0 Yellow:0];
//        whiteValue =0;
//        //        FLAG =TRUE;
//        
//        //这段代码是点击红色跳转跳到取色盘红色的区域
//        RedPoint =[NSArray arrayWithObject:[UIColor redColor]];
//        _rgb = MSRGBColorComponents([RedPoint objectAtIndex:sender.tag]);
//        HSB hsb = MSRGB2HSB(_rgb);
//        [wheelView setSaturation:hsb.saturation];
//        [wheelView setHue:hsb.hue];
//        
//        [self Touch];
//        
//    } else{
//        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
//    }

}
- (IBAction)yellow_Btn:(UIButton *)sender {
    
    if ([_bleManager isConnected]) {
//        [self adjustColorByteRed:0 Green:0 Blue:0 White:0 Yellow:255];
        
        
        [self switchLightON];
        
        self.ColorTempValue.value = 0;
        self.Rgb_SliderValue.value = 1;
        [self Touch];
        
        
        
        
    }else{
    
     [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    
    }
}
- (IBAction)whiteYellow_Btn:(UIButton *)sender {
    
    if ([_bleManager isConnected]) {
        [self switchLightON];
        self.ColorTempValue.value = 0.5;
        self.Rgb_SliderValue.value = 1;
        [self adjustColorByteRed:0 Green:0 Blue:0 White:255 Yellow:255];
    }else{
    
    
     [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }
}

- (IBAction)nightLamp:(UIButton *)sender {
    
    
    
    if ([_bleManager isConnected]) {
//        [self adjustColorByteRed:0 Green:0 Blue:0 White:2 Yellow:5];
        [self switchLightON];
        
        self.ColorTempValue.value = 0.555556;
        self.Rgb_SliderValue.value = 0.17647;
        [self Touch];
        
        
        
    }else{
    
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }
    
}










- (IBAction)red_Btn:(UIButton *)sender {
    
    //    BLE_Tool *ble =[BLE_Tool alloc];
    isFirstInto=TRUE;
    
    //    NSLog(@"%d",);
    //    _RgbSwState=YES;
    if([_bleManager isConnected]){
        
        [_SW_state setOn:YES];
        [_SW_lightAttribute setOn:NO];
        
        //        _Rgb_SliderValue.value=1;
        _ColorTempValue.enabled=NO;
        _Rgb_SliderValue.value = 1;
        _Rgb_SliderValue.enabled = YES;
        
        //        [self adjustColorByteRed:255 Green:0 Blue:0 White:0 Yellow:0];
        whiteValue =0;
//        FLAG =TRUE;
        
        //这段代码是点击红色跳转跳到取色盘红色的区域
        RedPoint =[NSArray arrayWithObject:[UIColor redColor]];
        _rgb = MSRGBColorComponents([RedPoint objectAtIndex:sender.tag]);
        HSB hsb = MSRGB2HSB(_rgb);
        [wheelView setSaturation:hsb.saturation];
        [wheelView setHue:hsb.hue];
        
        [self Touch];
        
    } else{
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }
    
}
- (IBAction)green_Btn:(UIButton *)sender {
    if([_bleManager isConnected]){
        [_SW_lightAttribute setOn:NO];
        [_SW_state setOn:YES];
        //        [self adjustColorByteRed:0 Green:255 Blue:0 White:0 Yellow:0];
        _ColorTempValue.enabled=NO;
        _Rgb_SliderValue.value = 1;
        _Rgb_SliderValue.enabled = YES;
        whiteValue =0;
        //        FLAG =TRUE;
        //        _Rgb_SliderValue.value=1;
        _ColorTempValue.enabled=NO;
        GreenPoint =[NSArray arrayWithObject:[UIColor greenColor]];
        _rgb = MSRGBColorComponents([GreenPoint objectAtIndex:sender.tag]);
        
        HSB hsb = MSRGB2HSB(_rgb);
        [wheelView setSaturation:hsb.saturation];
        [wheelView setHue:hsb.hue];
        
        [self Touch];
        
    } else{
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }
    
}

- (IBAction)bluen_Btn:(UIButton *)sender {
    if([_bleManager isConnected]){
        [_SW_state setOn:YES];
        [_SW_lightAttribute setOn:NO];
        //        _Rgb_SliderValue.value=1;
        _ColorTempValue.enabled=NO;
        _Rgb_SliderValue.value = 1;
        _Rgb_SliderValue.enabled = YES;
        //        [self adjustColorByteRed:0 Green:0 Blue:255 White:0 Yellow:0];
        whiteValue =0;
        //        FLAG =TRUE;
        
        //这段代码是点击红色跳转跳到取色盘红色的区域
        BluenPoint =[NSArray arrayWithObject:[UIColor blueColor]];
        _rgb = MSRGBColorComponents([BluenPoint objectAtIndex:sender.tag]);
        HSB hsb = MSRGB2HSB(_rgb);
        [wheelView setSaturation:hsb.saturation];
        [wheelView setHue:hsb.hue];
        
        [self Touch];
        
    } else{
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
    }
    
}


//
//
//- (IBAction)orange_Btn:(UIButton *)sender {
//    
//    
//    if([_bleManager isConnected]){
//        [_SW_lightAttribute setOn:NO];
//        [_SW_state setOn:YES];
//        //        _Rgb_SliderValue.value=1;
//        _ColorTempValue.enabled=NO;
//        _Rgb_SliderValue.value = 1;
//        _Rgb_SliderValue.enabled = YES;
//        //        [self adjustColorByteRed:255 Green:165 Blue:0 White:0 Yellow:0];
//        
//        whiteValue =0;
////        FLAG =TRUE;
//        orangepoint =[NSArray arrayWithObject:[UIColor orangeColor]];
//        _rgb = MSRGBColorComponents([orangepoint objectAtIndex:sender.tag]);
//        HSB hsb = MSRGB2HSB(_rgb);
//        [wheelView setSaturation:hsb.saturation];
//        [wheelView setHue:hsb.hue];
//        
//        [self Touch];
//        
//    } else{
//        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
//    }
//}
//
////- (IBAction)yellow_Btn:(UIButton *)sender {
////    
////    
////    if([_bleManager isConnected]){
////        [_SW_state setOn:YES];
////        //        _Rgb_SliderValue.value=1;
////        _ColorTempValue.enabled=NO;
////        [_SW_lightAttribute setOn:NO];
////        _Rgb_SliderValue.value = 1;
////        _Rgb_SliderValue.enabled = YES;
////        //        [self adjustColorByteRed:255 Green:255 Blue:0 White:0 Yellow:0];
////        whiteValue =0;
//////        FLAG =TRUE;
////        
////        YellowPoint =[NSArray arrayWithObject:[UIColor yellowColor]];
////        _rgb = MSRGBColorComponents([YellowPoint objectAtIndex:sender.tag]);
////        HSB hsb = MSRGB2HSB(_rgb);
////        [wheelView setSaturation:hsb.saturation];
////        [wheelView setHue:hsb.hue];
////        
////        [self Touch];
////        
////    } else{
////        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
////    }
////    
////}
//
//
//
//- (IBAction)cyan_Btn:(UIButton *)sender {
//    if([_bleManager isConnected]){
//        //        _Rgb_SliderValue.value=1;
//        [_SW_lightAttribute setOn:NO];
//        [_SW_state setOn:YES];
//        _ColorTempValue.enabled=NO;
//        _Rgb_SliderValue.value = 1;
//        _Rgb_SliderValue.enabled = YES;
//        //        [self adjustColorByteRed:0 Green:255 Blue:255 White:0 Yellow:0];
//        whiteValue =0;
////        FLAG =TRUE;
//        
//        cyanPoint =[NSArray arrayWithObject:[UIColor cyanColor]];
//        _rgb = MSRGBColorComponents([cyanPoint objectAtIndex:sender.tag]);
//        HSB hsb = MSRGB2HSB(_rgb);
//        [wheelView setSaturation:hsb.saturation];
//        [wheelView setHue:hsb.hue];
//        
//        [self Touch];
//    } else{
//        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
//    }
//}
//
//- (IBAction)purple_Btn:(UIButton *)sender {
//    
//    if([_bleManager isConnected]){
//        [_SW_state setOn:YES];
//        [_SW_lightAttribute setOn:NO];
//        //        _Rgb_SliderValue.value=1;
//        _ColorTempValue.enabled=NO;
//        _Rgb_SliderValue.value = 1;
//        _Rgb_SliderValue.enabled = YES;
//        //       [self adjustColorByteRed:160 Green:32 Blue:240 White:0 Yellow:0];
//        whiteValue =0;
////        FLAG =TRUE;
//        
//        //这段代码是点击青色跳转跳到取色盘青色的区域
//        purplePoint =[NSArray arrayWithObject:[UIColor purpleColor]];
//        _rgb = MSRGBColorComponents([purplePoint objectAtIndex:sender.tag]);
//        HSB hsb = MSRGB2HSB(_rgb);
//        [wheelView setSaturation:hsb.saturation];
//        [wheelView setHue:hsb.hue];
//        
//        [self Touch];
//        
//    } else{
//        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
//    }
//    
//    
//}



#pragma mark =====  发送数据  =====
-(void)adjustColorByteRed:(int)red Green:(int)green Blue:(int)blue White:(int)white Yellow:(int)yellow{
    
    
    redValue    = red;
    greenValue  = green;
    blueValue   = blue;
    whiteValue  = white;
    YellowValue = yellow;
    
    Byte bytes[] = {redValue,greenValue,blueValue,YellowValue,whiteValue};
    NSData  * datas =[NSData dataWithBytes:bytes length:5];
    [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.ledCharacteristic andValue:datas andResponseWriteType:CBCharacteristicWriteWithResponse];

    
//    NSLog(@"redValue:%d,greenValue:%d,blueValue:%d,whiteValue:%d,YellowValue:%d",redValue,greenValue,blueValue,whiteValue,YellowValue);
    
   
}


#pragma mark -  保存所有值
-(void)saveColorValue
{
    if (redValue||greenValue||blueValue||whiteValue||YellowValue) {
        //存入rgb的值
        [_saveColorArr removeAllObjects];
        [_saveColorArr addObject:@(redValue)];
        [_saveColorArr addObject:@(greenValue)];
        [_saveColorArr addObject:@(blueValue)];
        [_saveColorArr addObject:@(whiteValue)];
        [_saveColorArr addObject:@(YellowValue)];
        
        //    tempSlideValue = self.ColorTempValue.value;
        colorSliderValue = self.Rgb_SliderValue.value;
    }

}


-(void)saveLightvalue
{
    [_saveLightArr removeAllObjects];
    [_saveLightArr addObject:@(redValue)];
    [_saveLightArr addObject:@(greenValue)];
    [_saveLightArr addObject:@(blueValue)];
    [_saveLightArr addObject:@(whiteValue)];
    [_saveLightArr addObject:@(YellowValue)];
    
    
    tempSlideValue = self.ColorTempValue.value;
    lightSliderValue = self.Rgb_SliderValue.value;
}





#pragma mark -  外设发送数据
-(void)adjustPeriphral:(BOOL)isOn{

    
    NSString *isOpen ;
    if (isOn) {
        isOpen = @"AT#EXON";
    }else{
        isOpen = @"AT#EXOFF";
    
    
    }
    NSData *datas = [isOpen dataUsingEncoding:NSUTF8StringEncoding];
    
    
     [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.ctrlCharacteristic andValue:datas andResponseWriteType:CBCharacteristicWriteWithResponse];



}






//#pragma mark -  监听代理
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
//    //如果被调用的是圆盘
//    if ([object isKindOfClass:[MSColorWheelView class]]) {
//        isSlide = NO;
//    }
//
//
//}



@end
