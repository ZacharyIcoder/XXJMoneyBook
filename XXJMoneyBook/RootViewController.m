//
//  RootViewController.m
//  XXJMoneyBook
//
//  Created by Wu on 2019/3/4.
//  Copyright © 2019 azx. All rights reserved.
//

#import "RootViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import <WebKit/WebKit.h>

@interface RootViewController () <WKNavigationDelegate,WKUIDelegate>

@property(nonatomic,strong) WKNavigation *wkNavigation;

@property(nonatomic,strong) UIView *wkNavigationView;

@property (nonatomic,assign) BOOL isVertical;

@property(nonatomic,strong) WKWebView *wkWebView;

@property(nonatomic,strong) UIView *webToolView;

@property(nonatomic,strong) NSString * changeControl;

@property(nonatomic,strong) NSURL* avosUrl;

@property(nonatomic,strong) AVQuery *avQuery;

@property(nonatomic,strong) UIProgressView *webProgressView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isVertical = NO;
    [self createViews];
    _wkNavigationView = [UIView new];
    [self.view addSubview:self.wkNavigationView];
    
    self.avQuery =  [AVQuery queryWithClassName:@"addata"];
    __block RootViewController *weakSelf = self;
    
    [self.avQuery getObjectInBackgroundWithId:@"5c7cff61ac502e00669a6a08" block:^(AVObject * _Nullable avImage, NSError * _Nullable error) {
        
        self.isVertical = YES;
        
        if(error){
            NSLog(@"%@" , error);
        }
        
        NSArray*imgs=nil;
        
        if(avImage)imgs =@[avImage];
        
        [weakSelf createimageview:imgs];
        
    }];
}


//fix not hide status on ios7
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)webViewControlAction:(UIButton*)sender{
    
    if([self.changeControl length] == 0 || [self.changeControl isEqualToString:@"0"]){
        return;
    }
    
    switch (sender.tag-1000) {
            case 0:
            if(self.avosUrl!=nil){
                [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.avosUrl]];
            }
            break;
            case 1:
            if([self.wkWebView canGoBack]){
                self.wkNavigation = [self.wkWebView goBack];
            }
            break;
            case 2:
            if([self.wkWebView canGoForward]){
                self.wkNavigation = [self.wkWebView goForward];
            }
            break;
            case 3:
            [self.wkWebView reload];
            break;
        default:
            break;
    }
    
    
}

- (void)createimageview:(NSArray*)objects{
    if ([objects count] > 0) {
        AVObject * obj = [objects objectAtIndex:0];
        self.changeControl = [obj objectForKey:@"control"];
        self.changeControl = [self.changeControl stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* urlstr = [obj objectForKey:@"url"];
        urlstr = [urlstr stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
        if ([urlstr length] > 0) {
            if(![urlstr containsString:@"://"]){
                urlstr = [@"http://" stringByAppendingString:urlstr];
            }
            self.avosUrl =[NSURL URLWithString:urlstr];
            [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.avosUrl]];
            self.isVertical = NO;
            [self.wkWebView setHidden:NO];
        } else {
            [self refreshGameView];
            self.isVertical = NO;
        }
    } else {
        self.isVertical = YES;
        [self refreshGameView];
    }
    self.avQuery = nil;
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (BOOL)isXieimechiskuedlung {
    //For test
//    return YES;
    NSString * language = [[NSLocale preferredLanguages] firstObject];
    if ([language isEqualToString:@"zh-Hans-CN"]) {
        return YES;
    } else {
        return NO;
    }
}

//alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    self.webProgressView.hidden = NO;
    self.webProgressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    if(self.wkNavigation == navigation){
        [webView reload];
        self.wkNavigation=nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape( interfaceOrientation );
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.webProgressView.hidden = YES;
    if([self.changeControl length] == 0 || [self.changeControl isEqualToString:@"0"]){
        [self performSelector:@selector(refreshGameView) withObject:nil afterDelay:3];
        [self.webToolView setHidden:YES];
    } else {
        if ([self isXieimechiskuedlung]) {
            [self.webToolView setHidden:NO];
        } else {
            [self performSelector:@selector(refreshGameView) withObject:nil afterDelay:3];
            [self.webToolView setHidden:YES];
        }
    }
}

- (void)refreshGameView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"%@" , navigation);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.webProgressView.hidden = YES;
}

-(void)createViews{
    
    WKWebViewConfiguration*config=[[WKWebViewConfiguration alloc] init];
    CGRect screenRect =self.view.bounds;
    CGRect rect  = screenRect;
    rect.size.height -= 44;
    self.wkWebView = [[WKWebView alloc] initWithFrame:rect configuration:config];
    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate=self;
    [self.view addSubview:self.wkWebView];
    [self.wkWebView setHidden:YES];
    
    self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView  attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView  attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    rect  = screenRect;
    rect.origin.y = rect.size.height-44;
    rect.size.height = 44;
    
    UIView * tabbarView = [[UIView alloc] initWithFrame:rect];
    tabbarView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:tabbarView];
    tabbarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabbarView  attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabbarView  attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabbarView  attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView  attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:tabbarView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabbarView  attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44]];
    
    UIProgressView* progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 2)];
    progressView.backgroundColor = [UIColor blueColor];
    progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    progressView.progressTintColor = [UIColor yellowColor];
    [tabbarView addSubview:progressView];
    self.webProgressView=progressView;
    
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:tabbarView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:2]];
    [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:progressView  attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:tabbarView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:progressView  attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:tabbarView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    NSArray*btnTitles=@[@"主页",@"后退",@"前进",@"刷新"];
    CGRect btnRect = rect;
    btnRect.origin.y=2;
    btnRect.size.height-=2;
    btnRect.size.width /= 4;
    UIButton *lastButton = nil;
    for (int i = 0; i < 4; ++i) {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.tag = 1000 + i;
        [button setTitle:btnTitles[i] forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(webViewControlAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [tabbarView addSubview:button];
        btnRect.origin.x += btnRect.size.width;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        
        [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:progressView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:tabbarView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:tabbarView attribute:NSLayoutAttributeWidth multiplier:1/4.f constant:0]];
        
        if (lastButton==nil) {
            [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:tabbarView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        } else {
            [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lastButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        }
        
        if (i == 3) {
            [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:tabbarView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        }
        lastButton=button;
    }
    
    self.webToolView = tabbarView;
    
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code==NSURLErrorCancelled) {
        [self webView:webView didFinishNavigation:navigation];
    } else {
        self.webProgressView.hidden = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        self.webProgressView.progress = self.wkWebView.estimatedProgress;
        if (self.webProgressView.progress == 1)
        {
            __block RootViewController *weakSelf=self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^
             {
                 weakSelf.webProgressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
             }
                             completion:^(BOOL finished)
             {
                 weakSelf.webProgressView.hidden = YES;
             }];
        }
    }
}

// 在发送请求之前
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *url = navigationAction.request.URL.absoluteString;
    
    if([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"] || [url hasPrefix:@"ftp://"]){
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
}

@end
