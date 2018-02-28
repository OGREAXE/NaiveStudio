//
//  NaiveStudio.h
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS) on 2018/2/27.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCMainViewController.h"

@interface NaiveStudio : NSObject

+(id)sharedInstance;

-(NCMainViewController*)mainViewController;
-(UINavigationController*)navigationControllerWithMainViewController;

@end
