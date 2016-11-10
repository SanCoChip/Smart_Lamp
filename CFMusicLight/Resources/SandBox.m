//
//  SandBox.m
//  single
//
//  Created by 先科讯 on 2016/10/9.
//  Copyright © 2016年 先科讯. All rights reserved.
//

#import "SandBox.h"

@implementation SandBox
+(void)saveBox:(NSString *)key withState:(BOOL)state
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",state] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(BOOL)receiveBox:(NSString *)key
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:key] isEqualToString:@"0"]?NO:YES;
    
}
@end
