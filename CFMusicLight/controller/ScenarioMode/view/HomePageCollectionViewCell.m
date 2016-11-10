//
//  HomePageCollectionViewCell.m
//  LiYang
//
//  Created by SuHui on 16/5/17.
//  Copyright © 2016年 lexiangquan. All rights reserved.
//

#import "HomePageCollectionViewCell.h"
#import "LGSingleLight.h"

#import "LGSingleLight.h"


@interface HomePageCollectionViewCell ()

@end

@implementation HomePageCollectionViewCell



- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.isYes = NO;
        self.backgroundColor = [UIColor whiteColor];
        NSLog(@"%lf,%lf",frame.size.width,frame.size.height);
        
        self.ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width / 4.5, frame.size.height / 6, frame.size.width/1.7, frame.size.height/1.7)];
        
        [self.contentView addSubview:self.ImageView];
        //这里要让label居中
        self.ShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height * 2 / 2.5, frame.size.width, frame.size.height / 3)];
        self.ShowLabel.textAlignment = NSTextAlignmentCenter;
        self.ShowLabel.textColor = [UIColor blackColor];
        self.ShowLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.ShowLabel];
        
            
        
        
    }
    
    
    
    return self;
}





-(void)setSelected:(BOOL)selected
{
    
    if (selected) {
        self.ImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"picture%ld",self.tag]];
        self.ShowLabel.textColor = [UIColor  colorWithRed:157/255.0f green:216/255.0f blue:98/255.0f alpha:1];
        
//        if (![LGSingleLight shareLight].isSix) {
//            [self adjustbyte:self.tag];
//        }
        
    }
    
    else
    {
    
        self.ImageView.image = [UIImage imageNamed:[NSString stringWithFormat: @"picture0%ld",self.tag]];
        self.ShowLabel.textColor = [UIColor grayColor];
        
    }
    
    
}







@end
