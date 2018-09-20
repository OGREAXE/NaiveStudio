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

//@property (weak, nonatomic) IBOutlet  UITextView * textView;
//
//@property (weak, nonatomic) IBOutlet  UITextView * outputView;
//
//@property (weak, nonatomic) IBOutlet  UIButton * runButton;

@property (nonatomic)  UITextView * textView;

@property (nonatomic)  UITextView * outputView;

@property (nonatomic) NCTextManager * textManager;

@property (nonatomic) NCTextViewDataSource * textViewDataSource;  //only one

@property (nonatomic) NSMutableArray * fileDataSourceArray;  //could be many

@property (nonatomic) NSRange selectedRange;

//buttons
@property (nonatomic)  UIView * inputPanel;

@property (nonatomic)  UIButton * runButton;

@property (nonatomic)  UIButton * moveUpButton;
@property (nonatomic)  UIButton * moveDownButton;
@property (nonatomic)  UIButton * moveLeftButton;
@property (nonatomic)  UIButton * moveRightButton;

@property (nonatomic)  UIButton * closeButton;
@property (nonatomic)  UIButton * saveButton;

@end

@implementation NCEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor  = [UIColor grayColor];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.textView];
    
    self.outputView = [[UITextView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.outputView];
    
    self.inputPanel = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.inputPanel];
    
    self.runButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.runButton setTitle:@"run" forState:UIControlStateNormal];
    [self.runButton addTarget:self action:@selector(didTapCompile:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputPanel addSubview:self.runButton];
    
    self.moveUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.moveUpButton setTitle:@"^" forState:UIControlStateNormal];
    [self.moveUpButton addTarget:self action:@selector(didTapMoveUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.moveUpButton setBackgroundColor:[UIColor whiteColor]];
    [self.inputPanel addSubview:self.moveUpButton];
    
    self.moveDownButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.moveDownButton setTitle:@"v" forState:UIControlStateNormal];
    [self.moveDownButton addTarget:self action:@selector(didTapMoveDown:) forControlEvents:UIControlEventTouchUpInside];
    [self.moveDownButton setBackgroundColor:[UIColor whiteColor]];
    [self.inputPanel addSubview:self.moveDownButton];
    
    self.moveLeftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.moveLeftButton setTitle:@"<" forState:UIControlStateNormal];
    [self.moveLeftButton addTarget:self action:@selector(didTapMoveLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.moveLeftButton setBackgroundColor:[UIColor whiteColor]];
    [self.inputPanel addSubview:self.moveLeftButton];
    
    self.moveRightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.moveRightButton setTitle:@">" forState:UIControlStateNormal];
    [self.moveRightButton addTarget:self action:@selector(didTapMoveRight:) forControlEvents:UIControlEventTouchUpInside];
    [self.moveRightButton setBackgroundColor:[UIColor whiteColor]];
    [self.inputPanel addSubview:self.moveRightButton];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.closeButton setTitle:@"close" forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.inputPanel addSubview:self.closeButton];
    
    self.saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.saveButton setTitle:@"save" forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(didTapSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputPanel addSubview:self.saveButton];
    if (self.mode == NCInterpretorModeCommandLine) {
        self.saveButton.hidden = YES;
    }
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    
    //    string str = "int i=0 \n if(i==0)i=2+1";
    _textViewDataSource  = [[NCTextViewDataSource alloc] initWithTextView:self.textView];
    
    if (@available(iOS 11_0, *)) {
        _textView.smartQuotesType = UITextSmartQuotesTypeNo;
    } else {
        // Fallback on earlier versions
    }
    
    _textManager = [[NCTextManager alloc] initWithDataSource:self.textViewDataSource];
//    _interpreter = [[NCInterpreterController alloc] init];
    _interpreter.mode = self.mode;
    
    self.interpreter.delegate  = self.textManager;
    
    [self.textViewDataSource addDelegate:self.interpreter];
    self.textViewDataSource.linkedStorage = self.sourceFile.filepath;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePrintNotification:) name:@"NCPrintStringNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLogNotification:) name:@"NCLogNotification" object:nil];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressCompile:)];
    longPress.minimumPressDuration = 0.8; //定义按的时间
    [self.runButton addGestureRecognizer:longPress];
    
//    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    UIGestureRecognizer *popRecognizer = self.navigationController.interactivePopGestureRecognizer;
    [popRecognizer addTarget:self action:@selector(navigationControllerPopGestureRecognizerAction:)];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)navigationControllerPopGestureRecognizerAction:(UIGestureRecognizer *)sender
{
    switch (sender.state)
    {
        case UIGestureRecognizerStateEnded:
            [self saveCurrentContent];
        default:
            break;
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGSize mainSize = self.view.frame.size;
    
    self.textView.frame = CGRectMake(5,40,mainSize.width - 5 * 2, 250);
    
    self.inputPanel.frame = CGRectMake(5,self.textView.frame.origin.y + self.textView.frame.size.height + 5,mainSize.width - 5 * 2, 50);
    
    self.runButton.frame = CGRectMake(5,4,70, 40);
    
    self.outputView.frame = CGRectMake(5,self.inputPanel.frame.origin.y + self.inputPanel.frame.size.height + 5,mainSize.width - 5 * 2, 230);
    
    float directionButtonWidth = 38,directionButtonHeight = 20;
    self.moveLeftButton.frame = CGRectMake(CGRectGetMaxX(self.runButton.frame) + 4, CGRectGetMaxY(self.runButton.frame)-directionButtonHeight, directionButtonWidth, directionButtonHeight);
    self.moveDownButton.frame = CGRectMake(CGRectGetMaxX(self.moveLeftButton.frame)+1,self.moveLeftButton.frame.origin.y,self.moveLeftButton.frame.size.width,self.moveLeftButton.frame.size.height);
    self.moveUpButton.frame = CGRectMake(self.moveDownButton.frame.origin.x,self.moveDownButton.frame.origin.y-directionButtonHeight-1,self.moveLeftButton.frame.size.width,self.moveLeftButton.frame.size.height);
    self.moveRightButton.frame = CGRectMake(CGRectGetMaxX(self.moveDownButton.frame)+1,self.moveLeftButton.frame.origin.y,self.moveLeftButton.frame.size.width,self.moveLeftButton.frame.size.height);
    
    self.closeButton.frame = CGRectMake(CGRectGetMaxX(self.moveRightButton.frame)+50,self.moveRightButton.frame.origin.y,self.moveRightButton.frame.size.width,self.moveRightButton.frame.size.height);
    
    self.saveButton.frame = CGRectMake(CGRectGetMaxX(self.closeButton.frame)+10,self.closeButton.frame.origin.y,self.closeButton.frame.size.width,self.closeButton.frame.size.height);
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
    
    if (self.mode == NCInterpretorModeCommandLine) {
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
    else {
        NSError * error;
        if(![self.textViewDataSource save:&error]){
            NSLog(@"compile error");
            return;
        }
        
        [self.interpreter markDirty:self.sourceFile.filename];
        [self.interpreter runProject];
    }
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
        
        UIAlertAction * actionDelay5sec = [UIAlertAction actionWithTitle:@"Run in 5 seconds" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.interpreter runWithDataSource:self.textViewDataSource];
                });
                
            }];
        }];
        
        UIAlertAction * actionDelay15sec = [UIAlertAction actionWithTitle:@"Run in 15 seconds" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.interpreter runWithDataSource:self.textViewDataSource];
                });
                
            }];
        }];
        
        UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [wAlert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:actionDelay];
        [alert addAction:actionDelay5sec];
        [alert addAction:actionDelay15sec];
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
    [self saveCurrentContent];
}

-(BOOL)saveCurrentContent{
    NSError * error;
    if([self.textViewDataSource save:&error]){
        return YES;
    }
    if (error) {
        NSLog(@"save error:%@",error);
    }
    return NO;
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

-(void)close{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
