//
//  NCAddNewFileViewController.m
//  NaiveC
//
//  Created by 梁志远 on 01/01/2018.
//  Copyright © 2018 Ogreaxe. All rights reserved.
//

#import "NCAddNewFileViewController.h"
#import "Common.h"
#import "NCEditorViewController.h"
#import "NCProjectManager.h"
#import "Common.h"

@interface NCAddNewFileViewController ()

//@property (nonatomic) IBOutlet UITextField * textField;
//
//@property (nonatomic) IBOutlet UIButton * okButton;

@property (nonatomic) UITextField * textField;

@property (nonatomic) UIButton * okButton;

@end

@implementation NCAddNewFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.textField];
    
    self.okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.okButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.view addSubview:self.okButton];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGSize mainSize = self.view.frame.size;
    self.textField.frame = CGRectMake((mainSize.width - 250)/2, 80, 250, 40);
    self.okButton.frame = CGRectMake((mainSize.width - 150)/2, 80 + 40 + 15, 150, 40);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didTapOk:(id)sender{
//    NSString * filename = self.textField.text;
//    NSString * projectPath = self.currentProject.rootDirectory;
//    NSString * filepath = [projectPath stringByAppendingPathComponent:filename];
//
    NSError * error = nil;
//    [@"" writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NCSourceFile * file = [[NCProjectManager sharedManager] createSourceFile:self.textField.text project:self.currentProject error:&error];
    
    if (error) {
        NSLog(@"write file fail: %@",error);
    }
    else {
        NCEditorViewController * controller = [[UIStoryboard storyboardWithName:MainStoryBoardName bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:NSStringFromClass([NCEditorViewController class])];
        
        controller.sourceFile = file;
        
        if ([self.delegate respondsToSelector:@selector(addNewFileViewController:willPushtoEditController:)] ) {
            [self.delegate addNewFileViewController:self willPushtoEditController:controller];
        }
        [self.navigationController pushViewController:controller animated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *currentControllers = self.navigationController.viewControllers;
            
            NSMutableArray *newControllers = [NSMutableArray
                                              arrayWithArray:currentControllers];
            [newControllers removeObject:self];
            
            self.navigationController.viewControllers = newControllers;
        });
    }
}

@end
