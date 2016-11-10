//
//  LGSceneModel.h
//  CFMusicLight
//
//  Created by 金港 on 16/7/5.
//
//

#import <Foundation/Foundation.h>
#import "JRBLESDK.h"
//   功能：关键开关
//          | -- 开
                //  -- 其他事件
                    //  -- 实现 其他事件
//          | -- 关
            //

            // 彩虹接口:
                //  打开 - 关闭状态
                //   设置彩虹模式：开关


@interface LGSceneModel : NSObject{

    JRBLESDK *_bleManager;
}
//封装方法
- (void)setOpen:(BOOL)isOpen andFunction:(NSInteger)function;





@end
        