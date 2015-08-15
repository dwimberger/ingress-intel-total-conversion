//
//  IITCWebView.m
//  IITC-Mobile
//
//  Created by Hubert Zhang on 15/7/25.
//  Copyright © 2015年 IITC. All rights reserved.
//

#import "IITCWebView.h"
#import "JSHandler.h"

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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ios-hooks" ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    [self addJSBlock:js];
    path = [[NSBundle mainBundle] pathForResource:@"total-conversion-build.user" ofType:@"js"];
    js = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    
    [self addJSBlock:js];
    path = [[NSBundle mainBundle] pathForResource:@"user-location.user" ofType:@"js"];
    js = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    [self addJSBlock:js];
    
}

- (void)addJSBlock:(NSString *)path {
//    NSFileManager* fileMgr = [NSFileManager defaultManager];
//    NSString *tmpPath = [NSTemporaryDirectory()stringByAppendingPathComponent:@"www" ];
//    NSError * error;
//    if (![fileMgr createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:&error]) {
//        NSLog(@"Couldn't create www subdirectory. error");
//        return;
//    }
//    NSString  *dstPath = [tmpPath stringByAppendingPathComponent:[path lastPathComponent]];
//    if (![fileMgr fileExistsAtPath:dstPath]) {
//        if (![fileMgr copyItemAtPath:path toPath:dstPath error:&error]) {
//            NSLog(@"Couldn't copy file to /tmp/. (error)");
//            return;
//        }
//    }
    
//    [self loadFileURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", path]] allowingReadAccessToURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", path]]];
////    self loadRequest:<#(nonnull NSURLRequest *)#>
//        NSString *temp =[NSString stringWithFormat:@"var script = document.createElement('script');script.src = \"file://%@\";document.body.appendChild(script);", dstPath];
//    NSLog(temp);

    [self evaluateJavaScript:path completionHandler:^(id result, NSError * error) {
        if (error) {
            NSLog([error description]);
        }
    }];
}

- (void)loadJS:(NSString *)js {
    [self evaluateJavaScript:js completionHandler:^(id result, NSError * error) {
        if (error) {
            NSLog([error description]);
        }
    }];
}

@end