//
//  NCBuiltinManager.m
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS)2 on 24/8/18.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCBuiltinManager.h"
#import <UIKit/UIKit.h>
#include "NCBuiltinFunction.hpp"
#include "NCModuleCache.hpp"

class NCBuiltinGetAdaptorValue :public NCBuiltinFunction{
public:
    NCBuiltinGetAdaptorValue();
    
    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments,vector<shared_ptr<NCStackElement>> & lastStack);
    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments);
};

/*
 get adaptor value
 */
//BNAVI_ADAPTOR_VALUE_$$()宏直接将转换设计师的标注值转为手机屏幕上的实际值, $$为设计师所给设计稿的实际宽度(默认为1080)
#define PHONE_SIZE      ([UIScreen mainScreen].bounds.size)
#define PHONE_WIDTH    MIN(PHONE_SIZE.width,PHONE_SIZE.height) //横屏时也使用竖屏时宽度
#define BNAVI_ADAPTOR_VALUE(_VALUE_)   (int)(((float)PHONE_WIDTH/1080)*(_VALUE_) + 0.5)
#define BNAVI_ADAPTOR_VALUE_640(_VALUE_)   (int)(((float)PHONE_WIDTH/640)*(_VALUE_) + 0.5)
#define BNAVI_ADAPTOR_VALUE_750(_VALUE_)   (int)(((float)PHONE_WIDTH/750)*(_VALUE_) + 0.5)
#define BNAVI_ADAPTOR_VALUE_1242(_VALUE_)   (int)(((float)PHONE_WIDTH/1242)*(_VALUE_) + 0.5)

NCBuiltinGetAdaptorValue::NCBuiltinGetAdaptorValue(){
    name = "getAdaptorValue";
    parameters.push_back(shared_ptr<NCParameter>(new NCParameter("float","markWidth")));
    parameters.push_back(shared_ptr<NCParameter>(new NCParameter("float","markValue")));
}

bool NCBuiltinGetAdaptorValue::invoke(vector<shared_ptr<NCStackElement>> &arguments){
    
    return true;
}

bool NCBuiltinGetAdaptorValue::invoke(vector<shared_ptr<NCStackElement>> &arguments,vector<shared_ptr<NCStackElement>> & lastStack){
    auto markwidth = arguments[0]->toFloat();
    auto markvalue = arguments[1]->toFloat();
    
    if (markwidth <= 0) {
        lastStack.push_back(shared_ptr<NCStackElement>(new NCStackFloatElement(0)));
        return false;
    }
    
    float ret = (int)(((float)PHONE_WIDTH/markwidth)*(markvalue) + 0.5);
    lastStack.push_back(shared_ptr<NCStackElement>(new NCStackFloatElement(ret)));
    return true;
}

@implementation NCBuiltinManager

+(void)addAll{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.class addAll_private];
    });
}

+(void)addAll_private{
    auto fGetAdaptorValue = shared_ptr<NCBuiltinFunction>(new NCBuiltinGetAdaptorValue());
    NCModuleCache::GetGlobalCache()->addSystemFunction(fGetAdaptorValue);
}

@end
