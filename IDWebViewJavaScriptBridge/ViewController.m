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

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate>{
    WKWebView *_wkWebView;
}
@property (strong, nonatomic) IDWKWebViewJavascriptBridge *bridge;
@end

@implementation ViewController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _wkWebView.backgroundColor = [UIColor redColor];
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    [self.view addSubview:_wkWebView];
    self.bridge = [IDWKWebViewJavascriptBridge bridgeForWebView:_wkWebView];
    [IDWKWebViewJavascriptBridge enableLogging];
    NSURLRequest *request = [NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"]];
    [_wkWebView loadRequest:request];

//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"echo" ofType:@"html"];
//    NSString *HTMLString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    [_wkWebView loadHTMLString:HTMLString baseURL:nil];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.bridge callHandler:@"callHandler" data:@"最美的太阳" responseCallback:^(id responseData) {
            NSLog(@"返回数据了啊%@",responseData);
        }];
    });
    
    [self.bridge registerHander:@"share" handler:^(id data, BridgeResponseCallback responseCallback) {
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            [args addEntriesFromDictionary:data];
        }
        
        if (responseCallback) {
            [args setObject:responseCallback forKey:@"responseCallback"];
        }
        [self share:data];
    }];
    
    [self.bridge registerHander:@"requestLocation" handler:^(id data, BridgeResponseCallback responseCallback) {
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            [args addEntriesFromDictionary:data];
        }
        
        if (responseCallback) {
            [args setObject:responseCallback forKey:@"responseCallback"];
        }
        [self requestLocation:[args copy]];
    }];
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
    NSString *shareContent = [NSString stringWithFormat:@"标题：%@\n 内容：%@ \n url：%@",
                              args[@"title"],
                              args[@"content"],
                              args[@"url"]];
    [self showAlertViewWithTitle:@"调用原生分享菜单" message:shareContent];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

#pragma mark --WKNavigationDelegate
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
