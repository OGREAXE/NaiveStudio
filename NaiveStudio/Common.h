//
//  Common.h
//  NaiveC
//
//  Created by Liang,Zhiyuan(GIS) on 2017/12/26.
//  Copyright © 2017年 Ogreaxe. All rights reserved.
//

#ifndef Common_h
#define Common_h

#include "NCConsole.h"
#import <Foundation/Foundation.h>
#import "UIViewController+NCExtension.h"

#define SAFE_RELEASE(p) if(p){delete p;p=nullptr;}

#define MainStoryBoardName @"NaiveStudio"

#define NCPrintContentFromEngineNotification @"NCPrintStringNotification"

//appears in the meta data that server writes back to client

#define WRITE_CLIENT_CONTENT_TYPE_KEY @"contentType"
#define WRITE_CLIENT_TEXT_COLOR_KEY @"textColor"

typedef NS_ENUM(NSInteger, NCWriteToClientContentType) {
    NCWriteToClientContentTypeFromEngine = 0,          // default, display in client output window
    NCWriteToClientContentTypeOverrideInput,       //  ask client to display in input window
};

#endif /* Common_h */
