//
//  UIImageView+RotateImgV.m
//  RotateImgV
//
//  Created by Ashen on 15/11/10.
//  Copyright © 2015年 Ashen. All rights reserved.
//

#import "UIImageView+RotateImgV.h"




@implementation UIImageView (RotateImgV)

- (void)rotate360DegreeWithImageView :(CGFloat)speed {
    
    
    
    CABasicAnimation *rotationAnimation = (CABasicAnimation *)[self.layer animationForKey:@"rotationAnimation"];
 
    CFTimeInterval pause = self.layer.timeOffset;
    self.layer.speed = 1.0f;
    self.layer.timeOffset = 0.0f;
    self.layer.beginTime = 0.0f;
    CFTimeInterval timeSincePauseTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pause;
    self.layer.beginTime = timeSincePauseTime;
    
    if (rotationAnimation) {
        
    }
    else {

        rotationAnimation= [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 10/speed;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = MAXFLOAT;
        
        //不允许动画从渲染树中删除，否则程序中断会被删除
        rotationAnimation.removedOnCompletion = NO;
        //当动画结束后,layer会一直保持着动画最后的状态
        rotationAnimation.fillMode = kCAFillModeBackwards;
        
        
        
        [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    
//    CABasicAnimation * rotationAnimation= [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
//    rotationAnimation.duration = 2;
//    rotationAnimation.cumulative = YES;
//    rotationAnimation.repeatCount = 100000;
//    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
}
- (void)stopRotate {
    
    CFTimeInterval pauseTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.layer.speed = 0.0f;
    self.layer.timeOffset = pauseTime;
    
//    [self.layer removeAllAnimations];
}



@end
