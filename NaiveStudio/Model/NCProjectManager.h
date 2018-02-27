//
//  NCProjectManager.h
//  NaiveC
//
//  Created by 梁志远 on 31/12/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCProject.h"

@interface NCProjectManager : NSObject

+(instancetype)sharedManager;

@property (nonatomic) NSString * rootPath;

-(NCProject*)defaultProject;


/**
 get playground
 */
@property (nonatomic) NCPlayground * playground;
-(BOOL)playgroundExist;
-(void)createPlayground;

-(void)createProjct:(NSString*)name properties:(NSDictionary*)properties;

-(BOOL)removeSourceFile:(NCSourceFile*)file project:(NCProject*)project error:(NSError**)error;

-(NCSourceFile*)createSourceFile:(NSString*)name project:(NCProject*)project error:(NSError**)error;

-(void)onAppFirstLaunch;

@end
