//
//  ViewController.m
//  IITC-Mobile
//
//  Created by Hubert Zhang on 15/7/25.
//  Copyright © 2015年 IITC. All rights reserved.
//

#import "ViewController.h"
#import "IITCWebView.h"
#import "IITCLocation.h"
#import "JSHandler.h"

static ViewController *_viewController;
@interface ViewController ()
@property IITCLocation *location;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong) NSMutableArray *backPane;
@property BOOL backButtonPressed;
@property NSString *currentPaneID;
@property BOOL iitcLoaded;
@property BOOL loadIITCNeeded;
@end

@implementation ViewController
@synthesize webView;
@synthesize progressView;
- (void)viewDidLoad {
    [super viewDidLoad];
    _viewController = self;
    // Do any additional setup after loading the view, typically from a nib.
    self.backPane = [[NSMutableArray alloc] init];
    self.currentPaneID = @"map";
    self.loadIITCNeeded = YES;
    
    self.location = [[IITCLocation alloc] initWithCallback:self];
    self.webView = [[IITCWebView alloc] initWithFrame:CGRectZero];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *constraits = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];

    [constraits addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    id topGuide = self.topLayoutGuide;
    id bottomGuide = self.bottomLayoutGuide;
    [constraits addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide]-0-[webView]-0-[bottomGuide]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topGuide, webView, bottomGuide)]];
    [constraits addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[progressView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(progressView)]];
    [constraits addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide]-0-[progressView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topGuide, progressView)]];
    [self.view addConstraints:constraits];
    [self.progressView setProgress:0.8];
    self.webView.backgroundColor = [UIColor blackColor];
    
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bootFinished) name:JSNotificationBootFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCurrentPane:) name:JSNotificationPaneChanged object:nil];
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithTitle:@"settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonPressed:)];
    UIBarButtonItem *locationButton = [[UIBarButtonItem alloc] initWithTitle:@"locate" style:UIBarButtonItemStylePlain target:self action:@selector(locationButtonPressed:)];
    self.navigationItem.rightBarButtonItems = @[settingButton, locationButton];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.ingress.com/intel"]]];

}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
};

+(instancetype)sharedInstance{
    return _viewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString: @"URL"]) {

    } else if ([keyPath isEqualToString: @"loading"]) {
        if ([self.webView.URL.host containsString:@"accounts.google"]) {
            self.loadIITCNeeded = YES;
            UIViewController *tempView = [[UIViewController alloc] init];
            
        } else if (!self.webView.loading &&[self.webView.URL.host containsString:@"ingress"] && self.loadIITCNeeded) {
//            [self.webView loadScripts];
        }
    }
    else {
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
    }
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    //WebView.frame=[[UIScreen mainScreen] bounds];
//}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:webView.URL.host preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)bootFinished {
    [self.location startUpdate];
    [self getLayers];
}

- (void)switchToPane:(NSString *)pane {
    [self.webView loadJS:[NSString stringWithFormat:@"window.show('%@')", pane]];
}

- (void)backButtonPressed:(id)aa {
    if ([self.backPane count]) {
        NSString * pane = [self.backPane lastObject];
        [self.backPane removeLastObject];
        [self switchToPane:pane];
        self.backButtonPressed = true;
    }
    if (![self.backPane count]) {
        self.navigationItem.leftBarButtonItem=nil;
    }
}

-(void)setCurrentPane:(NSNotification *)notification {
    NSString *pane = notification.userInfo[@"paneID"];

    if ([pane isEqualToString:self.currentPaneID]) return;
    
    // map pane is top-lvl. clear stack.
    if ([pane isEqualToString:@"map"]) {
        self.backPane.removeAllObjects;
    }
    // don't push current pane to backstack if this method was called via back button
    else if (!self.backButtonPressed) {
        [self.backPane addObject:self.currentPaneID];
        self.navigationItem.leftBarButtonItem = self.backButton;
    }
    
    self.backButtonPressed = NO;
    _currentPaneID = pane;
}

- (void)getLayers {
    [self.webView loadJS:@"window.layerChooser.getLayers()"];
}

- (void)webView:(nonnull WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
    
    NSLog(@"%s", __func__);
    
}

- (void)webView:(nonnull WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __func__);
    if ([webView.URL.host containsString:@"ingress"]) {
        [self.webView loadScripts];
    }
}

- (void)webView:(nonnull WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"%s", __func__);
    
}

@end