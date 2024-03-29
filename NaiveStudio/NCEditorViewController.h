//
//  NCEditorViewController.h
//  NaiveC
//
//  Created by 梁志远 on 16/09/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCProjectManager.h"
#import "NCScriptInterpreter.h"

@interface NCEditorViewController : UIViewController

@property (nonatomic) NCSourceFile * sourceFile;

@property (nonatomic) NCInterpretorMode mode;

@property (nonatomic) NCScriptInterpreter * interpreter;

@end

