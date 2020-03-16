//
//  ViewController.m
//  IDWebViewJavaScriptBridge
//
//  Created by ZLK on 2019/1/16.
//  Copyright © 2019年 ___ZLK___. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "IDWKWebViewJavascriptBridge.h"
#import "IDHandlerManager.h"
#import "IDUserMessageHandler.h"
#import "IDAppMessageHandler.h"
#import "IDPlayerMessageHandler.h"
#import "IDPageMessageHandler.h"
#import "IDSettingMessageHandler.h"

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,IDUserMessageHandlerProtocol,IDAppMessageHandlerProtocol,IDSettingMessageHandlerProtocol,IDPlayerMessageHandlerProtocol,IDPageMessageHandlerProtocol>{
    WKWebView *_wkWebView;
}
@property (strong, nonatomic) IDWKWebViewJavascriptBridge *bridge;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _wkWebView.backgroundColor = [UIColor redColor];
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    [self.view addSubview:_wkWebView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"]];
    [_wkWebView loadRequest:request];
    
    [self registerMessageHandlers];
}

- (void)registerMessageHandlers {
    self.bridge = [IDWKWebViewJavascriptBridge bridgeForWebView:_wkWebView];
    [[IDHandlerManager sharedManager] registerAllHandlersForJSBridge:self.bridge delegate:self];
}

#pragma mark - IDUserMessageHandlerProtocol
- (void)userMessageHandler:(NSDictionary *)args{
    BridgeResponseCallback responseCallback = args[@"responseCallback"];
    if (responseCallback) {
        NSDictionary *dic = @{
            @"code": @(0),        //请求状态码
            @"msg": @"OK",     //请求返回信息
            @"data": @{        //请求返回的数据
                @"userId": @"123456",
                @"nickname": @"口袋宝贝",
                @"userType": @(1),
                @"avatar": @"http://avatar.account.idaddy.cn/avatar/025/35/11/69_avatar_1575628057.jpg",
                @"vipExpiredAt": @"2020-12-28 23:59:59",
                @"token": @"4b04ba3f-95a7-8e25-a2f6-5e142e7bfaa9aa",
                @"age": @"3.1",
                @"gender":@"1"
            }
        };
        responseCallback(dic);
    }
}

- (void)userLoginMessageHandler:(NSDictionary *)args{
    BridgeResponseCallback responseCallback = args[@"responseCallback"];
    [self share:args];
    if (responseCallback) {
        NSDictionary *dic = @{
                @"code": @(0),        //请求状态码
                @"msg": @"OK"     //请求返回信息
                            };
        responseCallback(dic[@"msg"]);
    }
}

#pragma mark - IDAppMessageHandlerProtocol
- (void)appMessageHandler:(NSDictionary *)args{
    NSLog(@"app----%@",args);
}

#pragma mark - IDPlayerMessageHandlerProtocol
- (void)playerPlayMessageHandler:(NSDictionary *)args{
    NSLog(@"player.play----%@",args);
    BridgeResponseCallback responseCallback = args[@"responseCallback"];
    if (responseCallback) {
        NSDictionary *dic = @{
                @"code": @(0),        //请求状态码
                @"msg": @"OK"     //请求返回信息
                            };
        responseCallback(dic[@"msg"]);
    }
}

- (void)playerPauseMessageHandler:(NSDictionary *)args{
    NSLog(@"player.pause----%@",args);
}

#pragma mark - IDSettingMessageHandlerProtocol
- (void)settingMessageHandler:(NSDictionary *)args{
    NSLog(@"setting----%@",args);
}

#pragma mark - IDPageMessageHandlerProtocol
- (void)pageMessageHandler:(NSDictionary *)args{
    NSLog(@"page----%@",args);
}

// 获取地理位置信息（由JS端调用）
- (void)requestLocation:(NSDictionary *)args {
    BridgeResponseCallback responseCallback = args[@"responseCallback"];
    if (responseCallback) {
        responseCallback(@"上海市浦东新区张江高科");
    }
}

// 分享（由JS端调用）
- (void)share:(NSDictionary *)args {
    NSString *shareContent = [NSString stringWithFormat:@"标题：%@\n 内容：%@ \n",
                              args[@"title"],
                              args[@"content"]];
    [self showAlertViewWithTitle:@"调用原生分享菜单" message:shareContent];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败%@",[error description]);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    //捕捉JS端alert，同时最后completionHandler必须执行否则报错not called
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"JS Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { completionHandler(); }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    //    if (<#wkwebView.isVisible#>) {
//        [self presentViewController:alert animated:YES completion:nil];
//    } else {
//        completionHandler();
//    }
}

@end
