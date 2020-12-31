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
        /// 全局配置
        MediaBrowserAppearance.appearance.addImageViewInZoomViewBlock = ^UIImageView * _Nonnull(MediaBrowserViewController *browserVC, MediaBrowserZoomImageView *zoomImageView) {
            return [[SDAnimatedImageView alloc] init];
        };
        MediaBrowserAppearance.appearance.addWebImageMediatorBlock = ^id<MediaBrowserWebImageMediatorProtocol> _Nonnull(MediaBrowserViewController * browserVC, id<MediaBrowserSourceProtocol> sourceItem) {
            return [[MediaBrowserViewDefaultWebImageMediator alloc] init];
        };
        MediaBrowserAppearance.appearance.addToolViewsBlock = ^NSArray<UIView<MediaBrowserToolViewProtocol> *> *(MediaBrowserViewController *browserVC) {
            PageControl *pageControl = [[PageControl alloc] init];
            ShareControl *shareControl = [[ShareControl alloc] init];
            return @[pageControl, shareControl];
        };
        MediaBrowserAppearance.appearance.willDisplayEmptyViewBlock = ^(MediaBrowserViewController *browserVC, UICollectionViewCell *cell, EmptyView *emptyView, NSError *error) {
            emptyView.image = [UIImage imageNamed:@"picture_fail"];
            emptyView.title = [NSString stringWithFormat:@"%@", error.localizedDescription];
        };
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
    MediaBrowserViewController *browser = [[MediaBrowserViewController alloc] init];
    NSMutableArray *sourceItems = [NSMutableArray array];
    [self.dataSource enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL * _Nonnull stop) {
        QMUIButton *button = [self.floatLayoutView.subviews objectAtIndex:idx];
        MediaBrowserImageEntity *entity = [[MediaBrowserImageEntity alloc] initWithSourceView:button
                                                                                   sourceRect:CGRectZero
                                                                                   thumbImage:[button imageForState:UIControlStateNormal]];
        entity.imageUrl = [NSURL URLWithString:urlString];
        entity.sourceCornerRadius = button.layer.cornerRadius;
        [sourceItems addObject:entity];
    }];
    browser.sourceItems = sourceItems;
    browser.browserView.currentPage = [self.floatLayoutView.subviews indexOfObject:sender];
    [browser showFromViewController:self animated:YES completion:nil];
}

@end
