//
//  NDIntroPageView.m
//  NDParallaxIntroView
//
//  Created by Simon Wicha on 17/04/2016.
//  Copyright © 2016 Simon Wicha. All rights reserved.
//

#import "NDIntroView.h"
#import "NDIntroPageView.h"

@interface NDIntroView () <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIScrollView *parallaxBackgroundScrollView;

@property (strong, nonatomic) NSMutableArray<UIView *> *pageViews;
@property (strong, nonatomic) NSArray <NSDictionary*> *onboardContentArray;

@end

@implementation NDIntroView

- (id)initWithFrame:(CGRect)frame parallaxImage:(UIImage *)parallaxImage andData:(NSArray *)data {
    self = [super initWithFrame:frame];
    if(self) {
        self.onboardContentArray = data;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-50, 0, self.scrollView.frame.size.width * self.onboardContentArray.count, self.frame.size.height)];
        [imageView setImage:parallaxImage];
//        imageView.contentMode = UIViewContentModeScaleAspectFill;
//        imageView.layer.masksToBounds = YES;
        [self.parallaxBackgroundScrollView addSubview:imageView];
        
        [self addSubview:self.parallaxBackgroundScrollView];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        
        [self generateIntroPageViews];
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = CGRectGetWidth(self.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
    CGFloat backgroundScrollValue = 0.5f;//self.backgroundImage.size.width/self.onboardContentArray.count/self.frame.size.width;
    [self.parallaxBackgroundScrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x  * backgroundScrollValue, self.scrollView.contentOffset.y) animated:YES];
    
    
//    NSLog(@"scrollview, %f", self.scrollView.frame.size.width);
//    NSLog(@"parallaxscrollview, %f", self.parallaxBackgroundScrollView.frame.size.width);
    
//    CGFloat diffFromCenter = ABS(scrollView.contentOffset.x - (self.pageControl.currentPage) * self.scrollView.frame.size.width);
//    CGFloat currentPageAlpha = 1.0 - diffFromCenter / self.scrollView.frame.size.width;
//    CGFloat sidePagesAlpha = diffFromCenter / self.scrollView.frame.size.width;
    
//    NSLog(@"contentOffset, %f", scrollView.contentOffset.x);
//    NSLog(@"diffFromCenter, %f", diffFromCenter);
//    NSLog(@"currentPageAlpha, %f", currentPageAlpha);
//    NSLog(@"sidePagesAlpha, %f", sidePagesAlpha);
    
//    [self.scrollView setAlpha:currentPageAlpha];
    
    
//    [self.scrollView setAlpha:0.7];
    
//    NDIntroPageView *currentView = (NDIntroPageView *) self.scrollView.subviews[0];
//    NDIntroPageView *currentView1 = (NDIntroPageView *) self.scrollView.subviews[1];
//    NDIntroPageView *currentView2 = (NDIntroPageView *) self.scrollView.subviews[2];
//    NDIntroPageView *currentView3 = (NDIntroPageView *) self.scrollView.subviews[3];
//    
//    [currentView setAlpha:0.2];
//    [currentView1 setAlpha:0.4];
//    [currentView2 setAlpha:0.5];
//    [currentView3 setAlpha:0.7];
    
}





- (void)generateIntroPageViews {
    [self.onboardContentArray enumerateObjectsUsingBlock:^(NSDictionary *pageDict, NSUInteger idx, BOOL *stop) {
        NDIntroPageView *pageView = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"NDIntroPageView" owner:nil options:nil] lastObject];
        pageView.frame = CGRectMake(self.frame.size.width * idx, 0, self.frame.size.width, self.frame.size.height);
        pageView.titlelabel.text = (pageDict[kNDIntroPageTitle]) ? pageDict[kNDIntroPageTitle] : @"nil";
        pageView.descriptionLabel.text = (pageDict[kNDIntroPageDescription]) ? pageDict[kNDIntroPageDescription] : @"";
        pageView.imageView.image = [[UIImage imageNamed:(pageDict[kNDIntroPageImageName]) ? pageDict[kNDIntroPageImageName] : @""] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        pageView.imageHorizontalConstraint.constant = ([pageDict[kNDIntroPageImageHorizontalConstraintValue] floatValue]) ? [pageDict[kNDIntroPageImageHorizontalConstraintValue] floatValue] : 0.f;
        pageView.titleLabelHeightConstraint.constant = ([pageDict[kNDIntroPageTitleLabelHeightConstraintValue] floatValue]) ? [pageDict[kNDIntroPageTitleLabelHeightConstraintValue] floatValue] : 80.f;
        if (self.onboardContentArray.count - 1 == idx) [pageView addSubview:self.lastPageButton];
        [self.scrollView addSubview:pageView];
    }];
}

-(UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(self.frame.size.width * self.onboardContentArray.count, self.scrollView.frame.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return _scrollView;
}

-(UIScrollView *)parallaxBackgroundScrollView {
    if (!_parallaxBackgroundScrollView) {
        _parallaxBackgroundScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        _parallaxBackgroundScrollView.delegate = self;
        _parallaxBackgroundScrollView.pagingEnabled = YES;
        _parallaxBackgroundScrollView.userInteractionEnabled = NO;
        _parallaxBackgroundScrollView.contentSize = CGSizeMake(self.frame.size.width*4, self.scrollView.frame.size.height);
        _parallaxBackgroundScrollView.showsHorizontalScrollIndicator = NO;
        [_parallaxBackgroundScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    return _parallaxBackgroundScrollView;
}

-(UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height-22, self.frame.size.width, 10)];
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.numberOfPages = self.onboardContentArray.count;
    }
    return _pageControl;
}

-(UIButton *)lastPageButton {
    if (!_lastPageButton) {
        _lastPageButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.3, self.frame.size.height * 0.18, self.frame.size.width * 0.4, 40)];
        _lastPageButton.layer.cornerRadius = 5.f;
        _lastPageButton.tintColor = [UIColor whiteColor];
        _lastPageButton.backgroundColor = [UIColor colorWithRed:0.f/255.f green:214.f/235.f blue:196.f/255.f alpha:1.f];
        [_lastPageButton setTitle:@"Start Using App!" forState:UIControlStateNormal];
        [_lastPageButton.titleLabel setFont:[UIFont fontWithName:@"TrebuchetMS" size:18.0]];
        [_lastPageButton addTarget:self.delegate action:@selector(launchAppButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lastPageButton;
}

@end
