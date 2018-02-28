//
//  NCProjectManager.m
//  NaiveC
//
//  Created by 梁志远 on 31/12/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#import "NCProjectManager.h"

@implementation NCProjectManager

+(instancetype)sharedManager{
    static NCProjectManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NCProjectManager alloc] init];
    });
    return instance;
}

-(NCProject*)defaultProject{
    NCProject * project = [[NCProject alloc] initWithRoot:[NSString stringWithFormat:@"%@/Documents/projects/project0/",NSHomeDirectory()]];
    return project;
}

#define PLAYGROUND_PROJ_NAME @"playground"

-(NCPlayground*)playground{
    NCPlayground * project = [[NCPlayground alloc] initWithRoot:[NSString stringWithFormat:@"%@/%@/",self.rootPath,PLAYGROUND_PROJ_NAME]];
    return project;
}

-(BOOL)playgroundExist{
    NSString *documentsDirectoryPath = self.rootPath;
    
    NSString * playgroundDir = [documentsDirectoryPath stringByAppendingPathComponent:PLAYGROUND_PROJ_NAME];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:playgroundDir];
}

-(void)createPlayground{
    NSString *documentsDirectoryPath = self.rootPath;
    
    if (!documentsDirectoryPath) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [NCProjectManager sharedManager].rootPath = path;
        documentsDirectoryPath = self.rootPath;
    }
    
    NSString * playgroundDir = [documentsDirectoryPath stringByAppendingPathComponent:PLAYGROUND_PROJ_NAME];
    
    NSError * error = nil;
    
    if(![[NSFileManager defaultManager] createDirectoryAtPath:playgroundDir withIntermediateDirectories:NO attributes:nil error:&error]){
        NSLog(@"create project folder at didFinishLaunchingWithOptions error, %@",error);
    }
}

-(void)createProjct:(NSString*)name properties:(NSDictionary*)properties{
    
}

-(BOOL)removeSourceFile:(NCSourceFile*)file project:(NCProject*)project error:(NSError**)error{
    [[NSFileManager defaultManager] removeItemAtPath:file.filepath error:error];
    if (*error) {
        return NO;
    }
    [project reload];
    return YES;
}

-(NCSourceFile*)createSourceFile:(NSString*)filename project:(NCProject*)project error:(NSError**)error{
    NSString * projectPath = project.rootDirectory;
    NSString * filepath = [projectPath stringByAppendingPathComponent:filename];
    
    [@"" writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:error];
    if (*error) {
        NSLog(@"write file fail: %@",*error);
        return nil;
    }
    
    NCSourceFile * file = [[NCSourceFile alloc] init];
    file.filename = filename;
    file.filepath = filepath;
    return file;
}

-(NSString*)createProjectsDirectory{
    NSString *documentsDirectoryPath = self.rootPath;
    
    NSString * projectDir = [documentsDirectoryPath stringByAppendingPathComponent:@"projects"];
    
    NSError * error = nil;
    
    if(![[NSFileManager defaultManager] createDirectoryAtPath:projectDir withIntermediateDirectories:NO attributes:nil error:&error]){
        NSLog(@"create project folder at didFinishLaunchingWithOptions error, %@",error);
    }
    return projectDir;
}

-(void)onAppFirstLaunch{
    //copy a sample file to /Document/projects/project0/
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * projectsDir = [self createProjectsDirectory];
    
    NSString * projectDir = [projectsDir stringByAppendingPathComponent:@"project0"];
    NSError * error = nil;
    
    if(![[NSFileManager defaultManager] createDirectoryAtPath:projectDir withIntermediateDirectories:NO attributes:nil error:&error]){
        NSLog(@"create project0 folder at didFinishLaunchingWithOptions error, %@",error);
    }
    
    //copy example
     NSString * fromfilepath = [[NSBundle mainBundle] pathForResource:@"CodeTest" ofType:nil];
    NSString * tofilepath = [projectDir stringByAppendingPathComponent:@"helloworld"];
   
    if(![[NSFileManager defaultManager] copyItemAtPath:fromfilepath toPath:tofilepath error:&error]){
        NSLog(@"copy sample file at didFinishLaunchingWithOptions error, %@",error);
    }
    
    /////////
    NSArray * files = [[NSFileManager defaultManager]  contentsOfDirectoryAtPath:projectDir error:&error];
    
    if (error) {
        NSLog(@"error project folders not exists");
    }
    [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"_________%@",obj);
    }];
}

@end
