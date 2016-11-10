//
//  LGSingleSwitch.m
//  CFMusicLight
//
//  Created by 金港 on 16/10/9.
//
//

#import "LGSingleSwitch.h"

@implementation LGSingleSwitch

+(id)allocWithZone:(struct _NSZone *)zone
{
    static LGSingleSwitch *instance;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}


+(instancetype)shareSwitch:(CGRect)frame
{
    return [[self alloc] initWithFrame:frame];
    
}


@end
