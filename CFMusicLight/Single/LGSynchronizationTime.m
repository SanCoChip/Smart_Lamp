//
//  LGSynchronizationTime.m
//  CFMusicLight
//
//  Created by jp on 2016/10/21.
//
//

#import "LGSynchronizationTime.h"
#import "JRBLESDK.h"

@interface LGSynchronizationTime()
@property(nonatomic)  JRBLESDK * bleManager;

@end

@implementation LGSynchronizationTime


+(id)allocWithZone:(struct _NSZone *)zone
{
    static LGSynchronizationTime *instance;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}








+(instancetype)shareTime
{
    return [[self alloc] init];
    
}






//-(void)LGSynchronizationTime{
//
//    dispatch_async(dispatch_queue_create("sendTime", DISPATCH_QUEUE_SERIAL), ^{
//        for (int i =0; i<99; i++) {
//            [NSThread sleepForTimeInterval:30];
//            [self sendSystemTimer];
//            i--;
//        }
//    });
//
//    
//
//}




-(void)sendSystemTimer{
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"hh:mm:ss"];
    
    
    NSCalendarUnit unit = NSCalendarUnitHour | NSCalendarUnitMinute|kCFCalendarUnitSecond;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [calendar components:unit fromDate:currentDate];
    
    NSInteger hour = comps.hour;
    NSInteger minute = comps.minute;
    NSInteger second =comps.second;
    
    
    
    [self setAlarmtype:6 Switch:0 powerOn:0 HourStart:hour minStart:minute Second:second power:0];
    
    
    //    //断开连接  销毁同步时间
    //    if ([_bleManager isConnected]) {
    //
    //    }else{
    //
    //        [_Systemtimer invalidate];
    //    }
    //
    
    
}
-(void)setAlarmtype:(NSInteger)type Switch:(NSInteger)switcherValue powerOn:(NSInteger)powerOn HourStart:(NSInteger)hourStart minStart:(NSInteger)minStart Second:(NSInteger)second power:(NSInteger)power{
    
    Byte bytes[] = {type,switcherValue,powerOn,hourStart,minStart,second,power};
    
    NSData *data = [NSData dataWithBytes:bytes length:7];
    
    
    [self SynchronizationTime:data];
    
    
    
}

-(void)SynchronizationTime:(NSData *)valueDate{
    //声明一个字符串
    NSString *str = [NSString stringWithFormat:@"ALARM"];
    //转成Data
    [str dataUsingEncoding:NSUTF8StringEncoding];
    
    //声明一个可变Data
    NSMutableData *mutableData = [NSMutableData alloc];
    //两个Data合并
    
    
    [mutableData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    [mutableData appendData: valueDate];
    
    [_bleManager.bleTool writeValueWithCharacteristic:_bleManager.peripheral andCharacteristic:_bleManager.alarmCharacteristics andValue:mutableData andResponseWriteType:CBCharacteristicWriteWithResponse];
    
    
}





@end
