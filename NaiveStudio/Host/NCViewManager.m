//
//  ViewManager.m
//  NaiveStudio
//
//  Created by liangzhiyuan on 2021/9/29.
//  Copyright © 2021 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCViewManager.h"
#import "NCServerManager.h"
#import "NCScriptManager.h"

@class TapDetectView;

@interface NCViewManager ()

@property (nonatomic) TapDetectView *tapdectView;

@property (nonatomic, weak) UIView *selectedView;

- (void)viewIsSelected:(UIView *)view;

- (UIView *)queryViewByPostion:(CGPoint)point view:(UIView *)p;

@end

UIView *getRootView(){
    return [UIApplication sharedApplication]
        .delegate
        .window
        .rootViewController
        .view;
}

@interface TapDetectView : UIView
@property (nonatomic) UIView *targetView;
@end

@implementation TapDetectView

- (id)init {
    self = [super init];
    [self commonInit];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

- (void)commonInit {
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(didTapView:)]];
}

- (void)didTapView:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    
    UIView *root = getRootView();
    UIView *hit = [[NCViewManager sharedManager] queryViewByPostion:point view:root];
    
    if (hit) {
        NSLog(@"hit view %@", hit);
        
        if (!_targetView) {
            _targetView = [[UIView alloc] initWithFrame:hit.frame];
            _targetView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
            [self addSubview:_targetView];
        }
        
        _targetView.hidden = NO;
        _targetView.frame = [hit.superview convertRect:hit.frame toView:self];
        
        [[NCViewManager sharedManager] viewIsSelected:hit];
    } else {
        _targetView.hidden = YES;
    }
}

/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *root = getRootView();
    UIView *hit = [[ViewManager sharedManager] queryViewByPostion:point view:root];
    
    if (hit) {
        NSLog(@"hit view %@", hit);
        
        if (!_targetView) {
            _targetView = [[UIView alloc] initWithFrame:hit.frame];
            _targetView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
            [self addSubview:_targetView];
        }
        
        _targetView.hidden = NO;
        _targetView.frame = [hit.superview convertRect:hit.frame toView:self];
        
        [[ViewManager sharedManager] viewIsSelected:hit];
    } else {
        _targetView.hidden = YES;
    }
    
    return self;
}
 */

@end

@implementation NCViewManager

+ (instancetype)sharedManager {
    static NCViewManager *sharedManager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)beginLockScreenMode {
    [_tapdectView removeFromSuperview];
    _tapdectView = [[TapDetectView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *root = getRootView();
    [root addSubview:_tapdectView];
}

- (void)viewIsSelected:(UIView *)view {
    
    self.selectedView = view;
    
    NSString *cmd = [NCScriptManager statementOfGetObjectWithObject:view];
    
    [[NCServerManager sharedManager] writeToClientWithContent:cmd
                                                     metaData:@{
        WRITE_CLIENT_CONTENT_TYPE_KEY:@(NCWriteToClientContentTypeOverrideInput)
    }];
}

- (void)exitLockScreenMode {
    [_tapdectView removeFromSuperview];
}

- (BOOL)viewVisible:(UIView *)view {
    if (view.alpha <= 0 || view.hidden) {
        return NO;
    }
    
    //check if has no child and background is clear
    
    BOOL isUserDefinedClass = NO;
    NSString *viewClassName = NSStringFromClass(view.class);
    if (![viewClassName hasPrefix:@"UI"]) {
        isUserDefinedClass = YES;
    }
    
    if (isUserDefinedClass && (!view.backgroundColor || view.backgroundColor == [UIColor clearColor])) {
        if (view.subviews.count <= 0) {
            return NO;
        }
    }
    
    if ([view isKindOfClass:UIScrollView.class]) {
        if (!view.backgroundColor || view.backgroundColor == [UIColor clearColor]) {
            return NO;
        }
    }
    
    return YES;
}

- (UIView *)queryViewByPostion:(CGPoint)point view:(UIView *)p{
    UIView *ret = nil;
        UIView *ancestorOfFound = nil;
        
        for (UIView *subview in p.subviews) {
            if ([subview isKindOfClass:TapDetectView.class]) {
                continue;
            }
            
            CGPoint subViewLocalPoint = [p convertPoint:point toView:subview];
            
            UIView *found = [self queryViewByPostion:subViewLocalPoint view:subview];
            
            if (found && [self viewVisible:found]) {
                ret = found;
                ancestorOfFound = subview;
            }
        }
        
        if (!ret) {
            if (CGRectContainsPoint(p.bounds, point)) {
                ret = p;
            }
        }

        return ret;
}

@end
