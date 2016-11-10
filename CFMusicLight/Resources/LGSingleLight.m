//
//  LGSingleLight.m
//  CFMusicLight
//
//  Created by 金港 on 16/10/12.
//
//

#import "LGSingleLight.h"

@implementation LGSingleLight

+(id)allocWithZone:(struct _NSZone *)zone
{
    static LGSingleLight *instance;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}


+(instancetype)shareLight
{
    return [[self alloc] init];
    
}



@end
