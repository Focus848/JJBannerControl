//
//  SSBannerControl.m
//  SSBannerControl
//
//  Created by sunshine on 15/11/24.
//  Copyright © 2015年 李红(lh.coder@foxmail.com). All rights reserved.
//

#import "SSBannerControl.h"

#define kPrevPage (0)
#define kCurrPage (1)
#define kNextPage (2)

@interface SSBannerControl()<UIScrollViewDelegate>
@end

@implementation SSBannerControl {
    NSTimeInterval _interval;
    NSUInteger _prevIndex, _currIndex, _nextIndex;
    NSMutableArray<id<SSBannerControlDataItemProtocol>> *_dataItemList;
    UIScrollView *_scrollView;
    UIImageView *_prevImageView, *_currImageView, *_nextImageView;
    UITapGestureRecognizer *_tapGestureRecognizer;
    BOOL _isCancelPreviousPerformRequests;
}

#pragma mark - init
- (instancetype)init {
    if (self = [super init]) {
        [self doInitWork];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self doInitWork];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self doInitWork];
    }
    return self;
}

/** 初始化 */
- (void)doInitWork {
    [self setupVars];
    [self setupScrollView];
    [self setupImageView];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOnPage:)];
    [self addGestureRecognizer:_tapGestureRecognizer];
}

/** 初始化变量*/
- (void)setupVars {
    _interval = 6.0;
    _prevIndex = 0;
    _currIndex = 0;
    _nextIndex = 0;
    _dataItemList = [NSMutableArray array];
}

/** 添加ScrollView */
- (void)setupScrollView {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    [self layoutScrollView];
}

/** 添加ImageView */
- (void)setupImageView {
    _prevImageView = [[UIImageView alloc] init];
    _currImageView = [[UIImageView alloc] init];
    _nextImageView = [[UIImageView alloc] init];
    [_scrollView addSubview:_prevImageView];
    [_scrollView addSubview:_currImageView];
    [_scrollView addSubview:_nextImageView];
    
    [self layoutImageViews];
}

/** 移除ImageView */
- (void)unsetupllImageView {
    [_prevImageView removeFromSuperview];
    [_currImageView removeFromSuperview];
    [_nextImageView removeFromSuperview];
}

/** 布局ScrollView */
- (void)layoutScrollView {
    CGSize size = self.bounds.size;
    _scrollView.frame = CGRectMake(0, 0, size.width, size.height);
    _scrollView.contentSize = CGSizeMake(3 * size.width, size.height);
}

/** 布局ImageView */
- (void)layoutImageViews {
    CGSize size = self.bounds.size;
    _prevImageView.frame = CGRectMake(0, 0, size.width, size.height);
    _currImageView.frame = CGRectMake(size.width, 0, size.width, size.height);
    _nextImageView.frame = CGRectMake(2 * size.width, 0, size.width, size.height);
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutScrollView];
    [self layoutImageViews];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self layoutIfNeeded];
}

#pragma mark - api
- (void)reload:(NSArray<id<SSBannerControlDataItemProtocol>> *)dataItemList {
    NSAssert(self.delegate, @"Must set delegate!");
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAutoScroll) object:nil];
    
    if (!dataItemList) return;
    [_dataItemList removeAllObjects];
    [_dataItemList addObjectsFromArray:dataItemList];
    
    static BOOL needSetupImageViews = NO;
    if (_dataItemList.count == 0) {
        [self unsetupllImageView];
        needSetupImageViews = YES;
        return;
    } if (needSetupImageViews) {
        [self setupImageView];
    }
    
    // 加载初始数据
    _currIndex = 0;
    _prevIndex = (_dataItemList.count > 1) ? (_dataItemList.count - 1) : 0;
    _nextIndex = (_dataItemList.count > 1) ? 1: 0;
    [self loadItemData:_prevIndex onPage:kPrevPage];
    [self loadItemData:_currIndex onPage:kCurrPage];
    [self loadItemData:_nextIndex onPage:kNextPage];
    
    CGSize size = _scrollView.bounds.size;
    [_scrollView scrollRectToVisible:CGRectMake(size.width, 0, size.width, size.height) animated:NO];
    [_delegate ssBannerControl:self didScrollToIndex:_currIndex];
    
    [self performSelector:@selector(startAutoScroll) withObject:nil afterDelay:_interval];
}

#pragma mark - atuo scroll
- (void)startAutoScroll {
    CGSize size = _scrollView.bounds.size;
    // 这是要使用动画,scrollViewDidEndScrollingAnimation:代理方法才能被调用
    [_scrollView scrollRectToVisible:CGRectMake(size.width*2, 0, size.width, size.height) animated:YES];
    [self performSelector:@selector(startAutoScroll) withObject:nil afterDelay:_interval];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 若是手动滚动,则取消自动滚动
    if (scrollView.tracking || scrollView.dragging) {
        _isCancelPreviousPerformRequests = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAutoScroll) object:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self responseForScroll];
    // 若已取消自动滚动，则恢复自动滚动
    if (_isCancelPreviousPerformRequests) {
        [self performSelector:@selector(startAutoScroll) withObject:nil afterDelay:_interval];
        _isCancelPreviousPerformRequests = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self responseForScroll];
}

- (void)responseForScroll {
    CGSize size = _scrollView.bounds.size;
    // 向左滑动
    if (_scrollView.contentOffset.x > size.width) {
        [self loadItemData:_currIndex onPage:kPrevPage];
        _currIndex = (_currIndex >= _dataItemList.count - 1) ? 0 : (_currIndex + 1);
        [self loadItemData:_currIndex onPage:kCurrPage];
        _nextIndex = (_currIndex >= _dataItemList.count - 1) ? 0 : (_currIndex + 1);
        [self loadItemData:_nextIndex onPage:kNextPage];
    }
    
    // 向右滑动
    if (_scrollView.contentOffset.x < size.width) {
        [self loadItemData:_currIndex onPage:kNextPage];
        _currIndex = (_currIndex == 0) ? (_dataItemList.count - 1) : (_currIndex - 1);
        [self loadItemData:_currIndex onPage:kCurrPage];
        _prevIndex = (_currIndex == 0) ? (_dataItemList.count - 1) : (_currIndex - 1);
        [self loadItemData:_prevIndex onPage:kPrevPage];
    }
    
    [_scrollView scrollRectToVisible:CGRectMake(size.width, 0, size.width, size.height) animated:NO];
    [_delegate ssBannerControl:self didScrollToIndex:_currIndex];
}

- (void)loadItemData:(NSUInteger)itemDataIndex onPage:(NSUInteger)pageIndex {
    if (itemDataIndex >= _dataItemList.count) return;
    id<SSBannerControlDataItemProtocol> item = [_dataItemList objectAtIndex:itemDataIndex];
    switch(pageIndex) {
        case kPrevPage:
            [_delegate ssBannerControl:self requestImageData:item forView:_prevImageView];
            break;
        case kCurrPage:
            [_delegate ssBannerControl:self requestImageData:item forView:_currImageView];
            break;
        case kNextPage:
            [_delegate ssBannerControl:self requestImageData:item forView:_nextImageView];
            break;
        default:break;
    }
}

#pragma mark - Touch event
- (void)touchOnPage:(UITapGestureRecognizer *)tapGesture {
    [_delegate ssBannerControl:self didTouchAtIndex:_currIndex];
}
@end

