//
//  ContentCellModel.m
//  testDemo
//
//
//  Copyright © 2016年 SIBAT. All rights reserved.
//

#import "ContentCellModel.h"

@implementation ContentCellModel



+(NSArray*)cellDataSource
{
     // NSLocalizedString(<#key#>, <#comment#>)
    /*
     1.填写 对应得语言单词
     2，nil
     */
//    
//    NSArray* array = @[NSLocalizedString(@"Switch", nil),NSLocalizedString(@"Rainbow", nil),NSLocalizedString(@"Heartbeat", nil),NSLocalizedString(@"Candlelight", nil), NSLocalizedString(@"Marquee", nil),NSLocalizedString(@"Stage", nil),NSLocalizedString(@"Escape", nil),NSLocalizedString(@"SlowFlash", nil),NSLocalizedString(@"Melody", nil),NSLocalizedString(@"Random", nil),NSLocalizedString(@"Breathing", nil),NSLocalizedString(@"Magic", nil),NSLocalizedString(@"WarmBloom", nil),NSLocalizedString(@"BluesElves", nil),NSLocalizedString(@"GreenMood", nil),NSLocalizedString(@"HappyRhythm", nil),NSLocalizedString(@"Rotate", nil),NSLocalizedString(@"Red", nil),NSLocalizedString(@"Green", nil),NSLocalizedString(@"Blue", nil)];
     NSArray* array = @[@"夜灯",@"彩虹",@"心跳",@"跑马",@"快闪",@"慢闪",@"旋律",@"随机",@"三色轮转",@"红色渐变",@"绿色渐变",@"蓝色渐变"];
    
    NSMutableArray* mutableArray = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        ContentCellModel* model = [[ContentCellModel alloc] init];
        model.title = array[i];
        
        //这里的图片的命名一定要与数组的顺序一致，我这里就用两张普通的图片了
        model.onImage = [UIImage imageNamed:[NSString stringWithFormat: @"picture0%d",i]];
        model.openImage = [UIImage imageNamed:[NSString stringWithFormat:@"picture%d",i]];
        
        
        [mutableArray addObject:model];
    }
    return [mutableArray copy];
   }

@end
