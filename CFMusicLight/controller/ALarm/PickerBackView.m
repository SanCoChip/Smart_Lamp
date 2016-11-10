//
//  PickerBackView.m
//  BaseProject
//
//  Created by iOS开发本-(梁乾) on 16/4/28.
//  Copyright © 2016年 tarena. All rights reserved.
//

#import "PickerBackView.h"

@implementation PickerBackView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//这里重写touchesBegan是为了让点击了PickerBackVIew后消失，如果不要这个功能注释掉即可

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    //BackView消失
    self.hidden = YES;
}

@end
