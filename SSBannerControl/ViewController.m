//
//  ViewController.m
//  SSBannerControl
//
//  Created by lihong on 15/11/24.
//  Copyright © 2015年 李红(lh.coder@foxmail.com). All rights reserved.
//

#import "SSBannerControl.h"
#import "ViewController.h"

@interface ItemData : NSObject <SSBannerControlDataItem>
@property (nonatomic) NSURL *url;
@property (nonatomic) NSString *caption;
+ (instancetype)dataWithUrlString:(NSString *)urlString caption:(NSString *)caption;
@end

@implementation ItemData
+ (instancetype)dataWithUrlString:(NSString *)urlString caption:(NSString *)caption {
    ItemData *obj = [ItemData new];
    obj.caption = caption;
    obj.url = [NSURL URLWithString:urlString];
    return obj;
}
@end

@interface ViewController ()<SSBannerControlActionHandler>
@end

@implementation ViewController {
    SSBannerControl *_ssBannerControl;
    NSMutableArray<id<SSBannerControlDataItem>> *_datasource;
    NSMutableDictionary *_dataCache;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url0 = [[NSBundle mainBundle] URLForResource:@"banner0" withExtension:@"jpg"];
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"banner1" withExtension:@"jpg"];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:@"banner2" withExtension:@"jpg"];
    
    _dataCache = [NSMutableDictionary dictionary];
    _datasource = [NSMutableArray array];
    [_datasource addObject:[ItemData dataWithUrlString:url0.absoluteString caption:@"大黑狗"]];
    [_datasource addObject:[ItemData dataWithUrlString:url1.absoluteString caption:@"小白狗"]];
    [_datasource addObject:[ItemData dataWithUrlString:url2.absoluteString caption:@"小黑狗"]];
    
    _ssBannerControl = [[SSBannerControl alloc] init];
    _ssBannerControl.delegate = self;
    _ssBannerControl.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_ssBannerControl];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _ssBannerControl.frame = CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width/2.0);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_ssBannerControl reload:_datasource];
}

#pragma mark - SSBannerControlActionHandler
- (void)ssBannerControl:(SSBannerControl *)bannerControl requestImageData:(id<SSBannerControlDataItem>)item forView:(UIImageView *)imageView {
    UIImage *cacheImage = [_dataCache objectForKey:item.url.absoluteString];
    if (cacheImage) {
        imageView.image = cacheImage;
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:item.url];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
            [_dataCache setObject:image forKey:item.url.absoluteString];
        });
    });
}

- (void)ssBannerControl:(SSBannerControl *)bannerControl didScrollToIndex:(NSUInteger)index {
    id<SSBannerControlDataItem> item = [_datasource objectAtIndex:index];
    NSLog(@"ScrollTo:%@",item.caption);
}

- (void)ssBannerControl:(SSBannerControl *)bannerControl didTouchAtIndex:(NSUInteger)index {
    id<SSBannerControlDataItem> item = [_datasource objectAtIndex:index];
    NSLog(@"TouchOn:%@",item.caption);
}
@end