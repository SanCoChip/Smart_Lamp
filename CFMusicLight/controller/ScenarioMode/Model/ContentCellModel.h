//
//  ContentCellModel.h
//  testDemo
//
//  Created by iOS开发本-(梁乾) on 16/6/14.
//  Copyright © 2016年 SIBAT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LGModelBsaViewController.h"
//cell上内容的模型类
@interface ContentCellModel : NSObject

@property (nonatomic, strong) NSString* title;//标题
@property (nonatomic, strong) UIImage* onImage;//关闭时的图片
@property (nonatomic, strong) UIImage* openImage;//打开时的图片


+(NSArray*)cellDataSource;
//+(NSArray*)selectImages;

@end
