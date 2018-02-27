//
//  NCAddNewFileViewController.h
//  NaiveC
//
//  Created by 梁志远 on 01/01/2018.
//  Copyright © 2018 Ogreaxe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCProjectManager.h"

@class NCAddNewFileViewController;
@class NCEditorViewController;

@protocol NCAddNewFileViewControllerDelegate<NSObject>

-(void)addNewFileViewController:(NCAddNewFileViewController*)addNewController willPushtoEditController:(NCEditorViewController*)editController;

@end

@interface NCAddNewFileViewController : UIViewController
@property (nonatomic) NCProject * currentProject;
@property (nonatomic,weak) id<NCAddNewFileViewControllerDelegate> delegate;
@end
