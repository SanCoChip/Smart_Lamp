//
//  WebviewVC.m
//  CFMusicLight
//
//  Created by 吕金港 on 2016/12/6.
//
//

#import "WebviewVC.h"
#import "LGMusicPlayViewController.h"
#import <AFNetworking.h>
#import "JPProgressHUD.h"
@interface WebviewVC ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *onlineMusicWebView;

@end

@implementation WebviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.onlineMusicWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
    self.onlineMusicWebView.delegate =self;

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"这是WiFi");
                [JPProgressHUD showMessage:@"当前网络为WiFi"];
                
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"当前无网络");
                [JPProgressHUD showMessage:@"当前无网络"];
                break;
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"当前网络未知");
                [JPProgressHUD showMessage:@"当前网络未知"];
                break;
             case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"当前是蜂窝网络");
                [JPProgressHUD showMessage:@"当前网络为蜂窝网络"];
            default:
                
                break;
        }
    }];
    [self performSelector:@selector(checknetWork) withObject:nil afterDelay:0];
    
}

-(void)checknetWork{

}
-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    
    [_onlineMusicWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
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

//-(void)webViewDidStartLoad:(UIWebView*)webView{
//
//    NSLog(@"--------");
//
//}
//-(void)webView:(UIWebView*)webView DidFailLoadWithError:(NSError*)error{
//
//    NSLog(@"%@",error);
//}




@end
