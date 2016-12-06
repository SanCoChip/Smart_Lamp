//
//  LGMusicPlayViewController.h
//  CFMusicLight
//
//  Created by 金港 on 16/5/13.
//
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "LGMusic.h"
#import "BLE Tool.h"
#import "WebviewVC.h"
#import "OnlineMusicCell.h"
static AVAudioPlayer *player = nil;
#import "LGFMBaseViewController.h"
@interface LGMusicPlayViewController :LGFMBaseViewController <LGMusicDeleagte,UICollectionViewDelegate,UICollectionViewDataSource>//模式选择



@property (weak, nonatomic) IBOutlet UIButton *ModeButton;
@property (weak, nonatomic) IBOutlet UIButton *PlayerButton;


- (IBAction)modleAction:(UIButton*)sender;

- (IBAction)preOneAction:(UIButton*)sender;
- (IBAction)playAction:(UIButton*)sender;
- (IBAction)NextPlayer:(UIButton*)sender;
@property (strong, nonatomic) IBOutlet UIButton *List;

//时间
@property (weak, nonatomic) IBOutlet UILabel *TotalTime;
@property (weak, nonatomic) IBOutlet UILabel *RealTime;
@property (weak, nonatomic) IBOutlet UISlider *SliderPlay;
@property (nonatomic,retain) NSTimer*time;//定时器
@property (nonatomic,strong)NSMutableArray*Table;
//声音
- (IBAction)SliderValue:(UISlider *)sender;
@property(nonatomic,strong)UISlider *slider;
@property (strong, nonatomic) IBOutlet UISlider *changeVolume;
@property (strong, nonatomic) IBOutlet UIImageView *ImageView;
//旋律
- (IBAction)Sw_melody:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UISwitch *Switch_melody;
-(void)adjustbyte:(Byte)value;
@end
