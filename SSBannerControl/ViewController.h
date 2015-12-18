//
//  ViewController.h
//  SSBannerControl
//
//  Created by lihong on 15/11/24.
//  Copyright © 2015年 李红(lh.coder@foxmail.com). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end

@interface SSBannerControlDataItem : NSObject<SSBannerControlDataItemProtocol>
@property (nonatomic) NSURL *url;
@property (nonatomic) NSString *caption;
+ (instancetype)dataItemWihtUrlString:(NSString *)urlString caption:(NSString *)caption;
@end