//
//  LGMusic.m
//  Demo
//
//  Created by 金港 on 16/5/4.
//  Copyright © 2016年 xiankexun. All rights reserved.
//

#import "LGMusic.h"
#import "UIImageView+RotateImgV.h"
#import "PopupView.h"


@interface LGMusic ()

//@property (nonatomic, strong) UILabel *myLabel;

@property (nonatomic,strong)UITableViewCell *cell;

- (void)loadMediaItemsForMediaType:(MPMediaType)mediaType;


#pragma mark - 新增加属性
@property (nonatomic,strong)NSMutableDictionary *mdict;

@property (nonatomic,strong)NSMutableDictionary *peoplemuDict;
@end

@implementation LGMusic
{
    NSArray *_indexArr;
    NSArray *_itemsArr;
    
    PopupView  *popUpView;
}

#pragma mark ---加载数据源---
-(void)loadMediaItemsForMediaType:(MPMediaType)mediaType{
    
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    NSNumber *mediaTypeNumber= [NSNumber numberWithInteger:mediaType];
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:mediaTypeNumber forProperty:MPMediaItemPropertyMediaType];
    //根据条件查找到本地的音乐数据
    [query addFilterPredicate:predicate];
    //两个数组赋值
    mediaItems = [query items];
    showArray=[NSMutableArray arrayWithArray:mediaItems];
    
    [self initIndexArrWithQuery:query];
    
    
    
    
    self.peoplemuDict = [NSMutableDictionary dictionary];
    self.mdict = [NSMutableDictionary dictionary];
   
    NSMutableArray *musicArr = [NSMutableArray array];
    for (int i = 0; i<mediaItems.count; i ++) {
        MPMediaItem *item = mediaItems[i];
        NSString *nameStr = [item valueForProperty:MPMediaItemPropertyTitle];
        //增加作者名
        NSString *peopleStr = [item valueForProperty:MPMediaItemPropertyArtist];
        NSLog(@"peopleStr=%@",peopleStr);
       
        [musicArr addObject:nameStr];
        
        if (peopleStr == nil) {
            
            peopleStr = nameStr;
        }
        

        
    }
    
    


    
    [self.TableView reloadData];
    
    
    
}







- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //隐藏tarItem
    [[UIBarButtonItem appearance]setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)forBarMetrics:UIBarMetricsDefault];
    //初始化显示数组
    showArray = [NSMutableArray array];
    
    //初始化状态下，不需要初始化播放器
    ISChangeMusic=NO;
    
    //后台播放音频设置
    session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    //加上这句 咱外面就不能暂停
    //    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 设置标题，设置导航栏左侧按钮，视图背景色
    
    
    //    [self setupLeftMenuButton];
   
    
    //两个代理不能少
    self.TableView.dataSource=self;
    self.TableView.delegate = self;
    //加载本地音乐数据
    [self loadMediaItemsForMediaType:MPMediaTypeMusic];
    ISSendMusic=YES;
    
    

    [self setUI];

}


#pragma mark -  设置UI
-(void)setUI{

    
    
    //设置导航栏标题
    self.title = NSLocalizedString(@"MusicList", nil);
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //页面背景颜色
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:198/255.0 blue:175/255.0 alpha:1.0f];
    
    self.TableView.backgroundColor = [UIColor colorWithRed:0/255.0 green:198/255.0 blue:175/255.0 alpha:1.0f];
    
    //分割线颜色
    [self.TableView setSeparatorColor:[UIColor whiteColor]];

//    self.myLabel = [[UILabel alloc]initWithFrame:CGRectMake( 0,0, 50, 50)];
//    self.myLabel.center = self.view.center;
//    self.myLabel.backgroundColor = [UIColor redColor];
//    self.myLabel.layer.cornerRadius = self.myLabel.bounds.size.width * 0.5;
//    self.myLabel.layer.masksToBounds = YES;
//    self.myLabel.textAlignment = NSTextAlignmentCenter;
//    self.myLabel.alpha = 0;
//    
//    
//    UIWindow *window = [[UIWindow alloc] init];
//    window = [UIApplication sharedApplication].keyWindow;
//    
//    [self.view addSubview:self.myLabel];
//    [self.view bringSubviewToFront:self.myLabel];
    
    
    
    
    //索引
    self.TableView.sectionIndexColor = [UIColor whiteColor];
    self.TableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.TableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //获取上次播放的歌曲行数
    NSUserDefaults *userDefaults= [NSUserDefaults standardUserDefaults];
    //第一次加载，没有播放歌曲的时候 lastMusicID 是没有有效值的。有的只是一个乱码值
    if ([userDefaults objectForKey:@"lastMusicKey"]) {
        lastMusicIDD=[[userDefaults objectForKey:@"lastMusicKey"] integerValue];
        // 空音乐崩溃问题的地方
       
        
        
        if (lastMusicIDD) {
            lastIndexPath = [NSIndexPath indexPathForRow:lastMusicIDD inSection:0];
            [userDefaults setInteger:lastMusicIDD forKey:@"selectIndexpath.row"];
            
            
             [self.TableView selectRowAtIndexPath:lastIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
       
        
    }
    
    
    
    //滚动到上一次状态
//     NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSInteger selectSection = [userDefault integerForKey:@"selectIndexpath.section"];
//    NSInteger selectRow = [userDefault integerForKey:@"selectIndexpath.row"];
//    //NSLog(@"selectSection=%ld,selectRow=%ld",selectSection,selectRow);
//    
//    NSIndexPath *myindpath=[NSIndexPath indexPathForRow:selectRow inSection:selectSection];
//    
//    if (selectSection > 0 || selectRow > 0) {
//        
//        [self.TableView scrollToRowAtIndexPath:myindpath atScrollPosition:UITableViewScrollPositionNone animated:YES];
//    }
    

}






-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(lastMusicIDD) forKey:@"lastMusicKey"];


}




////点击开始
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self myTouch:touches];
//    
//    
//}
//
//
////点击进行中
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self myTouch:touches];
//}
//
////点击结束
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//
//}
//
////点击回调的方法
//-(void)myTouch:(NSSet *)touches
//{
//
//    //    获取点击的区域
//    UITouch *touch = [touches anyObject];
//    
//
//    
//
//    //    跳到tableview指定的区
//    NSIndexPath *indpath=[NSIndexPath indexPathForRow:0 inSection:index-1];
// 
//    
//   
//  
//    
//    [self.TableView scrollToRowAtIndexPath:indpath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
//    
//}



#pragma mark ---tableView代理---


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return 1;

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return  showArray.count;
    

    
}


//改变行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //
    NSString *cellId = @"CellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId] ;
    
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    
        //实现点击状态保存
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSInteger selectSection = [userDefault integerForKey:@"selectIndexpath.section"];
        NSInteger selectRow = [userDefault integerForKey:@"selectIndexpath.row"];
   

        if (indexPath.section == selectSection && indexPath.row == selectRow) {
            cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"矩形-3"]];
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            
            animation.duration = 0.2; // 动画持续时间
            animation.repeatCount = -1; // 重复次数
            animation.autoreverses = YES; // 动画结束时执行逆动画
            // 缩放倍数
            animation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
            animation.toValue = [NSNumber numberWithFloat:0.9]; // 结束时的倍率
            
            // 添加动画
            
            [self.cell.layer addAnimation:animation forKey:@"scaleAnmation"];
            
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont systemFontOfSize:16];

            
        }
        
        //选中状态Cell
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        
    
    
    
    
    
    //数据源
    NSUInteger row = [indexPath row];
    MPMediaItem *item = [showArray objectAtIndex:row];
    cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
    cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];


    
    return cell;
    
}










#pragma mark - 改变内容

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    lastIndexPath = indexPath;
    lastMusicIDD = indexPath.row;
    [self reSetlastMusicAction];
    
    
    
    
    NSIndexPath *selectIndexpath = [tableView indexPathForSelectedRow];

    //保存点中cell 的下标
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setInteger:selectIndexpath.section forKey:@"selectIndexpath.section"];
    [userDefault setInteger:selectIndexpath.row forKey:@"selectIndexpath.row"];
    
    //这里应该将lastMusicID转成对mediaItems的
    

    
    [self.TableView reloadData];
    
    
    
    
    
//    for (NSInteger i=0; i<mediaItems.count; i++) {
////        if ([mediaItems objectAtIndex:i] == item) {
//            lastMusicIDD = i;
//            
//         //   NSLog(@"重新对应lastMusicID:%ld",i);
//            //这里要将选中的歌曲的依据保存在本地，以便下次进来的时候知道最后点击的是哪首歌曲
//            [[NSUserDefaults standardUserDefaults] setObject:@(lastMusicIDD) forKey:@"lastMusicKey"];
////        }
//    }
    

    
    
}






#pragma mark -  索引代理方法
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return _indexArr;
}




- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    
    MPMediaQuerySection *section = _itemsArr[index];
    
    [self.TableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:section.range.location inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
    [popUpView removeFromSuperview];
    popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
    popUpView.ParentView = self.view;
    
    [popUpView setIndex:section.title];
    
    [self.view addSubview:popUpView];
    
   
    
    
    return section.range.location;
    
    
}











#pragma mark -  初始化索引数组
- (void)initIndexArrWithQuery:(MPMediaQuery *)query {
    
    NSMutableArray *tempArr = [NSMutableArray array];
    for (MPMediaQuerySection *section in query.itemSections) {
        
        [tempArr addObject:section.title];
    }
    
    _indexArr = [tempArr copy];
    _itemsArr = [query.itemSections copy];
}


#pragma mark -  重新设置最后一首歌
-(void)reSetlastMusicAction{
    
    
    MPMediaItem *item = [showArray objectAtIndex:lastIndexPath.row];
    //在这里使用协议传值
    
    [self.delegate didSelectMusic:item];
    
    
    
    
    
    for (int i=0; i<mediaItems.count; i++) {
        if ([mediaItems objectAtIndex:i] == item) {
            lastMusicIDD = i;
            
            NSLog(@"重新对应lastMusicID:%d",i);
            //这里要将选中的歌曲的依据保存在本地，以便下次进来的时候知道最后点击的是哪首歌曲
            [[NSUserDefaults standardUserDefaults] setObject:@(lastMusicIDD) forKey:@"lastMusicKey"];
        }
    }
}

@end
