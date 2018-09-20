//
//  NCInterpreterController.m
//  NaiveC
//
//  Created by Liang,Zhiyuan(GIS) on 2017/12/25.
//  Copyright © 2017年 Ogreaxe. All rights reserved.
//

#import "NCInterpreterController.h"
//#import <NaiveC/NaiveC.h>

#include "Common.h"

@interface NCInterpreterController()

@property (nonatomic) NSMutableDictionary * parserDict;

@property (nonatomic) NCCodeEngine_iOS * codeEngine;

@end

@implementation NCInterpreterController{
//    NCTokenizer *_tokenizer;
//    NCParser * _parser;
//    NCInterpreter * _interpreter;
}

-(id)init{
    self = [super init];
    if (self) {
        [self doInit];
    }
    return self;
}

-(void)doInit{
    _parserDict = [NSMutableDictionary dictionary];
    
    _codeEngine = [[NCCodeEngine_iOS alloc] init];
}

-(void)textDidLoad:(NCDataSource*)dataSource{
//    [self reparseSource:dataSource];
}

//-(NCParser *)reparseSource:(NCDataSource*)dataSource{
//    if (!dataSource.text || dataSource.text.length == 0) {
//        return nil;
//    }
//
//    string str = dataSource.text.UTF8String;
//
//    if (!_tokenizer) {
//        _tokenizer = new NCTokenizer();
//    }
//
//    if (!_tokenizer->tokenize(str)) {
//        NCLog(@"tokenization fail %@");
//        return nil;
//    }
//
//    auto tokens = _tokenizer->getTokens();
//
//    NCParser * parser = [self parserForDataSource:dataSource];
//
//    if(!parser->parse(tokens)){
//        NCLog(@"parse fail %@");
//        return nil;
//    }
//    if ([self.delegate respondsToSelector:@selector(interpreterController:didFinishParsingDataSource:WithParser:)]) {
//        [self.delegate interpreterController:self didFinishParsingDataSource:dataSource WithParser:parser];
//    }
//    return parser;
//}
//
//-(NCParser*)parserForDataSource:(NCDataSource*)dataSource{
//    NCParser * parser = nullptr;
//    NSValue * parserValue = [self.parserDict objectForKey:dataSource.sourceId];
//    if (!parserValue) {
//        parser = new NCParser();
//        self.parserDict[dataSource.sourceId] = [NSValue valueWithPointer:parser];
//    }
//    else {
//        parser = (NCParser *)parserValue.pointerValue;
//    }
//    return parser;
//}

-(void)textDidChange:(NCDataSource*)dataSource{
    
}

- (BOOL)dataSource:(NCDataSource *)dataSource shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

-(BOOL)runWithDataSource:(NCDataSource*)source{
//    auto parser = [self reparseSource:source];
//    _interpreter->initWithRoot(parser->getRoot());
//    _interpreter->invoke_main();
    
    if (!source.text || source.text.length == 0) {
        return NO;
    }
        
    return [self.codeEngine run:source.text mode:self.mode error:nil];;
}

-(BOOL)runProject{
    return [self.codeEngine runWithError:nil];
}

-(void)setProject:(NCProject *)project{
    _project = project;
    
    [self.codeEngine setRoot:project.rootDirectory];
}

-(void)markDirty:(NSString*)filename{
    [self.codeEngine setDirty:filename];
}

@end
