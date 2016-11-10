
//  LGMusic.h
//  Demo
//
//  Created by 金港 on 16/5/4.
//  Copyright © 2016年 xiankexun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@protocol LGMusicDeleagte <NSObject>
/**
 *  用户在表格中选择了歌曲后通过此方法将选中的歌曲传递回播放控制器界面。需要先遵循LGMusicDeleagte协议
 *
 *  @param item 选中的歌曲
 */
-(void)didSelectMusic:(MPMediaItem*)item;

@end

@interface LGMusic : UIViewController<AVAudioPlayerDelegate,UITableViewDelegate,UITableViewDataSource>{
    AVAudioSession *session;
    
    NSArray *mediaItems;
    NSMutableArray *showArray;//显示到表视图上的数据
    NSURL *urlOfSong;
    NSInteger modleNumber;//模型数
    
    //    BOOL HaveMusic;//本地播放库有没有音乐，有音乐为YES，没有音乐为NO。
    NSInteger lastMusicIDD;//内存中保存的最后一次播放的音乐ID
    NSIndexPath *lastIndexPath;//最后选择的行,刷新界面的依据
    BOOL ISChangeMusic;//是否重新初始化播放器.YES需要重新初始化播放器，NO不需要
    BOOL ISSendMusic;
    


    
}

@property (weak, nonatomic) IBOutlet UITableView *TableView;
@property (nonatomic, weak) id<LGMusicDeleagte> delegate;//代理
@property (nonatomic,weak)UIImageView *image;






@end
