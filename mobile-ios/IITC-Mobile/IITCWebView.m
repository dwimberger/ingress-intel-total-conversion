//
//  IITCWebView.m
//  IITC-Mobile
//
//  Created by Hubert Zhang on 15/7/25.
//  Copyright © 2015年 IITC. All rights reserved.
//

#import "IITCWebView.h"
#import "JSHandler.h"
#import "ScriptsManager.h"

@implementation IITCWebView

- (instancetype)initWithFrame:(CGRect)frame{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    JSHandler *handler = [[JSHandler alloc] init];
    [configuration.userContentController addScriptMessageHandler:handler name:@"ios"];
//    NSError *error;
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"ios-hooks" ofType:@"js"];
//    NSString *js = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
//    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES]];
//    path = [[NSBundle mainBundle] pathForResource:@"total-conversion-build.user" ofType:@"js"];
//    js = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
//    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES]];
//    path = [[NSBundle mainBundle] pathForResource:@"user-location.user" ofType:@"js"];
//    js = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
//    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES]];
//    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:@"alert('a')" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES]];
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {

    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)loadScripts {
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"scripts/ios-hooks" ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    js = [NSString stringWithFormat:js,[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"], [(NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey] integerValue]];

    [self loadJS:js];

    path = [[NSBundle mainBundle] pathForResource:@"scripts/total-conversion-build.user" ofType:@"js"];
    NSLog(@"Loading script %@", path);
    js = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    [self loadJS:js];
    
    path = [[NSBundle mainBundle] pathForResource:@"scripts/user-location.user" ofType:@"js"];
    NSLog(@"Loading script %@", path);
    js = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    [self loadJS:js];
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * pluginsPath = [resourcePath stringByAppendingPathComponent:@"scripts/plugins"];
    for (NSString *scriptPath in [[ScriptsManager sharedInstance] loadedScripts]) {
        path = [pluginsPath stringByAppendingPathComponent:scriptPath];
        NSLog(@"Loading script %@", path);
        js = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
        [self loadJS:js];
    }
    
    
    
}

- (void)loadJS:(NSString *)js {
    [self evaluateJavaScript:js completionHandler:^(id result, NSError * error) {
        if (error) {
            NSLog(@"evaluateJavaScript error: %@", error);
//            NSLog(@"%@ \n\n --- SCRIPT ---\n\n%@\n\n------\n\n", [error description], js);
        }
    }];
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    __block NSString *resultString = nil;
    __block BOOL finished = NO;
    
    [self evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];
    
    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return resultString;
}


@end
