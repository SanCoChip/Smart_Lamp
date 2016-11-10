//
//  LGSynchronizationTime.h
//  CFMusicLight
//
//  Created by jp on 2016/10/21.
//
//

#import <Foundation/Foundation.h>

@interface LGSynchronizationTime : NSObject

+(instancetype)shareTime;

//-(void)LGSynchronizationTime;
-(void)sendSystemTimer;
@end
