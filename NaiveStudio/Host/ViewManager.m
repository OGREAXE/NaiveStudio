//
//  ViewManager.m
//  NaiveStudio
//
//  Created by liangzhiyuan on 2021/9/29.
//  Copyright © 2021 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "ViewManager.h"
#import "NCServerManager.h"
#import "FunctionManager.h"
"
@class TapDetectView;

@interface ViewManager ()

@property (nonatomic) TapDetectView *tdView;

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

@end

@implementation ViewManager

+ (instancetype)sharedManager {
    static ViewManager *sharedManager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)beginLockScreenMode {
    [_tdView removeFromSuperview];
    _tdView = [[TapDetectView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UIView *root = getRootView();
    [root addSubview:_tdView];
}

- (void)viewIsSelected:(UIView *)view {
    NSUInteger address = (NSUInteger)view;
    NSString *cmd = [FunctionManager statementOfGetObjectWithAddress:address];
    
    [[NCServerManager sharedManager] writeToClientWithContent:cmd
                                                     metaData:{
        WRITE_CLIENT_CONTENT_TYPE_KEY:@(NCWriteToClientContentTypeOverrideInput)
    }];
}

- (void)exitLockScreenMode {
    [_tdView removeFromSuperview];
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
