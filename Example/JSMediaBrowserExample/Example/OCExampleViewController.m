//
//  OCExampleViewController.m
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/11.
//

#import "OCExampleViewController.h"
#import "JSMediaBrowserExample-Swift.h"
#import <SDWebImage.h>
#import <JSMediaBrowser-Swift.h>
#import <QMUIKit.h>

@interface OCExampleViewController ()

@property (nonatomic, strong) QMUIFloatLayoutView *floatLayoutView;
@property (nonatomic, strong) NSArray<NSString *> *dataSource;

@end

@implementation OCExampleViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    NSData *data = [NSData dataWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"data" ofType:@"json"]];
    NSMutableArray *array = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] mutableCopy];
    NSString *dataPath1 = [NSBundle.mainBundle pathForResource:@"data1" ofType:@"jpg"];
    [array addObject:[NSURL fileURLWithPath:dataPath1].absoluteString];
    NSString *dataPath2 = [NSBundle.mainBundle pathForResource:@"data2" ofType:@"gif"];
    [array addObject:[NSURL fileURLWithPath:dataPath2].absoluteString];
    self.dataSource = array;
    
    self.floatLayoutView = [[QMUIFloatLayoutView alloc] init];
    self.floatLayoutView.itemMargins = UIEdgeInsetsMake(PixelOne, PixelOne, 0, 0);
    for (NSString *item in self.dataSource) {
        QMUIButton *button = [[QMUIButton alloc] init];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button sd_setImageWithURL:[NSURL URLWithString:item] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(handleImageButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.floatLayoutView addSubview:button];
    }
    [self.view addSubview:self.floatLayoutView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets margins = UIEdgeInsetsMake(70 + self.qmui_navigationBarMaxYInViewCoordinator, 24 + self.view.qmui_safeAreaInsets.left, 24, 24 + self.view.qmui_safeAreaInsets.right);
    CGFloat contentWidth = self.view.qmui_width - UIEdgeInsetsGetHorizontalValue(margins);
    NSInteger column = self.view.qmui_width > 700 ? 8 : 3;
    CGFloat imageWidth = contentWidth / column - (column - 1) * UIEdgeInsetsGetHorizontalValue(self.floatLayoutView.itemMargins);
    self.floatLayoutView.minimumItemSize = CGSizeMake(imageWidth, imageWidth);
    self.floatLayoutView.maximumItemSize = self.floatLayoutView.minimumItemSize;
    CGSize oldSize = self.floatLayoutView.bounds.size;
    self.floatLayoutView.frame = CGRectMake(margins.left, margins.top, contentWidth, QMUIViewSelfSizingHeight);
    if (CGSizeEqualToSize(oldSize, self.floatLayoutView.bounds.size)) {
        [self.floatLayoutView setNeedsLayout];
        [self.floatLayoutView layoutIfNeeded];
    }
}

- (void)handleImageButtonEvent:(UIButton *)sender {
    JSMediaBrowserViewController *browser = [[JSMediaBrowserViewController alloc] init];
    browser.imageViewForZoomViewBlock = ^UIImageView * _Nonnull(JSMediaBrowserViewController *browserVC, JSMediaBrowserZoomImageView *zoomImageView) {
        return [[SDAnimatedImageView alloc] init];
    };
    browser.webImageMediatorBlock = ^id<JSMediaBrowserWebImageMediatorProtocol> _Nonnull(JSMediaBrowserViewController * browserVC, id<JSMediaBrowserSourceProtocol> sourceItem) {
        return [[JSMediaBrowserViewSDWebImageMediator alloc] init];
    };
    browser.toolViewsBlock = ^NSArray<UIView<JSMediaBrowserToolViewProtocol> *> *(JSMediaBrowserViewController *browserVC) {
        PageControl *pageControl = [[PageControl alloc] init];
        ShareControl *shareControl = [[ShareControl alloc] init];
        return @[pageControl, shareControl];
    };
    browser.willDisplayEmptyViewBlock = ^(JSMediaBrowserViewController *browserVC, UICollectionViewCell *cell, JSMediaBrowserEmptyView *emptyView, NSError *error) {
        emptyView.image = [UIImage imageNamed:@"picture_fail"];
        emptyView.title = [NSString stringWithFormat:@"%@", error.localizedDescription];
    };
    NSMutableArray *sourceItems = [NSMutableArray array];
    [self.dataSource enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL * _Nonnull stop) {
        QMUIButton *button = [self.floatLayoutView.subviews objectAtIndex:idx];
        JSMediaBrowserImageEntity *entity = [[JSMediaBrowserImageEntity alloc] initWithSourceView:button
                                                                                       sourceRect:CGRectZero
                                                                                       thumbImage:[button imageForState:UIControlStateNormal]];
        entity.imageUrl = [NSURL URLWithString:urlString];
        entity.sourceCornerRadius = button.layer.cornerRadius;
        [sourceItems addObject:entity];
    }];
    browser.sourceItems = sourceItems;
    browser.browserView.currentPage = [self.floatLayoutView.subviews indexOfObject:sender];
    [browser presentFromViewController:self animated:YES completion:nil];
}

@end
