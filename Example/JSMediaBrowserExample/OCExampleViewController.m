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

@interface OCExampleViewController ()

@end

@implementation OCExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
