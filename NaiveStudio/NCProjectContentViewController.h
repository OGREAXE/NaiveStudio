//
//  NCProjectContentViewController.h
//  NaiveC
//
//  Created by 梁志远 on 31/12/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCScriptInterpreter.h"

@class NCProject;

@interface NCProjectContentViewController : UIViewController
@property  (nonatomic) NCProject * project;
@property (nonatomic) NCInterpretorMode mode;
@end
