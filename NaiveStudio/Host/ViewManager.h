//
//  ViewManager.h
//  NaiveStudio
//
//  Created by liangzhiyuan on 2021/9/29.
//  Copyright © 2021 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ViewManager : NSObject

+ (instancetype)sharedManager;

- (void)beginLockScreenMode;

- (void)exitLockScreenMode;

@end

NS_ASSUME_NONNULL_END
