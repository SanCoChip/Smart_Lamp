
//
//  LGDeviceTableViewController.m
//  CFMusicLight
//
//  Created by 金港 on 16/7/26.
//
//

#import "LGDeviceTableViewController.h"
#import "JRBLESDK.h"
#import "UIImageView+RotateImgV.h"
#import "LGAlarmViewController.h"
#import "SVProgressHUD.h"
#import "PopupView.h"
#import "Masonry.h"
#import <AVFoundation/AVFoundation.h>
#define ScreenW [UIScreen mainScreen].bounds.size.width

//可以输入字符的长度
static NSInteger CharacterCount = 21;


@interface LGDeviceTableViewController ()<UIAlertViewDelegate,UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UILabel *totalCharacterLabel;



@property(nonatomic)  JRBLESDK * bleManager;

@property (nonatomic,weak)NSTimer *timer;

@property (nonatomic,strong)UIButton *editBtn;

@property (nonatomic,strong)UITableViewCell*cell;

@property (nonatomic,weak) UITextField* textField;

@property (nonatomic,weak)UIImage *connected_show_image;

@property (nonatomic,assign)NSInteger didSelectedRow;

//localName
@property(nonatomic, retain)  NSMutableArray * bleDeviceNames;


@end

@implementation LGDeviceTableViewController
{
    PopupView  *popUpView;
    UIView *_isConnectBack;
    UIActivityIndicatorView *_isConnectView;
    NSString *_oldName;
    CBPeripheral *_changePeripheral;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.tabBarItem.selectedImage = [[UIImage imageNamed:@"蓝牙-点击"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"导航背景"]forBarMetrics:UIBarMetricsDefault];
    
    
    [self initBLE_ENV];
    self.Device_list.delegate=self;
    self.Device_list.dataSource=self;
    
    
    
    //设置背景和分割线
    //    self.Device_list.backgroundColor = [UIColor colorWithRed:40/255.0 green:62/255.0 blue:77/255.0 alpha:1];
    self.Device_list.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"搜索蓝牙背景"]];
    [self.Device_list setSeparatorColor:[UIColor whiteColor]];
    
    _Device_list.layer.borderWidth=10;
    _Device_list.layer.borderColor =[UIColor clearColor].CGColor;
    _Device_list.layer.cornerRadius =25;
    [self.view addSubview:_Device_list];
    
    [self Roundedbtn];
    
    //这是初始化通知
    [self addBLEObserver];
    
    
    //标题颜色和字体
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self imageAddGestureRecognizer];
    
    
    
}



//#warning change
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [_bleManager.bleTool stopDiscover];
    //退出还原
//    [_bleManager.bleTool setfirstinto:FALSE];
}

-(void)viewWillAppear:(BOOL)animated{
    
    //如果没连接则自动搜索
    if (![_bleManager isConnected]) {
         [_bleManager.bleTool startDiscoverWithServices:nil andOptions:nil];
    }
   
    
//    if([_bleManager isConnected]){
//        
//        [_bleManager.bleTool startDiscoverWithServices:nil andOptions:nil];
//        [_bleManager.bleTool setfirstinto:TRUE];
//        [_ImageBG rotate360DegreeWithImageView:5];
//        [self SearchTime:_timer];
//
//    }
    
}












#pragma mark -  旋转按钮添加点击事件
-(void)imageAddGestureRecognizer{

    
    
    
    UITapGestureRecognizer *imgGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Btn:)];
    
    _ImageBG.userInteractionEnabled = YES;
    [_ImageBG addGestureRecognizer:imgGesture];
    
    
    


}



-(void)Roundedbtn{
    
    
    [_btn_Image_Bg.layer setMasksToBounds:YES];
    //    _btn_Image_Bg .layer.cornerRadius=10;
    [_btn_Image_Bg.layer setCornerRadius:30.5];
    [self.view addSubview:_btn_Image_Bg];
}


-(void)SearchTime :(NSTimer *)timer{
    
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
        
    }
    
    
}

-(void)timeChange{
    
    [_ImageBG stopRotate];
    [_bleManager.bleTool stopDiscover];
    
    [_timer invalidate];
    _ImageBG.hidden = YES;
    self.btn_Image_Bg.hidden = NO;
}








#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    
    return [_bleDevices count];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString * CELL_ID = @"deviceCellID";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    _cell= [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    
    if (!self.cell) {
     self.cell = [[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
        
    }
    self.cell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cell.backgroundColor = [UIColor clearColor];
    //    cell.detailTextLabel.text =NSLocalizedString(@"ClickConnectionBLE", nil);
    self.cell.detailTextLabel.textColor =[UIColor  colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1];
    
    
    self.cell.detailTextLabel.font =[UIFont systemFontOfSize:15];
    
    

//    self.cell.imageView.hidden = YES;
    
    
    
    return  self.cell;
}




- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CBPeripheral * peripheral = [_bleDevices objectAtIndex:[indexPath row]];
    
//    NSMutableArray *mArr =[NSMutableArray arrayWithObjects:peripheral.name, nil];
//    [_deviceName addObject:mArr];
    
//    for (int i = 0; i < [_bleDevices count] ; i++) {
//        CBPeripheral * peripheral=[_bleDevices objectAtIndex:i];
//        [_deviceName addObject: peripheral.name];
//        NSLog(@"设备名affafafaa。。。。。。。..............。。。。。%@",[_deviceName objectAtIndex:i]);
//    }
//    [_deviceName addObject:  peripheral.name];
    
//    for (int i = 0; i < [_deviceName count] ; i++) {
//        CBPeripheral * peripheral=[_bleDevices objectAtIndex:i];
//        [_deviceName addObject: peripheral.name];
//        NSLog(@"设备名。。。。。。。..............。。。。。%@",[_deviceName objectAtIndex:[indexPath row]]);
//    }
    
//    NSLog(@"设备名。。。。。。。..............。。。。。%@",_bleDevices);
    //    _deviceName
    
    self.cell.textLabel.textColor =[UIColor whiteColor];
    self.cell.textLabel.text= [_bleDeviceNames objectAtIndex:[indexPath row]];

//    self.cell.textLabel.text = [_deviceName objectAtIndex:[indexPath row]];
    

    if (peripheral.state == CBPeripheralStateConnected) {
        
        [_ImageBG stopRotate];
//        [self SenderSystemTime:_Systemtimer];
        
        //钩钩图片
        self.connected_show_image=[UIImage imageNamed:@"选中"];
        self.cell.imageView.image = self.connected_show_image;

        
        
        
        //编辑图片
        self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.editBtn.frame = CGRectMake(200.0f, 0.0f, 44.0f, 44.0f);

//            self.editBtn.backgroundColor =[UIColor whiteColor];
//        [self.editBtn setTitle:nil forState:UIControlStateNormal];
        [self.editBtn addTarget:self action:@selector(onClick3:) forControlEvents:UIControlEventTouchUpInside];
        [self. editBtn setImage:[UIImage imageNamed:@"重命名"] forState:UIControlStateNormal];
//        self.editBtn.hidden=NO;
       
        [self.cell addSubview:self.editBtn];

        
        //适配
        [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self.cell.mas_right).with.offset(-20);
            make.top.equalTo(self.cell).with.offset(0);
            make.height.equalTo(self.cell.mas_height);
            make.width.equalTo(self.cell.mas_height);
            
        }];
        
        
        
        
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth Is Connected", nil)];
        
        
    }else {
        
        self.connected_show_image=[UIImage imageNamed:@""];
        self.cell.imageView.image=self.connected_show_image;
//        [self.editBtn removeFromSuperview];
        
    }
    
    
    
    //让分割线顶头
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) [cell setSeparatorInset:UIEdgeInsetsZero];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])[cell setLayoutMargins:UIEdgeInsetsZero];
    

}








-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    CBPeripheral * peripheral = [_bleDevices objectAtIndex:[indexPath row]];
    
    //保存连接的peripheral
    _changePeripheral = peripheral;
    
    //旋转图片和按钮
    self.btn_Image_Bg.hidden = NO;
    self.ImageBG.hidden = YES;
    
   
    if (peripheral.state != CBPeripheralStateConnected && (!_bleManager.peripheral)) {
        
        if (self.editBtn) {
            [self.editBtn removeFromSuperview];
        }
        
        
        //增加小菊花
        [self isConnectingPeripheral];
        
        [_bleManager.bleTool connectPeripheral:peripheral andOptions:nil];
        [_bleManager.bleTool stopDiscover];
        
        
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.cell = cell;
        _didSelectedRow = indexPath.row;
        
        
        
        if (Deviece_Version >= 10) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@NO} completionHandler:nil];
        }else{
        
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }

    

       
        
        

    }else{
        

        
        
        
        [self disConnectAlertView];
        
        

        
        

        
    }
    
    
}






/**
 
 *  tableView线条顶到头的方法
 
 */

-(void)viewDidLayoutSubviews

{
    
    if ([_Device_list respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [_Device_list setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
        
    }
    
    
    
    if ([_Device_list respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [_Device_list setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
        
    }
    
}





#pragma mark -  正在连接
-(void)isConnectingPeripheral{
    
    
    //底
    _isConnectBack = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _isConnectBack.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1f];
    //菊花
    _isConnectView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _isConnectView.frame = CGRectMake(_isConnectBack.bounds.size.width/2, _isConnectBack.bounds.size.height/2, 0, 0);
    [_isConnectView startAnimating];
 
    
    [_isConnectBack addSubview:_isConnectView];
    [self.view addSubview:_isConnectBack];

 
 
}



//获取到正在连接外设的通知
-(void)isConnectPeripheralNotification:(NSNotification*)notification{
    
    
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(connectTimeOut:) userInfo:notification.object repeats:NO];
}


//连接超时
-(void)connectTimeOut:(NSTimer *)timer{
    
    CBPeripheral *peripheral =(CBPeripheral *)[timer userInfo];
    
    if (_isConnectView && _isConnectBack) {
        
        [_isConnectView removeFromSuperview];
        [_isConnectBack removeFromSuperview];
        _isConnectView = nil;
        _isConnectBack = nil;
        
        [_bleManager.bleTool disconnectWithPeripheral:peripheral];
        //重新搜索
//        [self Btn:nil];
        
        

        [self setPopUpView:@"连接超时"];
    }
    

    
}




#pragma mark -  弹出提示
-(void)setPopUpView:(NSString *)title
{

    [popUpView removeFromSuperview];
    popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
    popUpView.ParentView = self.view;
    [popUpView setWarning:title];
    [self.view addSubview:popUpView];


}




#pragma mark ====  弹出按钮点击时间 ====
-(void)onClick3:(UIButton*)button{
    
//    NSLog(@"点击了一下");
    
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改蓝牙名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    //添加textfield
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"登陆";
        
        
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        
        
//        textField.text=_bleManager.peripheral.name;
        
        textField.delegate = self;
        
        
        
        [textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        
        
    }];
    
    
    
    
    
    UIAlertAction *commitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        /**
         *  这里面可以做一些与服务器端交互的事情
         */
//        NSLog(@"%@\n", alertController.textFields.firstObject.text);

//        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
//        self.cell.textLabel.text=_bleManager.peripheral.name;
        #pragma ==== 暂时取消====
//            [_deviceName replaceObjectAtIndex:_numberRor withObject:alertController.textFields.firstObject.text]; // 指定位置替换掉
        
        //存储修改前的名字
        UITableViewCell *cell = [self.Device_list cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_didSelectedRow inSection:0]];
        _oldName = cell.textLabel.text;
        
        
        
        
        if (alertController.textFields.count!=0) {
        
        
            
//              = alertController.textFields.firstObject.text;
        
            
            
            //发送修改名字
            [self adjustChangedWithName:alertController.textFields.firstObject.text];
            
        
            
            
           
            [self changingName];
        }
       
        
        
    }];
//    commitAction.enabled = NO;
    
    
    
    
    
    
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"用户取消了登陆");
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }];
    
    
    
    
    
    /**
     *  添加交互按钮
     */
    [alertController addAction:cancleAction];
    [alertController addAction:commitAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];


}





#pragma mark -  取消连接
-(void)disConnectAlertView{


    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"断开连接" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *commitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self disconnectWithBlueTooth];
  
        [self.editBtn removeFromSuperview];

        [_Device_list reloadData];
        
        
        
    }];
    
    
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];

    
    
    
    [alertController addAction:cancelAction];
    [alertController addAction:commitAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}





























#pragma mark -  修改名字菊花
-(void)changingName{
    
//    //底
    _isConnectBack = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _isConnectBack.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1f];
    //菊花
    _isConnectView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _isConnectView.frame = CGRectMake(_isConnectBack.bounds.size.width/2, _isConnectBack.bounds.size.height/2, 0, 0);
    [_isConnectView startAnimating];
    
    
    [_isConnectBack addSubview:_isConnectView];
    [self.view addSubview:_isConnectBack];

    
    


    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(changingNameSuccess) userInfo:nil repeats:NO];



}



-(void)changingNameSuccess{

    [_bleManager.bleTool startDiscoverWithServices:nil andOptions:nil];
    [_bleDevices removeAllObjects];
    [_bleDeviceNames removeAllObjects];
//    [self Btn:self.btn_Image_Bg];
    
    
    [self.Device_list reloadData];
    
    //删除菊花
    [_isConnectView removeFromSuperview];
    [_isConnectBack removeFromSuperview];
   

//    [popUpView removeFromSuperview];
//    popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
//    popUpView.ParentView = self.view;
//    [popUpView setWarning:@"修改成功"];
//    [self.view addSubview:popUpView];
    
  

}



#pragma mark -  重连
-(void)retrievePeriperal{
    
//    [_bleManager.bleTool connectPeripheral:_changePeripheral andOptions:nil];

}









#pragma mark -  textfield监听和代理方法
//监听正在输入的内容
- (void)textFieldChanged:(UITextField *)textField {

    NSString *toBeString = textField.text;
    
    if (![self isInputRuleAndBlank:toBeString]) {
        textField.text = [self disable_emoji:toBeString];
        return;
    }
    NSString *lang = [[textField textInputMode] primaryLanguage]; // 获取当前键盘输入模式
    
    //简体中文输入,第三方输入法（搜狗）所有模式下都会显示“zh-Hans”
    if([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            NSString *getStr = [self getSubString:toBeString];
            if(getStr && getStr.length > 0) {
                textField.text = getStr;
            }
        }
        
        
    } else{
        NSString *getStr = [self getSubString:toBeString];
        if(getStr && getStr.length > 0) {
            textField.text= getStr;
        }
    }


}



//判断输入框输入的是否符合否则不允许输入
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self isInputRuleNotBlank:string] || [string isEqualToString:@""]) {//当输入符合规则和退格键时允许改变输入框
        return YES;
    }
    else {
        NSLog(@"超出字数限制");
        return NO;
    }
}




#pragma mark - 过滤方法


//第三方的键盘判断是否有特殊字符
//➋➌➍➎➏➐➑➒系统九宫格输入
- (BOOL)isInputRuleNotBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d➋➌➍➎➏➐➑➒]*$";
//    NSString *pattern = @"[`~!@#$%^&*+=|{}':;',\\[\\].<>~！@#￥%……&*（）+|{}【】‘；：”“’。，、？-_()-""]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    
    
    
    if (!isMatch) {
        [popUpView removeFromSuperview];
        popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
        popUpView.ParentView = self.view;
        [popUpView setWarning:@"请勿输入非法字符"];
        [self.view addSubview:popUpView];
    }
    return isMatch;
    
}

//系统键盘拼音输入中间有空格，用这个方法判断是否有特殊字符
- (BOOL)isInputRuleAndBlank:(NSString *)str {
    
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$";
//    NSString *pattern = @"[`~!@#$%^&*+=|{}':;',\\[\\].<>~！@#￥%……&*（）+|{}【】‘；：”“’。，、？-_()-""]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        [popUpView removeFromSuperview];
        popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
        popUpView.ParentView = self.view;
        [popUpView setWarning:@"请勿输入非法字符"];
        [self.view addSubview:popUpView];
    }
    return isMatch;
    
}



//禁用emoji表情
- (NSString *)disable_emoji:(NSString *)text {
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}



//限制长度
-(NSString *)getSubString:(NSString*)string
{
    /// 第一种:三个字节一个中文
//        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSInteger length = [data length];
    
        if (length > CharacterCount) {
            NSData *data1 = [data subdataWithRange:NSMakeRange(0, CharacterCount)];
            NSString *content = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];//注意：当截取CharacterCount长度字符时把中文字符截断返回的content会是nil
            
            //当把中文的三个字节中间某个截断了的时候就抛弃
            if (!content || content.length == 0) {
                
                data1 = [data subdataWithRange:NSMakeRange(0, CharacterCount - 1)];
                content =  [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
                
                if (!content || content.length == 0) {
                    data1 = [data subdataWithRange:NSMakeRange(0, CharacterCount - 2)];
                    content =  [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
                }
            }
            
            
            [popUpView removeFromSuperview];
            popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
            popUpView.ParentView = self.view;
            [popUpView setWarning:@"输入过长"];
            [self.view addSubview:popUpView];
            return content;
        }
        return nil;
    
    
    
    
    
    /// 第二种:按照个数进行判断
//    if (string.length > CharacterCount) {
//        NSLog(@"超出字数上限");
//        _totalCharacterLabel.text = @"0";
//        return [string substringToIndex:CharacterCount];
//    }else {
//        _totalCharacterLabel.text = [NSString stringWithFormat:@"%ld",(long)(CharacterCount - string.length)];
//    }
//    return nil;
}









#pragma mark -  BLE SDK Notification
-(void)addBLEObserver{
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSearchPeripheralNotification:) name:BLESearchPeripheralNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectPeripheralNotification:) name:BLEConnectPeripheralNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectFailedPeripheralNotification:) name:BLEConnectFailPeripheralNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectFailedPeripheralNotification:) name:BLEDisconnectPeripheralNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDicoverServicelNotification:) name:BLEDiscoverServiceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDicoverCharacteristicsNotification:) name:BLEDiscoverCharacteristicNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didConnectFailedPeripheralNotification:) name:BLEUpdateStateNotification object:nil];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendValueToCharacteristic:) name:BLEDiscoverCharacteristicNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isConnectPeripheralNotification:) name:BLEIsConnectingNotification object:nil];
    
    
    

    
}
















//调用通知方法
- (void)didSearchPeripheralNotification:(NSNotification*)notification
{
    
    NSDictionary *dict = notification.userInfo;
    CBPeripheral * peripheral = (CBPeripheral *)[dict objectForKey:@"peripheral"];
    NSString *localName = (NSString *)[dict objectForKey:@"localName"];
    NSLog(@"%s\n %@ \n %d,%ld",__FUNCTION__,peripheral,[_bleDevices containsObject:peripheral],(unsigned long)[_bleDevices count]);
    
    
    
    if ([localName isEqualToString:_oldName]) {
        return;
    }
    
    
    //此处可以让搜索到的设备顺序不会乱保持第一次搜索到的样子
    for (CBPeripheral *searchedPeripheral in _bleDevices) {
        
        if ([searchedPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            
            return;
        }
    }
    
    //改名重连
    if (peripheral == _changePeripheral) {
        [self retrievePeriperal];
    }
    
    [_bleDevices addObject:peripheral];
    [_bleDeviceNames addObject:localName];
    [self.Device_list reloadData];
    
    
 
}

- (void)didConnectPeripheralNotification:(NSNotification*)notification
{
    
    NSDictionary *dict = notification.userInfo;
    NSLog(@"%s\n %@",__FUNCTION__,dict);
    CBPeripheral * peripheral = ( CBPeripheral *)[dict objectForKey:@"peripheral"];
    _bleManager.peripheral = peripheral;
    [_bleManager.bleTool discoverServicesWithPeripheral:peripheral andArray:nil];
    
    
    //连接成功删除菊花
    if (_isConnectBack && _isConnectView) {
        [_isConnectView removeFromSuperview];
        [_isConnectBack removeFromSuperview];
        _isConnectView = nil;
        _isConnectBack = nil;
        
        }

    
    
    [self.Device_list reloadData];
}


- (void)didDicoverServicelNotification:(NSNotification*)notification
{
    
    NSDictionary *dict = notification.userInfo;
    CBPeripheral * peripheral = ( CBPeripheral *)[dict objectForKey:@"peripheral"];
    
    
    if (peripheral != _bleManager.peripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    NSArray	* services  = [peripheral services];
    if (!services || ![services count]) {
        return ;
    }
    
    for (CBService *service in services) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kBLEServiceUUIDString]]) {
            _bleManager.service = service;
            [_bleManager.bleTool discoverCharacteristicsWithPeripheral:peripheral andConditionalArray:nil andService:service];
            break;
        }
    }
}

- (void)didDicoverCharacteristicsNotification:(NSNotification*)notification
{
    
    NSDictionary *dict = notification.userInfo;
    CBPeripheral * peripheral = ( CBPeripheral *)[dict objectForKey:@"peripheral"];
    CBService * service = ( CBService *)[dict objectForKey:@"service"];
    
    if (peripheral != _bleManager.peripheral) {
        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (service != _bleManager.service) {
        NSLog(@"Wrong Service.\n");
        return ;
    }
    
    NSArray		*characteristics	= [ service characteristics];
    CBCharacteristic *characteristic = nil;
    
    for (characteristic in characteristics) {
        NSLog(@"discovered characteristic %@", [characteristic UUID]);
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kBLECTRL_UUIDString]]) {
            NSLog(@"Discovered BLE Ctrl Characteristic");
            
            _bleManager.ctrlCharacteristic = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kBLEACK_UUIDString]]) {
            NSLog(@"Discovered BLE Acknowledge Characteristic");
            
            _bleManager.ackCharacteristic = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
        }
        else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kLEDCTRL_UUIDString]]) {
            NSLog(@"Discovered LED Ctrl Characteristic");
            
            _bleManager.ledCharacteristic = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            //            [characteristic.value.bytes ];
            
            
            
        }
        else if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kVOLUME_UUIDString]]) {
            NSLog(@"Discovered Temperature Characteristic");
            
            _bleManager.volumeCharacteristic = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            
        } else if([[characteristic UUID]isEqual:[CBUUID UUIDWithString:kFM_UUIDString]]){
            NSLog(@"Discovered FM Discovered");
            
            _bleManager.fmCharacteristic = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            
        }else if([[characteristic UUID]isEqual:[CBUUID UUIDWithString:KBLESD_UUIDString]]){
            
            _bleManager.musicCharacteristic=characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            
        }else  if ([[characteristic UUID]isEqual:[CBUUID UUIDWithString:KBLEALARM_UUIDString]]){
            
            _bleManager .alarmCharacteristics = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }else if([[characteristic UUID]isEqual:[CBUUID UUIDWithString:KBLECHANGENAME_UUIDString]]){
            
            _bleManager.changeNameCharacteristics = characteristic;
            [peripheral readValueForCharacteristic:characteristic];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }

    }
    
}


#pragma mark -  连接断开
- (void)didConnectFailedPeripheralNotification:(NSNotification*)notification
{
    
    
    
//    if (![_bleManager isConnected]) {
    

        //连接断开后隐藏图片
        [self.editBtn removeFromSuperview];
        self.cell.imageView.image =[UIImage imageNamed:@""];
        
    
//    }1
    
    NSDictionary *dict = notification.userInfo;
    
    
    
    CBPeripheral * peripheral = ( CBPeripheral *)[dict objectForKey:@"peripheral"];
    if (peripheral == _bleManager.peripheral) {
        _bleManager.peripheral = nil;
        
        [self.Device_list reloadData];
        return ;
    }
    
    
    
    
    
    
}




-(void)disconnectWithBlueTooth {
    
    [_bleManager.bleTool disconnectWithPeripheral:_bleManager.peripheral];
    //    [self setBlueToothPower:FALSE];
    
}


-(void)initBLE_ENV{
    _bleManager = [JRBLESDK getSDKToolInstance];
    _bleDevices = [[NSMutableArray alloc]init];
    _bleDeviceNames = [NSMutableArray array];
    
    //    _deviceName =[[NSMutableArray alloc]init];
}











#pragma mark -  连接完成后发送数据
-(void)sendValueToCharacteristic:(NSNotification *)notification{
    

    BOOL automaticLampIsOn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LampIsOn"] boolValue];
    
    BOOL automaticPlayIsOn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PlayIsOn"] boolValue];
    
    BOOL alarmIsOn_1 = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Alarm1"] boolValue];
    
    BOOL alarmIsOn_2= [[[NSUserDefaults standardUserDefaults] objectForKey:@"Alarm2"] boolValue];

    
    dispatch_async(dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL), ^{
        
        //发送同步时间数据
        [self sendSystemTimer];
        [NSThread sleepForTimeInterval:0.1];
        
        
       
        if (automaticLampIsOn) {
            
            NSString *lightOpenTime = [[NSUserDefaults standardUserDefaults] stringForKey:@"lightopenTime"];
            NSString *lightCloseTime = [[NSUserDefaults standardUserDefaults] stringForKey:@"lightcloseTime"];
            
            
            
            
            [self sendCharacterialRecvieLightTimeWithDateString:lightOpenTime withCloseStr:lightCloseTime];
            [NSThread sleepForTimeInterval:0.1];
        }
        
        
        if (automaticPlayIsOn) {
            NSString *playOpenTime = [[NSUserDefaults standardUserDefaults] stringForKey:@"playopenTime"];
            NSString *playCloseTime = [[NSUserDefaults standardUserDefaults] stringForKey:@"playcloseTime"];
            
            [self sendCharacterialRecviePlayTimeWithDateString:playOpenTime withCloseStr:playCloseTime];
            [NSThread sleepForTimeInterval:0.1];
        }
        
        
        if (alarmIsOn_1) {
            
            NSString *alarmTime = [[NSUserDefaults standardUserDefaults] stringForKey:@"dateStr"];
            
            [self sendCharacterialRecvieOpenTimeWithDateString:alarmTime];
            [NSThread sleepForTimeInterval:0.1];
        }
        
        
        
        
        if (alarmIsOn_2) {
            
            NSString *alarmTime = [[NSUserDefaults standardUserDefaults] stringForKey:@"CanceldateStr"];
            
            [self sendCharacterialRecvieOpenTimeWithDateString:alarmTime];
            
            
            
            [NSThread sleepForTimeInterval:0.1];
        }
        
 
        
    });







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












#pragma mark -  搜索按钮点击事件
- (IBAction)Btn:(UIButton *)sender {
    
    if ([_bleManager isConnected]) {
        _ImageBG.hidden = YES;
        self.btn_Image_Bg.hidden = NO;
        [_ImageBG stopRotate];
        [_bleManager.bleTool stopDiscover];
        
        
        [self setPopUpView:@"蓝牙设备已连接"];
        
        
    }else{
        
        _ImageBG.hidden = NO;
        self.btn_Image_Bg.hidden = YES;
        [_bleDevices removeAllObjects];
        [_bleDeviceNames removeAllObjects];
        [self.Device_list reloadData];
        
        [_ImageBG rotate360DegreeWithImageView:5];
        
        
        [_bleManager.bleTool startDiscoverWithServices:nil andOptions:nil];
        [self SearchTime:_timer];
        [self.Device_list reloadData];
        
    }


}





























#pragma 封装 设置自动灯光的时间

-(void)sendCharacterialRecvieLightTimeWithDateString:(NSString*)openDateStr     withCloseStr:(NSString*)CloseDateStr{
    
    
    
    if([openDateStr isEqualToString:NSLocalizedString(@"AddTime", nil)]){
        openDateStr = @"99:99";
    }
    
    if ([CloseDateStr isEqualToString:NSLocalizedString(@"AddTime", nil)]) {
        CloseDateStr = @"99:99";
    }
    
    
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
    
    [self setAlarmClockTimeWithType:1 Switch:1 PowerOn:0 OpenHour:hour OpenMin:minute CloseHour:hourPLayClose CloseMin:minutePLayClose];
    
}




#pragma mark -音乐播放 下发指令设置时间
-(void)sendCharacterialRecviePlayTimeWithDateString:(NSString*)openDateStr     withCloseStr:(NSString*)CloseDateStr{
    
    
    if([openDateStr isEqualToString:NSLocalizedString(@"AddTime", nil)]){
        openDateStr = @"99:99";
    }
    
    if ([CloseDateStr isEqualToString:NSLocalizedString(@"AddTime", nil)]) {
        CloseDateStr = @"99:99";
    }
    
    
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
    
    
    
    
    
    [self setAlarmClockTimeWithType:2 Switch:1 PowerOn:0 OpenHour:hour OpenMin:minute CloseHour:hourPLayClose CloseMin:minutePLayClose];
    
}





#pragma mark -封装发送时间 设置打开闹钟

-(void)sendCharacterialRecvieOpenTimeWithDateString:(NSString*)datestr{
    
    
    if([datestr isEqualToString:NSLocalizedString(@"AddTime", nil)]){
        datestr = @"99:99";
    }

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
    
    
    
    [self setAlarmClockTimeWithType:4 Switch:1 PowerOn:0 OpenHour:hour OpenMin:minute CloseHour:99 CloseMin:99];
    
    
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




#pragma mark -  发送改名字数据
-(void)adjustChangedWithName:(NSString *)name{
    
    
//    NSString *strLength = [NSString stringWithFormat:@"%ld",[name length]];
//    NSMutableData *mutableData = [NSMutableData new];
//
//    [mutableData appendData:[strLength dataUsingEncoding:NSUTF8StringEncoding]];
//    [mutableData appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
//    NSMutableData *mutableData = [NSMutableData new];
//    [mutableData appendData:[name dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    
    NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
    [self subpackageSendData:nameData withPackageLength:14];

    
    
    
}


#pragma mark -  分包发送
//packageLength包可以处理的字节数
-(void)subpackageSendData:(NSData *)nameData withPackageLength:(NSInteger)packageLength
{
    //包数
    int packageCount = 1;
    
    
    //最后包数
    Byte lastBytes[] = {0xff};
    NSData *lastPackData = [NSData dataWithBytes:lastBytes length:1];
    
    //不是尾包的数据长度：14
    Byte lengthBytes[] = {0x0e};
    NSData *lengthData = [NSData dataWithBytes:lengthBytes length:1];
    
    
    
    for (int i=0; i<nameData.length; i+=packageLength ) {
        
        
        if (i+packageLength < nameData.length) {
            
            NSString *rangeStr = [NSString stringWithFormat:@"%d,%ld",i,packageLength];
            
            NSData *subData = [nameData subdataWithRange:NSRangeFromString(rangeStr)];
            
            
            NSMutableData *totalData = [NSMutableData new];

            
            
            [totalData appendData:lengthData];
            [totalData appendData:[NSData dataWithBytes:&packageCount length:1]];
            [totalData appendData:subData];
            
            
            [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.changeNameCharacteristics andValue:totalData andResponseWriteType:CBCharacteristicWriteWithResponse];
            
            
            packageCount++;
            
            usleep(100 * 1000);
            
            
        }else{
        
            NSString *rangeStr = [NSString stringWithFormat:@"%d,%ld",i,nameData.length-i];
            NSData *subData = [nameData subdataWithRange:NSRangeFromString(rangeStr)];
            
            
            NSMutableData *totalData = [NSMutableData new];
//            NSString * dataLength = [NSString stringWithFormat:@"%ld",nameData.length+2];
            //包长度
            int length =(int)nameData.length - i;
            
            [totalData appendData:[NSData dataWithBytes:&length length:1]];
            [totalData appendData:lastPackData];
            [totalData appendData:subData];
            
            
            [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.changeNameCharacteristics andValue:totalData andResponseWriteType:CBCharacteristicWriteWithResponse];
            
            usleep(100 * 1000);
        
        }
        
        
        
     
    }
    
    
    
    
    

    
    
    
//    [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.ctrlCharacteristic andValue:mutableData andResponseWriteType:CBCharacteristicWriteWithResponse];
    
    
}



@end
