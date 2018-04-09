//
//  NCEditorViewController.m
//  NaiveC
//
//  Created by 梁志远 on 16/09/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#import "NCEditorViewController.h"
#import "NCInterpreterController.h"
#import "NCCodeTemplate.h"
#import "NCProject.h"
#import "Common.h"
#import "NCCodeFastInputViewController.h"

//#include "NCTokenizer.hpp"
//#include "NCParser.hpp"
//#include "NCInterpreter.hpp"
#include "NCTextManager.h"

@interface NCEditorViewController ()<UIGestureRecognizerDelegate, NCCodeFastInputViewControllerDelegate>

@property (weak, nonatomic) IBOutlet  UITextView * textView;

@property (weak, nonatomic) IBOutlet  UITextView * outputView;

@property (weak, nonatomic) IBOutlet  UIButton * runButton;

@property (nonatomic) NCTextManager * textManager;

@property (nonatomic) NCInterpreterController * interpreter;

@property (nonatomic) NCTextViewDataSource * textViewDataSource;  //only one

@property (nonatomic) NSMutableArray * fileDataSourceArray;  //could be many

@property (nonatomic) NSRange selectedRange;

@end

@implementation NCEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    
    //    string str = "int i=0 \n if(i==0)i=2+1";
    _textViewDataSource  = [[NCTextViewDataSource alloc] initWithTextView:self.textView];
    
    _textView.smartQuotesType = UITextSmartQuotesTypeNo; 
    
    _textManager = [[NCTextManager alloc] initWithDataSource:self.textViewDataSource];
    _interpreter = [[NCInterpreterController alloc] init];
    _interpreter.mode = self.mode;
    
    self.interpreter.delegate  = self.textManager;
    
    [self.textViewDataSource addDelegate:self.interpreter];
    self.textViewDataSource.linkedStorage = self.sourceFile.filepath;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePrintNotification:) name:@"NCPrintStringNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLogNotification:) name:@"NCLogNotification" object:nil];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCompile:)];
    longPress.minimumPressDuration = 0.8; //定义按的时间
    [self.runButton addGestureRecognizer:longPress];
}

//-(void)testNC{
//
//    string str = self.textView.text.UTF8String;
//    NCTokenizer tokenizer(str);
//    auto  tokens = tokenizer.getTokens();
//    for (int i=0; i<tokens->size(); i++) {
//        const auto & aToken = (*tokens)[i];
//        NSLog(@"%s",aToken.token.c_str());
//    }
//
//    auto _tokens = tokens;
//    auto parser =  shared_ptr<NCParser>(new NCParser(_tokens));
//
//    auto interpreter = shared_ptr<NCInterpreter>(new NCInterpreter(parser->getRoot()));
//    interpreter->invoke_main();
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
////    [self.view endEditing:YES];
//}

-(void)didReceivePrintNotification:(NSNotification*)notification{
    NSString * str = notification.object;
    
    self.outputView.text = [[[self.outputView.text stringByAppendingString:str]stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] stringByAppendingString:@"\n"];
}

-(void)didReceiveLogNotification:(NSNotification*)notification{
    NSString * str = notification.object;
    
    self.outputView.text = [[[self.outputView.text stringByAppendingString:str]stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] stringByAppendingString:@"\n"];
}

#pragma mark shortcut input
-(IBAction)didTapFor:(id)sender{
//    [self.textManager insertCodeTemplate:NCCodeTemplateFor];
    [self showFastInputViewController:NCFastInputTypeFor];
}

-(IBAction)didTapWhile:(id)sender{
//    [self.textManager insertCodeTemplate:NCCodeTemplateWhile];
    [self showFastInputViewController:NCFastInputTypeWhile];
}
-(IBAction)didTapIf:(id)sender{
//    [self.textManager insertCodeTemplate:NCCodeTemplateIf];
    [self showFastInputViewController:NCFastInputTypeIf];
}
-(IBAction)didTapIfElse:(id)sender{
//    [self.textManager insertCodeTemplate:NCCodeTemplateIfElse];
    [self showFastInputViewController:NCFastInputTypeIfElse];
}
-(IBAction)didTapFunction:(id)sender{
//    [self.textManager insertCodeTemplate:NCCodeTemplateFunc];
    [self showFastInputViewController:NCFastInputTypeFunc];
}
//{
-(IBAction)didTapPar1:(id)sender{
    [self.textManager insertText:@"\"\""];
}
//(
-(IBAction)didTapPar2:(id)sender{
    
}

-(IBAction)didTapCompile:(id)sender{
    NSError * error;
    if(![self.textViewDataSource save:&error]){
        NSLog(@"compile error");
        return;
    }
    
    self.outputView.text = @"";
    [self.textView endEditing:YES];
    //    [self testNC];
    
    [self.interpreter runWithDataSource:self.textViewDataSource];
}

-(void)didLongPressCompile:(UILongPressGestureRecognizer*)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Run Action" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        __weak UIAlertController * wAlert = alert;
        
        UIAlertAction * actionDelay = [UIAlertAction actionWithTitle:@"Run after dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [self.interpreter runWithDataSource:self.textViewDataSource];
            }];
        }];
        
        UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [wAlert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:actionDelay];
        [alert addAction:actionCancel];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
}

-(IBAction)didTapUndo:(id)sender{
    NSUndoManager * manager = self.textView.undoManager;
    [manager undo];
}

-(IBAction)didTapMoveLeft:(id)sender{
    NSRange range = self.textViewDataSource.selectedRange;
    range.location --;
    self.textViewDataSource.selectedRange = range;
}

-(IBAction)didTapMoveRight:(id)sender{
    NSRange range = self.textViewDataSource.selectedRange;
    range.location ++;
    self.textViewDataSource.selectedRange = range;
}

-(IBAction)didTapMoveUp:(id)sender{
    CGRect rec = [self.textView firstRectForRange:self.textView.selectedTextRange];
    CGPoint currentPoint = rec.origin;
    currentPoint.y -= self.textView.font.pointSize;
    UITextRange * newrange = [_textView characterRangeAtPoint:currentPoint];
    
    const NSInteger location = [_textView offsetFromPosition:_textView.beginningOfDocument toPosition:newrange.start];
    
    
    self.textView.selectedRange = NSMakeRange(location, 0);
}

-(IBAction)didTapMoveDown:(id)sender{
    CGRect rec = [self.textView firstRectForRange:self.textView.selectedTextRange];
    CGPoint currentPoint = rec.origin;
    currentPoint.y += self.textView.font.pointSize * 2;
    UITextRange * newrange = [_textView characterRangeAtPoint:currentPoint];
    
    const NSInteger location = [_textView offsetFromPosition:_textView.beginningOfDocument toPosition:newrange.start];
    
    
    self.textView.selectedRange = NSMakeRange(location, 0);
    
}

-(IBAction)didTapSave:(id)sender{
    NSError * error;
    if([self.textViewDataSource save:&error]){
        
    }
}

-(void)showFastInputViewController:(NCFastInputType)type{
    self.selectedRange = self.textView.selectedRange;
    
    NCCodeFastInputViewController * controller = [[UIStoryboard storyboardWithName:MainStoryBoardName bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:NSStringFromClass([NCCodeFastInputViewController class])];
    controller.type = type;
    controller.delegate = self;
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)codeFastInputViewController:(NCCodeFastInputViewController*)controller didInput:(NSArray*)textArray type:(NCFastInputType)type{
    [self.textManager insertCodeTemplate:(NCCodeTemplateType)type placeholdersFillerArray:textArray];
}

-(void)didClose:(NCCodeFastInputViewController *)controller{
    [self.textView becomeFirstResponder];
    self.textView.selectedRange  = self.selectedRange;
}

@end
