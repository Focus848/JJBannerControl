//
//  SSBannerControl.h
//  SSBannerControl
//
//  Created by sunshine on 15/11/24.
//  Copyright © 2015年 李红(lh.coder@foxmail.com). All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSBannerControlDataItemProtocol,SSBannerControlDelegate;

/// 滚动方向
typedef NS_ENUM(NSInteger,SSBannerControlScrollDirection){
    SSBannerControlScrollDirectionRightLeft = 0, ///< 从右向左滚动,默认为这种方式.
    SSBannerControlScrollDirectionLeftRight = 1, ///< 从左向右滚动
    SSBannerControlScrollDirectionTopBottom = 2, ///< 从上到下滚动
    SSBannerControlScrollDirectionBottomTop = 3  ///< 从下到上滚动
};

/* SSBannerControl 是一个提供无限循环滚动的控件。
 * 原理:http://iosdevelopertips.com/user-interface/creating-circular-and-infinite-uiscrollviews.html
 */
@interface SSBannerControl : UIControl
@property (nonatomic, weak) id <SSBannerControlDelegate> delegate; ///< 代理
- (void)reload:(NSArray<id<SSBannerControlDataItemProtocol>> *)dataItemList;
@end


@protocol SSBannerControlDataItemProtocol <NSObject>
@property (nonatomic) NSURL *url; ///< 图片地址
@end

@protocol SSBannerControlDelegate <NSObject>
/// 由外部处理图像下载、缓存,SSBannerControl的核心功能是提供一个无线循环滚动.
- (void)ssBannerControl:(SSBannerControl *)bannerControl requestImageData:(id<SSBannerControlDataItemProtocol>)item forView:(UIImageView *)imageView;
@optional
- (void)ssBannerControl:(SSBannerControl *)bannerControl didScrollToIndex:(NSUInteger)index;
- (void)ssBannerControl:(SSBannerControl *)bannerControl didTouchAtIndex:(NSUInteger)index;
@end



