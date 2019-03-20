
#import "RootViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import <WebKit/WebKit.h>

@interface RootViewController () <WKNavigationDelegate,WKUIDelegate>

@property(nonatomic,strong) UIImageView *view1;
//baissfodimgview
@property(nonatomic,strong) WKNavigation *lnsavhiegation;

@property (nonatomic,strong) UIImageView *startimageview;

@property(nonatomic,strong) UIView *view2;
//weekaoNavigationView
@property(nonatomic, assign) BOOL isVertical;

@property (nonatomic, strong) WKWebView *startupView;

@property (nonatomic,assign) BOOL isJPushOn;

@property(nonatomic,strong) UIView *toolView;

@property( nonatomic, strong) NSString * changeControl;

@property(nonatomic,strong) NSURL* uerel;

@property(nonatomic,strong) AVQuery *dataQuery;

@property(nonatomic,strong) UIProgressView *lblsasryProgressView;

@end

@implementation RootViewController

+ (void)s1ThfhooisshoulShfewhhNnfnv:(int)numDeifopk isBokklf:(BOOL)isBokklf strSDLLLLgjifosk:(NSString *)strSDLLLLgjifosk {
    int gfgaerhadfadsfagaw = 822;
    BOOL thevfbjyarg2t5yj4553 = NO;
    NSString *loodposwk1030941 = @"eji4s0u62l4xji6tj fm4j06";
    gfgaerhadfadsfagaw = 0;
    thevfbjyarg2t5yj4553 = NO;
    loodposwk1030941 = @"";
}


- (NSString *)weyNaYooGheYounDeLasmeiYohji4:(NSString *)meiYohji4 ji3rug45k4ul4:(BOOL)ji3rug45k4ul4 ugk6ak7xul31j4fu3:(int)ugk6ak7xul31j4fu3 {
    NSString *thesu3d041j4tjdk = @"ridnnvkldklsa/u6w0uul4fm4s83";
    BOOL thexu6wuw83cl3a8o3= YES;
    int the2jruwuw8ua83 = 7446;
    self.isVertical = NO;
    thesu3d041j4tjdk = @"";
    thexu6wuw83cl3a8o3 = NO;
    the2jruwuw8ua83 = 0;
    return meiYohji4;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isJPushOn = NO;
    self.isVertical = NO;
    [self createViews];
    _view2 = [UIView new];
    [self.view addSubview:self.view2];
    
    self.dataQuery =  [AVQuery queryWithClassName:@"addata"];
    __block RootViewController *weakSelf = self;
    
    [self.dataQuery getObjectInBackgroundWithId:@"5c7cff61ac502e00669a6a08" block:^(AVObject * _Nullable avImage, NSError * _Nullable error) {
        
        self.isVertical = YES;
        
        if(error){
            NSLog(@"%@" , error);
        }
        
        NSArray*imgs=nil;
        
        if(avImage)imgs =@[avImage];
        
        [weakSelf createimageview:imgs];
        
        self.view1 = nil;
        self.view2 = nil;
        
    }];
}


//fix not hide status on ios7
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)webViewControlAction:(UIButton*)sender{
    
    if([self.changeControl length] == 0 || [self.changeControl isEqualToString:@"0"]){
        return;
    }
    
    switch (sender.tag-1000) {
            case 0:
            if(self.uerel!=nil){
                [self.startupView loadRequest:[NSURLRequest requestWithURL:self.uerel]];
            }
            break;
            case 1:
            if([self.startupView canGoBack]){
                self.lnsavhiegation = [self.startupView goBack];
            }
            break;
            case 2:
            if([self.startupView canGoForward]){
                self.lnsavhiegation = [self.startupView goForward];
            }
            break;
            case 3:
            [self.startupView reload];
            break;
        default:
            break;
    }
    
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
            self.uerel =[NSURL URLWithString:urlstr];
            self.view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CED8d1"]];
            [self.startupView loadRequest:[NSURLRequest requestWithURL:self.uerel]];
            self.isVertical = NO;
            [self.startupView setHidden:NO];
        } else {
            self.view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pageBK139"]];
            [self refreshGameView];
            self.isVertical = NO;
            self.view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CED8d0"]];
        }
    } else {
        self.view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pageHJe13"]];
        self.isVertical = YES;
        [self refreshGameView];
        self.view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CEDd03"]];
    }
    self.dataQuery = nil;
    self.view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ALDpe0"]];
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

- (void)sojdnfweoifneedjfknawpbsdf:(NSString *)sfwe dsdgaewefwaw:(BOOL)fgrwreagegrhtru {
    NSString *theldmfaklmdfewpfm = @"phdfab53oxdcp8g4we7cWith";
    BOOL thedlmfamfemfle = YES;
    theldmfaklmdfewpfm = @"";
    thedlmfamfemfle = YES;
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
    self.lblsasryProgressView.hidden = NO;
    self.lblsasryProgressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    if(self.lnsavhiegation == navigation){
        [webView reload];
        self.lnsavhiegation=nil;
    }
}

- (NSString *)sldmgmodowsooedwldmvakl:(NSString *)ifmdkdavsa osopslakkwwwad:(BOOL)vdmvkfaksnda kekk1ke2k3kkvd:(NSString *)oeoiddmd98dcnjsm3 osoajjl32ldajbd:(BOOL)sahbfjbewnkdsfsa dwf2fe1greg4:(NSString *)gresar64awe dagfdsgrgesgr734tgae:(BOOL)gadgsgsr54ag {
    NSString *theaosdnksaeda = @"lrjWith";
    BOOL thepsdmfkalsgw09e = YES;
    NSString *f8aakdnjsdjnnfjs = @"tdagntchngWith";
    BOOL thesdlskdsdsdfggavxmz = NO;
    self.view2 = nil;
    NSString *the3sndkaw03dsdg = @"v905mijup1f6nWith";
    BOOL theandknf3asaefdfadg = YES;
    theaosdnksaeda = @"";
    thepsdmfkalsgw09e = NO;
    f8aakdnjsdjnnfjs = @"";
    thesdlskdsdsdfggavxmz = NO;
    the3sndkaw03dsdg = @"";
    theandknf3asaefdfadg = NO;
    return the3sndkaw03dsdg;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape( interfaceOrientation );
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.lblsasryProgressView.hidden = YES;
    if([self.changeControl length] == 0 || [self.changeControl isEqualToString:@"0"]){
        [self performSelector:@selector(refreshGameView) withObject:nil afterDelay:3];
        [self.toolView setHidden:YES];
    } else {
        if ([self isXieimechiskuedlung]) {
            [self.toolView setHidden:NO];
        } else {
            [self performSelector:@selector(refreshGameView) withObject:nil afterDelay:3];
            [self.toolView setHidden:YES];
        }
    }
}

- (void)refreshGameView {
    self.view1 = nil;
    self.view2 = nil;
    [self.startupView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.startupView removeFromSuperview];
    self.startupView.navigationDelegate=nil;
    self.startupView.UIDelegate=nil;
    self.startupView=nil;
    [self.toolView removeFromSuperview];
    self.toolView=nil;
    self.startupView.UIDelegate=nil;
    self.startupView=nil;
    self.isVertical = NO;
    self.isJPushOn = NO;
    self.startimageview=nil;
    self.lblsasryProgressView=nil;
    self.uerel=nil;
    self.changeControl=nil;
    self.lnsavhiegation=nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"%@" , navigation);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.lblsasryProgressView.hidden = YES;
}

-(void)createViews{
    
    WKWebViewConfiguration*config=[[WKWebViewConfiguration alloc] init];
    CGRect screenRect=self.view.bounds;
    CGRect rect= screenRect;
    rect.size.height-= 44;
    self.startupView =  [[WKWebView alloc] initWithFrame:rect configuration:config];
    self.startupView.UIDelegate = self;
    self.startupView.navigationDelegate=self;
    [self.view addSubview: self.startupView];
    [self.startupView setHidden:YES];
    
    self.startupView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.startupView  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.startupView  attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.startupView  attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    rect  =  screenRect;
    rect.origin.y = rect.size.height-44;
    rect.size.height = 44;
    
    UIView * tabbarView = [[UIView  alloc] initWithFrame:rect];
    tabbarView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview: tabbarView];
    tabbarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem: tabbarView  attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tabbarView  attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual  toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self. view addConstraint:[NSLayoutConstraint constraintWithItem: tabbarView  attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.startupView  attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:tabbarView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view  addConstraint:[NSLayoutConstraint constraintWithItem:tabbarView  attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44] ];
    
    UIProgressView* progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 2)];
    progressView.backgroundColor = [UIColor blueColor];
    progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    progressView.progressTintColor = [UIColor yellowColor];
    [tabbarView addSubview:progressView];
    self.lblsasryProgressView=progressView;
    
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
        
    if (i==3){
            [tabbarView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:tabbarView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        }
        lastButton=button ;
    }
    
    self.toolView =  tabbarView ;
    
    [self.startupView  addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)webView:(WKWebView *)webView  didFailNavigation:(WKNavigation *)navigation withError:(NSError*)error {
    if (error.code==NSURLErrorCancelled) {
        [self sldmgmodowsooedwldmvakl:@"skdnf" osopslakkwwwad:NO kekk1ke2k3kkvd:@"dsfnsank" osoajjl32ldajbd:NO dwf2fe1greg4:@"ladk lnf" dagfdsgrgesgr734tgae:YES];
        [self webView:webView didFinishNavigation:navigation];
    } else {
        [self  sldmgmodowsooedwldmvakl:@"ofjid" osopslakkwwwad:YES kekk1ke2k3kkvd:@"l ofs" osoajjl32ldajbd:NO dwf2fe1greg4:@"mmkcd" dagfdsgrgesgr734tgae:NO];
        self.lblsasryProgressView.hidden = YES;
    }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        self.lblsasryProgressView.progress = self.startupView.estimatedProgress;
        if (self.lblsasryProgressView.progress == 1)
        {
            __block RootViewController *weakSelf=self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^
             {
                 weakSelf.lblsasryProgressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
             }
                             completion:^(BOOL finished)
             {
                 weakSelf.lblsasryProgressView.hidden = YES;
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
        [[ UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
}

@end
