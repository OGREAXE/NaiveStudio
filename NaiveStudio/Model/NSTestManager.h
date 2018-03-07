//
//  NSTestManager.h
//  NaiveStudio
//
//  Created by 梁志远 on 07/03/2018.
//  Copyright © 2018 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTestManager : NSObject
+(instancetype)sharedInstance;
-(void)dispatch:(void(^)(int))block;
@end
