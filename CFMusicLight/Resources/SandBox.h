//
//  SandBox.h
//  single
//
//  Created by 先科讯 on 2016/10/9.
//  Copyright © 2016年 先科讯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SandBox : NSObject
+(void)saveBox:(NSString *)key withState:(BOOL)state;

+(BOOL)receiveBox:(NSString *)key;
@end
