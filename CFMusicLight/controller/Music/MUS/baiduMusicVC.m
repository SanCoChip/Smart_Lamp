//
//  baiduMusicVC.m
//  BLEProject
//
//  Created by 先科讯 on 2016/12/1.
//  Copyright © 2016年 jp. All rights reserved.
//

#import "baiduMusicVC.h"

@interface baiduMusicVC ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *baiduWeb;

@end

@implementation baiduMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSURL* url = [NSURL URLWithString:@"http://music.baidu.com"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    _baiduWeb.delegate = self;
    
    
    
    [_baiduWeb loadRequest:request];
    [self.view addSubview:_baiduWeb];
    
}

#pragma mark --- UIWebViewDelegate
//开始加载网页
- (void)webViewDidStartLoad:(UIWebView *)webView {
    //设置状态条(status bar)的activityIndicatorView开始动画
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

//成功加载完毕
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //设置indicatorView动画停止
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}
//加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    //停止动画
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"加载失败:%@", error.userInfo);
    
}


@end
