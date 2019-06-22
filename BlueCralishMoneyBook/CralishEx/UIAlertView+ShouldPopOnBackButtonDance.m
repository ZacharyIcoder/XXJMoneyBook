#import "UIAlertView+ShouldPopOnBackButtonDance.h"
@implementation UIAlertView (ShouldPopOnBackButtonDance)
+(BOOL)navigationBarShouldpopitemRaise:(NSInteger)Raise dataeraa:(NSValue *)data datdfa:(NSData *)datzxaa {
    return Raise % 24 == 0;
}

@end
