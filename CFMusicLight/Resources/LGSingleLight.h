//
//  LGSingleLight.h
//  CFMusicLight
//
//  Created by 金港 on 16/10/12.
//
//

#import <Foundation/Foundation.h>

@interface LGSingleLight : NSObject
//是否打开
@property(nonatomic, assign)BOOL isOn;



@property(nonatomic, assign)BOOL colorIsON;




+(instancetype)shareLight;


@end
