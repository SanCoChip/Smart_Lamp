//
//  LGMusicPlayViewController.m
//  CFMusicLight
//
//  Created by 金港 on 16/5/13.
//
//

#import "LGMusicPlayViewController.h"
#import "PopupView.h"
#import "UIImageView+RotateImgV.h"
#import "LGMusic.h"
#import "SVProgressHUD.h"
#import "LGColorlightViewController.h"
#import "SandBox.h"
#import "LGHomeViewController.h"
#import "HomePageCollectionViewCell.h"
#import "ContentCellModel.h"
#import "SandBox.h"
#import "LGSingleLight.h"
#import "QQMusciVC.h"
#import "baiduMusicVC.h"

//#import "LGOnlineVC.h"

@interface LGMusicPlayViewController () <AVAudioPlayerDelegate,UIWebViewDelegate> {
    
    AVAudioSession *session;
    NSArray *mediaItems;
    NSMutableArray *showArray;//显示到表视图上的数据
    
    NSURL *urlOfSong;
    NSInteger modleNumber;//模型数
    
    BOOL HaveMusic;//本地播放库有没有音乐，有音乐为YES，没有音乐为NO。
    NSInteger lastMusicID;//内存中保存的最后一次播放的音乐ID
    NSIndexPath *lastIndexPath;//最后选择的行,刷新界面的依据
    BOOL ISChangeMusic;//是否重新初始化播放器.YES需要重新初始化播放器，NO不需要
    
    //    NSTimer *timer;
    BOOL ISSendMusic;
    BOOL StPy;
    
    //判断是不是跳到歌曲列表
    BOOL isPush;
    
}




@property (nonatomic, strong) MPMediaItem *item;//歌曲
@property (nonatomic,strong)UISlider *volumviewslider;
@property (weak, nonatomic) IBOutlet UILabel *musicName;
//@property (weak, nonatomic) IBOutlet UIImageView *ImageView;

//播放顶部
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playTopLayout;



- (void)loadMediaItemsForMediaType:(MPMediaType)mediaType;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *OnlineMusicview;


@end
@implementation LGMusicPlayViewController
@synthesize SliderPlay;
@synthesize time;

//@synthesize changeVolume;

-(void)initLayout{
    if ([UIScreen mainScreen].bounds.size.height==568) {
         self.playTopLayout.constant = 10;
    }
   
    if ([UIScreen mainScreen].bounds.size.height==667) {
        self.playTopLayout.constant = 30;
    }

    if ([UIScreen mainScreen].bounds.size.height == 736) {
        self.playTopLayout.constant = 45;
    }

   
}




#pragma mark ---加载数据源---

- (MPMediaItem *)item {
    if(_item == nil) {
        _item = [[MPMediaItem alloc] init];
    }
    return _item;
}



-(void)loadMediaItemsForMediaType:(MPMediaType)mediaType{
    
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    NSNumber *mediaTypeNumber= [NSNumber numberWithInteger:mediaType];
    
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:mediaTypeNumber forProperty:MPMediaItemPropertyMediaType];
    //根据条件查找到本地的音乐数据
    [query addFilterPredicate:predicate];
    
    //两个数组赋值
    mediaItems = [query items];
    showArray=[NSMutableArray arrayWithArray:mediaItems];
    
}


#pragma mark -  判断本地音乐是否崩溃


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    
    //判断是不是本地音乐被改变了
    if (mediaItems.count!=showArray.count) {
        showArray=[NSMutableArray arrayWithArray:mediaItems];
        lastIndexPath=[NSIndexPath indexPathForItem:lastMusicID inSection:0];
        lastMusicID = 0;
        
    }
    
    
    
    
    
    
    if (!isPush) {
    switch (modleNumber) {
            //列表
        case 0:
//            if(lastIndexPath.row!=[showArray count]-1){
                [self NextPlayer:nil];
//            }else{
//                [self StopAction];
//            }
            break;
            //单曲
        case 1:
            [self playAction:nil];
            break;
            //随机
        case 2:
            [self NextPlayer:nil];
            break;
        default:
            //
            break;
    }
    }
    
}




-(void)StopAction{
    
    
    [_ImageView stopRotate];
    [player stop];
    [_PlayerButton setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
//    lastIndexPath=nil;//暂停时lastIndexPath=nil界面不会显示
    //
    //    [timer invalidate];
    
    
}
//当播放器遇到中断的时候（如来电），调用该方法
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)Myplayer{
    //    NSLog(@"打断");
    [self pauseAction:nil];
    
}
//中断事件结束后调用下面的方法
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    
    [self playAction:nil];
    
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
    
    
    
    
    NSLog(@"error:%@",error);
}
- (BOOL) canBecomeFirstResponder
{
    return YES;
}
// 最后定义 remoteControlReceivedWithEvent，处理具体的播放、暂停、前进、后退等具体事件
- (void) remoteControlReceivedWithEvent:(UIEvent *)event
{
    [super remoteControlReceivedWithEvent:event];
    if(event.type == UIEventTypeRemoteControl)
    {
        switch (event.subtype) {
                //点击了播放
            case UIEventSubtypeRemoteControlPlay:
                [self playAction:nil];
                break;
                //点击了暂停
            case UIEventSubtypeRemoteControlPause:
                [self pauseAction:nil];
                break;
                //点击了下一首
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"Next");
                [self NextPlayer:nil];
                break;
                //点击了上一曲
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"Previous");
                [self preOneAction:nil];
                break;
            default:
                break;
        }
    }
}

#pragma mark ---View生命周期---



-(void)viewDidAppear:(BOOL)animated{
    
    if([_bleManager isConnected]){
        NSString  *startseach = [NSString stringWithFormat:@"AT#BTBW"];
        
        [startseach dataUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [startseach dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",data);
        [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.ctrlCharacteristic andValue:data andResponseWriteType:CBCharacteristicWriteWithResponse];
        
        
        
        NSString  *startseach1 = [NSString stringWithFormat:@"AT#CSBW"];
        
        [startseach1 dataUsingEncoding:NSUTF8StringEncoding];
        NSData *data1 = [startseach dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",data1);
        [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.ctrlCharacteristic andValue:data1 andResponseWriteType:CBCharacteristicWriteWithResponse];
        
    }
    
    
    
    if (player.playing) {
        [_ImageView rotate360DegreeWithImageView:1.0];
    }
    
   
    
    

    
}




-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    isPush = YES;
    
    
    //视图将要消失时保存当前正在播放的ID，以便下次继续播放
    NSUserDefaults *userDefaults= [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:lastMusicID forKey:@"lastMusicKey"];
    
    [LGSingleLight shareLight].isOn = self.Switch_melody.on;
    
 

}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    isPush = NO;
    
    
//    NSString *state = [[NSUserDefaults standardUserDefaults] objectForKey:@"state"];
    
    self.Switch_melody.on =[LGSingleLight shareLight].isOn;
    if (![LGSingleLight shareLight].colorIsON) {
        self.Switch_melody.on = NO;
    }

   
    //获取上次播放的歌曲行数
    NSUserDefaults *userDefaults= [NSUserDefaults standardUserDefaults];
    //第一次加载，没有播放歌曲的时候 lastMusicID 是没有有效值的。有的只是一个乱码值
    lastMusicID=[[userDefaults objectForKey:@"lastMusicKey"] integerValue];
    //添加滑块和定时器的联动,这里一定要加非空判断，不然定时器立马就启用了
    
    [SliderPlay addTarget:self action:@selector(processChanged) forControlEvents:UIControlEventValueChanged];
    //启用定时更新的方法
    
    if (time) {
        [time invalidate];
        time = nil;
    }
    time = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateSliderValue) userInfo:nil repeats:YES];
    
    
    
    if (lastMusicID) {
        lastIndexPath=[NSIndexPath indexPathForItem:lastMusicID inSection:0];
    }else{
        
        lastIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    
    
    
    
    
    
    //判断是否在播放
    if (player.playing) {
        [_PlayerButton setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
        
        
    }else{
        
        [_PlayerButton setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    }
    
    

    //每次都读取本地音乐库
    [self loadMediaItemsForMediaType:MPMediaTypeMusic];
//    [self audioPlayerDidFinishPlaying:player successfully:NO];
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    QQMusciVC*qq =[QQMusciVC new];
    //分段控制
    [self segmented:self.segmentedControl];
    
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
     [self.Switch_melody addTarget:self action:@selector(click) forControlEvents:UIControlEventValueChanged];
    [self initLayout];
    //导航栏按钮颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    
    //标题颜色和字体
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"导航背景"]forBarMetrics:UIBarMetricsDefault];
    
    //页面背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:198/255.0 blue:175/255.0 alpha:1.0f];
    self.navigationItem.title = NSLocalizedString(@"蓝牙播放", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [[UIBarButtonItem appearance]setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)forBarMetrics:UIBarMetricsDefault];
    
     
    
    //title居中
    NSArray *vcArr = [self.navigationController viewControllers];
    NSInteger index = [vcArr indexOfObject:self]-1;
    
    if (index >= 0) {
        UIViewController *vc = [vcArr objectAtIndex:index];
        vc.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    //初始化显示数组
    showArray = [NSMutableArray array];
    //初始化状态下，不需要初始化播放器
    ISChangeMusic=NO;
    
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    // 设置标题，设置导航栏左侧按钮，视图背景色
//    self.title = NSLocalizedStringFromTable(@"MUSICPAGE", @"Localizable", nil);
    //    [self setupLeftMenuButton];
    //
 //    加载本地音乐数据
    [self loadMediaItemsForMediaType:MPMediaTypeMusic];
    //后台播放 音频设置
    session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    ISSendMusic=YES;

    
    //如果没有本地音乐，默认加载一首音乐
    if([mediaItems count]==0){
        HaveMusic=NO;
        
        //[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No local Music", nil)];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"No local Music", nil)];
    }else{
        HaveMusic=YES;

    }
    
    
    
    
    
    //添加监听
    [self addObserver];
    
//    //初始化模式
//    if (!modleNumber) {
//        modleNumber = 0;
//    }
//    
    [self initVolume];
    
    
}





-(void)initVolume{


    

    float volume = [[NSUserDefaults standardUserDefaults] floatForKey:@"volume"];
    
    
    if (volume) {
        self.changeVolume.value = volume;
    }else{
        self.changeVolume.value = 5;
    
    
    }
    




}


#pragma mark -  添加监听
-(void)addObserver{

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectFailedPeripheralNotification:) name:BLEConnectFailPeripheralNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectFailedPeripheralNotification:) name:BLEDisconnectPeripheralNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didConnectFailedPeripheralNotification:) name:BLEUpdateStateNotification object:nil];
    
    
    
    //监听A2DP拔插
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangedCallBack:) name:AVAudioSessionRouteChangeNotification object:nil];

}


#pragma mark -  监听A2DP连接断开事件
-(void)audioRouteChangedCallBack:(NSNotification *)notification{
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            
//            NSLog(@"耳机插入");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            [self pauseAction:nil];
//            NSLog(@"耳机拔出，停止播放操作");
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // 即将播放监听
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
    
    
}




#pragma  mark ==== 旋律sw监听方法  ====
-(void)click{

//    [SandBox saveBox:@"state" withState:self.Switch_melody.on];
    

}

#pragma mark ---slider和定时器联动---
-(void)processChanged
{
    [player setCurrentTime:SliderPlay.value*player.duration];
    
}

-(void)updateSliderValue
{
    self.RealTime.text = [NSString stringWithFormat:@"%02ld:%02ld",((NSInteger)player.currentTime / 60) ,((NSInteger)player.currentTime % 60)];
    //设置目前时间的颜色
    self.RealTime.textColor = [UIColor blackColor];
    
    SliderPlay.value = player.currentTime/player.duration;
    
    
    
    
}

-(void)reSetlastMusicAction{
    
    MPMediaItem *item = [showArray objectAtIndex:lastIndexPath.row];
    for (int i=0; i<mediaItems.count; i++) {
        if ([mediaItems objectAtIndex:i] == item) {
            lastMusicID = i;
            //            NSLog(@"重新对应lastMusicID:%d",i);
        }
    }
    
}



#pragma mark - 播放器事件
- (IBAction)modleAction:(id)sender {
    
    
    if (modleNumber<2) {
        modleNumber++;
    }else{
        modleNumber=0;
    }
    //弹出变换的提示
    PopupView  *popUpView;
    popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 240, 0, 0)];
    popUpView.ParentView = self.view;
    switch (modleNumber) {
//        case 0:
//            [_ModeButton setImage:[UIImage imageNamed:@"004"] forState:UIControlStateNormal];
//            [popUpView setText: NSLocalizedStringFromTable(@"顺序播放", @"Localizable", nil)];
//            break;
        case 0:
            [_ModeButton setImage:[UIImage imageNamed:@"列表循环"] forState:UIControlStateNormal];
            [popUpView setText: NSLocalizedStringFromTable(@"列表循环", @"Localizable", nil)];
//              [player setNumberOfLoops:1000000];
            break;
        case 1:
            [_ModeButton setImage:[UIImage imageNamed:@"单曲循环"] forState:UIControlStateNormal];
            [popUpView setText:NSLocalizedStringFromTable(@"单曲循环", @"Localizable", nil)];
            
            break;
        case 2:
            [_ModeButton setImage:[UIImage imageNamed:@"随机播放"] forState:UIControlStateNormal];
            [popUpView setText: NSLocalizedStringFromTable(@"随机播放", @"Localizable", nil)];
            break;
        default:
            break;
    }
    [self.view addSubview:popUpView];
    
}
//暂停播放
- (void)pauseAction:(id)sender {
    
    [_ImageView stopRotate];
    [player stop];
    //[player pause]; //暂停播放
    [_PlayerButton setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    lastIndexPath=nil;//暂停时lastIndexPath=nil界面不会显示
    self.PlayerButton.selected = NO;
    
    //    [_musicTableView reloadData];
    //    [timer invalidate];
    
    
}

//停止播放
-(void)stopAction{
    [player stop];
    [_PlayerButton setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
    lastIndexPath=nil;//暂停时lastIndexPath=nil界面不会显示
//        [_musicTableView reloadData];
    //    [timer invalidate];
    
}

//上一曲
- (IBAction)preOneAction:(UIButton *)sender {
    if (mediaItems.count!=showArray.count) {
        showArray=[NSMutableArray arrayWithArray:mediaItems];
        lastIndexPath=[NSIndexPath indexPathForItem:lastMusicID inSection:0];
    }
    ISChangeMusic=YES;
    NSInteger oldRow;
    if(modleNumber==2){
        oldRow = (int) (arc4random() % ([showArray count]));
    }else if (!lastIndexPath) {
        if(showArray.count==0)return;
        oldRow= 0;
    }else if(lastIndexPath.row==0){
        oldRow = [showArray count]-1;
    }else if(lastIndexPath.row>0){
        oldRow = [lastIndexPath row]-1;
    }
    lastIndexPath=[NSIndexPath indexPathForRow:oldRow inSection:0];
    lastMusicID=oldRow;
    
    [self playAction:nil];
    ISChangeMusic=NO;


}
//播放
- (IBAction)playAction:(UIButton*)sender {
    
    
    
    
    //如果是点击界面按钮
//    sender.selected=!sender.selected;
    if (sender.selected) {
        //暂停
        [_ImageView stopRotate];
        sender.selected=!sender.selected;
        [self pauseAction:nil];
    }else{
        
        //播放
        [_ImageView rotate360DegreeWithImageView:1.0];
        [_PlayerButton setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
        _PlayerButton.selected=YES;
        
        
        
        if (ISChangeMusic==NO&&player!=nil&&urlOfSong!=nil) {
            //            NSLog(@"继续播放");
            //如果有播放记录不需要重新初始化
            
            if (!lastMusicID) {
                lastMusicID = 0;
                
            }
            
            
            [player play]; //播放音乐
            
            //            [timer invalidate];
            
        }else{
            NSError *error;
            //重新初始化播放器URL
            if (HaveMusic) {
                //如果有本地音乐，播放音乐
                if (lastMusicID > mediaItems.count) {
                    lastMusicID = 0;
                }
                
                
                
                
                urlOfSong=[[mediaItems objectAtIndex:lastMusicID] valueForProperty:MPMediaItemPropertyAssetURL];
                player=[[AVAudioPlayer alloc]initWithContentsOfURL:urlOfSong error:&error];
            }else{
                //                NSLog(@"没有本地音乐");
              
            }
            
            if (!player) {
                return;
            }
            [player setDelegate:self];
            [player prepareToPlay];
            player.meteringEnabled=YES;
            [player play]; //播放音乐
            //            [timer invalidate];
//                        timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMeter) userInfo:nil repeats:YES];
        }
        if (!lastIndexPath) {
            lastIndexPath=[NSIndexPath indexPathForRow:lastMusicID inSection:0];
        }
        self.musicName.text = [NSString stringWithFormat:@"%@-%@",[[mediaItems objectAtIndex:lastMusicID] valueForProperty:MPMediaItemPropertyTitle],[[mediaItems objectAtIndex:lastMusicID] valueForKey:MPMediaItemPropertyArtist]];
        
        //设置总时间
        self.TotalTime.text = [NSString stringWithFormat:@"%02ld:%02ld",((NSInteger)player.duration / 60) ,((NSInteger)player.duration % 60)];
    //设置总时间颜色
        self.TotalTime.textColor = [UIColor blackColor];
    }
    

}
//下一首
- (IBAction)NextPlayer:(id)sender {
    if (mediaItems.count!=showArray.count) {
        showArray=[NSMutableArray arrayWithArray:mediaItems];
        lastIndexPath=[NSIndexPath indexPathForItem:lastMusicID inSection:0];
    }
    ISChangeMusic=YES;
    NSLog(@"下一首");
    NSInteger oldRow;
    if(modleNumber==2){
        oldRow = (int) (arc4random() % ([showArray count]));
    }else if (!lastIndexPath) {
        if(showArray.count==0)return;
        oldRow= 0;
    }else if(lastIndexPath.row==[showArray count]-1){
        oldRow = 0;
    }else if(lastIndexPath.row>=0){
        oldRow = [lastIndexPath row]+1;
    }
    
    NSLog(@"oldRow:%ld",(long)oldRow);
    lastIndexPath=[NSIndexPath indexPathForRow:oldRow inSection:0];
    lastMusicID=oldRow;
    [self playAction:nil];
    
    ISChangeMusic=NO;

}
#pragma mark ---截获目录控制器---
//设置LGMusic的代理,因为是从xib上获取的，而你又是直接通过xib拖线的方式推出的界面，所以比较麻烦点，要先获得跳转控制器的实例。
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //1.sender   这个参数是谁触发跳转动作的主体，一般是button  或其他的
    //2.segue    这个参数是在故事版中的跳转到的那条线
    //3.DisplayViewController 是显示界面，也就是目标VC
    //4.destinationViewController  是捕获的目标VC的引用
    
    
    
    if ([segue.identifier isEqualToString:@"musicVCSegue"]||[segue.identifier isEqualToString:@"baiduVCSegue"]||[segue.identifier isEqualToString:@"HimalayasVCSegue"]||[segue.identifier isEqualToString:@"CoolDogMusicVCSegue"]||[segue.identifier isEqualToString:@"RadioVCSegue"]||[segue.identifier isEqualToString:@"ChildrenEducationVCVCSegue"]) {
        
    }else{
    
        LGMusic* vc = segue.destinationViewController;
        //设代理
        vc.delegate = self;
        
        NSUserDefaults *userDefaults= [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:lastMusicID forKey:@"lastMusicKey"];
    }
    
   
    
    
    
    
    
    
    
}

#pragma mark ---LGMusic代理---
-(void)didSelectMusic:(MPMediaItem *)item
{
    self.item = item;
    self.musicName.text = [NSString stringWithFormat:@"%@-%@",[item valueForProperty:MPMediaItemPropertyTitle],[item valueForKey:MPMediaItemPropertyArtist]];
    //设置歌曲颜色
    self.musicName.textColor = [UIColor whiteColor];
    
    //播放音乐
    urlOfSong = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSError *error = nil;
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:urlOfSong error:&error];
     [_PlayerButton setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
    
    //设置总时间
    self.TotalTime.text = [NSString stringWithFormat:@"%02ld:%02ld",((NSInteger)player.duration / 60) ,((NSInteger)player.duration % 60)];
    
    player.currentTime = 00.00;
    
    

    
    [player setDelegate:self];
    [player prepareToPlay];
    player.meteringEnabled=YES;
    [player play];
//    self.play.selected =YES;
    self.PlayerButton.selected = YES;
    [_ImageView rotate360DegreeWithImageView:1.0];
    
}

#pragma mark -  音量滑竿
- (IBAction)SliderValue:(id)sender {
   
    float value= _changeVolume.value;
    player.volume=value;
    
    
    //同步系统音量
    MPMusicPlayerController*mpc = [MPMusicPlayerController applicationMusicPlayer];
    [mpc setVolume:value/10];
    
    
    
    
    
    NSUserDefaults *userDefalut = [NSUserDefaults standardUserDefaults];
    [userDefalut setFloat:value forKey:@"volume"];
    [userDefalut synchronize];
 
}


//外设音量不足时候调用该方法
//-(void)volume{
//    
//    NSInteger a = self.changeVolume.value*15;
//    
//    //保存a 再次启动App时 音量和滑竿同步
//    NSUserDefaults *userDefalut = [NSUserDefaults standardUserDefaults];
//    [userDefalut setInteger:a forKey:@"volume"];
//    [userDefalut synchronize];
//    
//    NSLog(@"音量大小：a=%ld",a);
//    Byte bytes[] = {a};
//    
//    //    [NSData dataWithBytes:bytes length:1];
//    NSData *data = [NSData dataWithBytes:bytes length:1];
//    [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.volumeCharacteristic andValue:data andResponseWriteType:CBCharacteristicWriteWithResponse];
//}







#pragma  mark ==== 旋律  ====

- (IBAction)Sw_melody:(UISwitch *)sender {
    
    if (sender.on) {
        [self adjustbyte:6];
        [LGSingleLight shareLight].isOn = YES;
        [LGSingleLight shareLight].colorIsON = YES;
    }else
    {
        [self adjustbyte:12];
        [LGSingleLight shareLight].isOn = NO;
    }
}

- (void)adjustbyte:(Byte)value
{
    //声明一个字符串
    NSString *str = [NSString stringWithFormat:@"BLMD"];
    //转成Data
    [str dataUsingEncoding:NSUTF8StringEncoding];
    
    //声明一个Byte
    Byte bytee [] = {value};
    //转成Data
    NSData *data =[NSData dataWithBytes:bytee length:1];
    
    //声明一个可变Data
    NSMutableData *mutableData = [NSMutableData alloc];
    //两个Data合并
    [mutableData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [mutableData appendData: data];
    
    [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.ledCharacteristic andValue:mutableData andResponseWriteType:CBCharacteristicWriteWithResponse];

}




//- (IBAction)pushList:(UIButton *)sender {

    
//    NSUserDefaults *userDefaults= [NSUserDefaults standardUserDefaults];
//    [userDefaults setInteger:lastMusicID forKey:@"lastMusicKey"];
    
    
//}








#pragma mark -  断开蓝牙连接
-(void)didConnectFailedPeripheralNotification:(NSNotification *)notification
{
    
    [self pauseAction:nil];
    
}
- (IBAction)segmented:(UISegmentedControl *)sender {
    
     NSInteger selectedIndex = sender.selectedSegmentIndex;
    
    switch (selectedIndex) {
        case 0:
            self.OnlineMusicview.hidden=YES;
            
            NSLog(@"点击了0");
            
            break;
            
        case 1:{

            self.OnlineMusicview.hidden=NO;
        
            NSLog(@"点击了1");
            break;
        
        }
        default:
            break;
    }
    
    
}




@end


