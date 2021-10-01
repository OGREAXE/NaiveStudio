//
//  NCInterpreterController.h
//  NaiveC
//
//  Created by Liang,Zhiyuan(GIS) on 2017/12/25.
//  Copyright © 2017年 Ogreaxe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NCDataSource.h"
//#import <NaiveC/NCCodeEngine_iOS.h>
#import "NCCodeEngine_iOS.h"
#import "NCProject.h"

@class NCScriptInterpreter;

@protocol NCInterpreterControllerDelegate<NSObject>

-(void)interpreterController:(NCScriptInterpreter*)controller didFinishParsingDataSource:(NCDataSource*)dataSource WithParser:(void*)parser;

//-(void)didFinishParsing:(NCInterpreterController*)controller;

@end

@interface NCScriptInterpreter : NSObject<NCDataSourceDelegate>

@property (nonatomic) id<NCInterpreterControllerDelegate> delegate;

@property (nonatomic) NCInterpretorMode mode;

@property (nonatomic) NCProject * project;

-(BOOL)reinterprete;

-(BOOL)runProject;

-(BOOL)runWithDataSource:(NCDataSource*)source;

-(BOOL)runWithCode:(NSString*)code;

-(BOOL)reparse;

-(void)markDirty:(NSString*)filename;

@end
