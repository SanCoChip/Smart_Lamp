//
//  LGHomeViewController.m
//  CFMusicLight
//
//  Created by 金港 on 16/6/16.
//
//

#import "LGHomeViewController.h"

#import "ContentCellModel.h"
#import "HomePageCollectionViewCell.h"
#import "MyCollectionLayout.h"
#import "LGSceneModel.h"
#import "SVProgressHUD.h"
#import "SandBox.h"
#import "LGSingleLight.h"
#import "JRBLESDK.h"


#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH  [UIScreen mainScreen].bounds.size.height

//以iphone 6Puls 的屏幕宽度为参考，计算出任意屏幕的10像素
#define widhtFor10 10.0 * [UIScreen mainScreen].bounds.size.width / 414
#define heightFor10  10.0 * [UIScreen mainScreen].bounds.size.height / 736

//item的宽度和高度相等
#define itemW (ScreenW - widhtFor10 * 4) / 3

@interface LGHomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

{

    HomePageCollectionViewCell* cell;
    
    JRBLESDK * _bleManager;
}
@end



@implementation LGHomeViewController


bool flag = FALSE;

#pragma  mark ---懒加载---

- (UICollectionView *)collectionView {
    if(_collectionView == nil) {
        MyCollectionLayout* layout = [[MyCollectionLayout alloc] init];
        //item的列间距是10,航间距是20
        layout.minimumLineSpacing = widhtFor10;
        layout.minimumInteritemSpacing = heightFor10;
        layout.itemSize = CGSizeMake(itemW, itemW);
        //这里我是从导航下面开始算frame的
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0,ScreenW , ScreenH) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        //静止边缘弹跳，连重用都不用考虑了
        _collectionView.bounces = NO;
        //防止
//        _collectionView.scrollEnabled =NO;
        _collectionView.backgroundColor = [UIColor colorWithRed:0/255.0 green:198/255.0 blue:175/255.0 alpha:1.0f];
        
        [self.view addSubview:_collectionView];
        
    }
    return _collectionView;
}









-(NSArray*)dataSource {
    if(_dataSource == nil) {
        _dataSource = [ContentCellModel cellDataSource];
    }
    return _dataSource;
}





#pragma mark ---View生命周期---
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    

    
    if ([LGSingleLight shareLight].isOn) {
        
        [_collectionView reloadData];
    }
    
    
    
    
    
    
    
    
    if (![_bleManager isConnected]) {
        
        _collectionView.userInteractionEnabled = NO;
        [_collectionView reloadData];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Bluetooth not connected", nil)];
        
        
    }else{
    
        _collectionView.userInteractionEnabled = YES;
    
    }

}



- (void)viewDidLoad {
    
    
    _bleManager = [JRBLESDK getSDKToolInstance];
    
    
    imageLabel = [[NSMutableArray alloc]init];
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    //注册cell并同时调用懒加载
    [self.collectionView registerClass:[HomePageCollectionViewCell class] forCellWithReuseIdentifier:@"homePageCell"];
    
    //标题颜色和字体
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"导航背景"]forBarMetrics:UIBarMetricsDefault];
    
    
    //添加监听
    [[LGSingleLight shareLight] addObserver:self forKeyPath:NSStringFromSelector(@selector(isOn)) options:NSKeyValueObservingOptionNew context:nil];
    [[LGSingleLight shareLight] addObserver:self forKeyPath:NSStringFromSelector(@selector(colorIsON)) options:NSKeyValueObservingOptionNew context:nil];
    
}

#pragma mark ---collectionView代理---




-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    

    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"homePageCell" forIndexPath:indexPath];
    ContentCellModel* model = self.dataSource[indexPath.row];

    cell.tag = indexPath.row;
    cell.ShowLabel.text = model.title;//（如果文字也要变化的话就把文字放到下面这两个判断中）
    cell.ShowLabel.font = [UIFont systemFontOfSize:15];
    cell.layer.cornerRadius =10;
    cell.backgroundColor =[UIColor clearColor];
    
    cell.ImageView.image = model.onImage;
    cell.ShowLabel.textColor = [UIColor grayColor];
    
    
    
    
    
    
    if([LGSingleLight shareLight].isOn)
    {
        
        [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:6 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionBottom];
    }
    
    else{
        
        [_collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:6 inSection:0] animated:YES];
        
       
        
    }
    
    

    
    return cell;
    

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    

    
    [LGSingleLight shareLight].colorIsON = YES;
    
    if (indexPath.row == 6) {
        [LGSingleLight shareLight].isOn = YES;
//        NSLog(@"-----%d",[LGSingleLight shareLight].isOn);

    }
    
    
    else
    {
        [LGSingleLight shareLight].isOn = NO;
//        NSLog(@"-----%d",[LGSingleLight shareLight].isOn);
        
    }
    
    
    
    
    [self adjustbyte:indexPath.row];
    
    
    
    

}






- (void)adjustbyte:(Byte)value1
{
    //声明一个字符串
    NSString *str = [NSString stringWithFormat:@"BLMD"];
    //转成Data
    [str dataUsingEncoding:NSUTF8StringEncoding];
    
    //声明一个Byte
    Byte bytee [] = {value1};
    //转成Data
    NSData *data =[NSData dataWithBytes:bytee length:1];
    
    //声明一个可变Data
    NSMutableData *mutableData = [NSMutableData alloc];
    //两个Data合并
    [mutableData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [mutableData appendData: data];
    
    [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.ledCharacteristic andValue:mutableData andResponseWriteType:CBCharacteristicWriteWithResponse];
    
    
}





#pragma mark -  监听代理
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(isOn))]) {
        
        BOOL ison = [change[NSKeyValueChangeNewKey] boolValue];
        
//        NSLog(@"%d",ison);
        //获取指定cell对象
        UICollectionViewCell *tempCell = [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
        tempCell.selected  = ison;
        
        
    }else if([keyPath isEqualToString:NSStringFromSelector(@selector(colorIsON))]){
    
        BOOL isOn = [change[NSKeyValueChangeNewKey] boolValue];
        if (!isOn) {
            
            [_collectionView reloadData];
        }
    }
    
    

}



//移除监听
-(void)dealloc{

    
    [[LGSingleLight shareLight] removeObserver:self forKeyPath:NSStringFromSelector(@selector(isOn))];
    [[LGSingleLight shareLight] removeObserver:self forKeyPath:NSStringFromSelector(@selector(colorIsON))];
    
    
}

@end
