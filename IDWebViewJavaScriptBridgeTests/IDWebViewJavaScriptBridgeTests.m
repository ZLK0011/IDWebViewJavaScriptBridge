//
//  IDWebViewJavaScriptBridgeTests.m
//  IDWebViewJavaScriptBridgeTests
//
//  Created by ZLK on 2019/1/16.
//  Copyright © 2019年 ___ZLK___. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IDWKWebViewJavascriptBridge.h"
#import "AppDelegate.h"

static NSString *const callHandler = @"callHandler";

@interface IDWebViewJavaScriptBridgeTests : XCTestCase

@end


@implementation IDWebViewJavaScriptBridgeTests {
    WKWebView *_wkWebView;
    IDWKWebViewJavascriptBridge *_bridge;
}

- (void)setUp {
    [super setUp];
    
    UIViewController *rootVC = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController];
    CGRect frame = rootVC.view.bounds;
    
    _wkWebView = [[WKWebView alloc] initWithFrame:frame];
    _wkWebView.backgroundColor = [UIColor redColor];

    [rootVC.view addSubview:_wkWebView];
    _bridge = [IDWKWebViewJavascriptBridge bridgeForWebView:_wkWebView];

}

- (void)tearDown {
    [super tearDown];
    [_wkWebView removeFromSuperview];
    _bridge = nil;
    
}

const NSTimeInterval timeoutSec = 5;

- (void)testCallHandler {
    
    //该方法用于表示这个异步测试结束了，每一个XCTestExpectation都需要对应一个fulfill，否则将会导致测试失败
     XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
    
    [_bridge callHandler:callHandler data:@"最美的太阳" responseCallback:^(id responseData) {
        XCTAssertEqualObjects(responseData, @"最美的太阳");
        [callbackInvocked fulfill];
    }];
    [self loadTestHtmlFile];
    
    //等待，若测试未结束（未收到 fulfill方法）则测试结果为失败
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
    
}

- (void)testObectEncoding {
    void (^printObject)(id) = ^(id object){
        XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
        [self->_bridge callHandler:callHandler data:object responseCallback:^(id responseData) {
            XCTAssertEqualObjects(responseData, object);
            [callbackInvocked fulfill];
            NSLog(@"Native=>JS%@",responseData);
        }];
    };
    printObject(@[ @1, @2, @3 ]);
    printObject(@{ @"a": @"Dog", @"b":@9527 });
    printObject(@"A string sent over the wire");
    printObject(@"A string with '\"'/\\");
    
    [self loadTestHtmlFile];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}

- (void)testJavascriptReceiveResponseWithoutSafetyTimeout {
    [_bridge disableJavscriptAlertBoxSafetyTimeout];
    [self loadTestHtmlFile];
    
    XCTestExpectation *callbackInvocked = [self expectationWithDescription:@"Callback invoked"];
    [_bridge callHandler:callHandler data:@"最美的太阳" responseCallback:^(id responseData) {
        XCTAssertEqualObjects(responseData, @"最美的太阳");
        [callbackInvocked fulfill];
    }];
    [self waitForExpectationsWithTimeout:timeoutSec handler:NULL];
}

- (void)loadTestHtmlFile {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSString *HTMLString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_wkWebView loadHTMLString:HTMLString baseURL:nil];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
