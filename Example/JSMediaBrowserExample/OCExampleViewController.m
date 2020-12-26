//
//  OCExampleViewController.m
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/11.
//

#import "OCExampleViewController.h"
#if !TARGET_OS_MACCATALYST
#import "JSMediaBrowserExample-Swift.h"
#else
#import "JSMediaBrowserExampleMacOS-Swift.h"
#endif
#import <SDWebImage.h>
#import <JSMediaBrowser/JSMediaBrowser-Swift.h>

@interface OCExampleViewController ()

@end

@implementation OCExampleViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
       
        MediaBrowserAppearance.appearance.addWebImageMediatorBlock = ^id<MediaBrowserWebImageMediatorProtocol> _Nonnull(MediaBrowserViewController * browserVC, id<MediaBrowserSourceProtocol> sourceItem) {
            return [[MediaBrowserViewDefaultWebImageMediator alloc] init];
        };
        MediaBrowserAppearance.appearance.addToolViewsBlock = ^NSArray<UIView<MediaBrowserToolViewProtocol> *> *(MediaBrowserViewController *browserVC) {
            return @[];
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)handleImageButtonEvent:(UIButton *)sender {
    MediaBrowserViewController *browserVC = [[MediaBrowserViewController alloc] init];
    browserVC.sourceItems = @[];
    browserVC.browserView.currentPage = 0;
    [browserVC showFromViewController:self animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
