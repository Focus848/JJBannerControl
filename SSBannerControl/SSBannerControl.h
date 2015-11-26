//
//  SSBannerControl.h
//  SSBannerControl
//
//  Created by sunshine on 15/11/24.
//  Copyright © 2015年 李红(lh.coder@foxmail.com). All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSBannerControlDataItem,SSBannerControlActionHandler;

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
@property (nonatomic, weak) id <SSBannerControlActionHandler> delegate; ///< 代理
- (void)reload:(NSArray<id<SSBannerControlDataItem>> *)itemDataList;
@end

@protocol SSBannerControlDataItem <NSObject>
@required
@property (nonatomic) NSURL *url; ///< 图片地址
@property (nonatomic) NSString *caption; ///< 标题
@end

@protocol SSBannerControlActionHandler <NSObject>
@optional
- (void)ssBannerControl:(SSBannerControl *)bannerControl didScrollToIndex:(NSUInteger)index;
- (void)ssBannerControl:(SSBannerControl *)bannerControl didTouchAtIndex:(NSUInteger)index;
@required
- (void)ssBannerControl:(SSBannerControl *)bannerControl requestImageData:(id<SSBannerControlDataItem>)item forView:(UIImageView *)imageView;
@end