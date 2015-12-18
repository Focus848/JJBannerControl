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

- (void)doInitWork {
    _interval = 3.0;
    _prevIndex = 0;
    _currIndex = 0;
    _nextIndex = 0;
    _dataItemList = [NSMutableArray array];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];

    _prevImageView = [[UIImageView alloc] init];
    _currImageView = [[UIImageView alloc] init];
    _nextImageView = [[UIImageView alloc] init];
    [_scrollView addSubview:_prevImageView];
    [_scrollView addSubview:_currImageView];
    [_scrollView addSubview:_nextImageView];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOnPage:)]];
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    _scrollView.frame = CGRectMake(0, 0, size.width, size.height);
    _scrollView.contentSize = CGSizeMake(3 * size.width, size.height);
    
    _prevImageView.frame = CGRectMake(0, 0, size.width, size.height);
    _currImageView.frame = CGRectMake(size.width, 0, size.width, size.height);
    _nextImageView.frame = CGRectMake(2 * size.width, 0, size.width, size.height);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self layoutIfNeeded];
}

#pragma mark - api
- (void)reload:(NSArray<id<SSBannerControlDataItemProtocol>> *)dataItemList {
    NSAssert(self.delegate, @"Must set delegate!");
    if (!dataItemList) return;
    [_dataItemList removeAllObjects];
    [_dataItemList addObjectsFromArray:dataItemList];
    
    // 加载初始数据
    _currIndex = 0;
    _prevIndex = (_dataItemList.count > 1) ? (_dataItemList.count - 1) : 0;
    _nextIndex = (_dataItemList.count > 1) ? 1: 0;
    [self loadItemData:_prevIndex onPage:kPrevPage];
    [self loadItemData:_currIndex onPage:kCurrPage];
    [self loadItemData:_nextIndex onPage:kNextPage];
    
    CGSize size = _scrollView.bounds.size;
    [_scrollView scrollRectToVisible:CGRectMake(size.width, 0, size.width, size.height) animated:NO];
    if (_delegate && [_delegate respondsToSelector:@selector(ssBannerControl:didScrollToIndex:)]) {
        [_delegate ssBannerControl:self didScrollToIndex:_currIndex];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAutoScroll) object:nil];
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
    if (_delegate &&[ _delegate respondsToSelector:@selector(ssBannerControl:didScrollToIndex:)]) {
        [_delegate ssBannerControl:self didScrollToIndex:_currIndex];
    }
}

- (void)loadItemData:(NSUInteger)itemDataIndex onPage:(NSUInteger)pageIndex {
    if (itemDataIndex >= _dataItemList.count) return;
    NSDictionary *imageViewDict = @{@(kPrevPage):_prevImageView,@(kCurrPage):_currImageView,@(kNextPage):_nextImageView};
    UIImageView *imageView = [imageViewDict objectForKey:@(pageIndex)];
    if (imageView && _delegate && [_delegate respondsToSelector:@selector(ssBannerControl:requestImageData:forView:)]){
        id<SSBannerControlDataItemProtocol> item = [_dataItemList objectAtIndex:itemDataIndex];
        [_delegate ssBannerControl:self requestImageData:item forView:imageView];
    }
}

#pragma mark - Touch event
- (void)touchOnPage:(UITapGestureRecognizer *)tapGesture {
    if (_delegate && [_delegate respondsToSelector:@selector(ssBannerControl:didTouchAtIndex:)]) {
        [_delegate ssBannerControl:self didTouchAtIndex:_currIndex];
    }
}
@end



