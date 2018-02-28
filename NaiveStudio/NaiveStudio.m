//
//  NaiveStudio.m
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS) on 2018/2/27.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NaiveStudio.h"

#import <UIKit/UIKit.h>

static NaiveStudio *_instance = NULL;

@implementation NaiveStudio

+(id)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NaiveStudio alloc] init];
    });
    return _instance;
}

-(NCMainViewController*)mainViewController{
    NCMainViewController * mainVC = [[UIStoryboard storyboardWithName:@"NaiveStudio" bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:NSStringFromClass(NCMainViewController.class)];
    return mainVC;
}

-(UINavigationController*)navigationControllerWithMainViewController{
    NCMainViewController * mainVC = [self mainViewController];
    mainVC.isPresented = TRUE;
    UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:mainVC];
    return navi;
}


@end
