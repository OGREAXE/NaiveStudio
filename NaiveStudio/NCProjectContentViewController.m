//
//  NCProjectContentViewController.m
//  NaiveC
//
//  Created by 梁志远 on 31/12/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#import "NCProjectContentViewController.h"
#import "NCProjectManager.h"
#import "NCEditorViewController.h"
#import "NCProjectTableViewCell.h"
#import "NCAddNewFileViewController.h"
#import "Common.h"

@interface NCProjectContentViewController ()<UITableViewDataSource, UITableViewDelegate,NCAddNewFileViewControllerDelegate>

//@property  (nonatomic) IBOutlet UITableView * tableView;

@property  (nonatomic) UITableView * tableView;

@property (nonatomic) NCInterpreterController * interpreter;

@end

@implementation NCProjectContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView reloadData];
    
    self.title= self.project.name;
    
//    UIButton * addNewButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addNewButton.imageView.image = [UIImage imageNamed:@"add"];
//    [addNewButton addTarget:self action:@selector(didTapAddNew) forControlEvents:UIControlEventTouchUpInside];
//
//    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:addNewButton];
//    self.navigationItem.rightBarButtonItems = @[item];
    
    UIBarButtonItem *btn0 = [[UIBarButtonItem alloc] initWithTitle:@"new"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(didTapAddNew)];
    //btn0.image = [UIImage imageNamed:@"add" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    self.navigationItem.rightBarButtonItems = @[btn0];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.interpreter = [[NCInterpreterController alloc] init];
    self.interpreter.project = self.project;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden  = NO;
    [self.project reload];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.project.sourceFiles.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

#define CONTENTVIEWCELL_REUSEIDENTIFIER @"contentViewCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCProjectTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:CONTENTVIEWCELL_REUSEIDENTIFIER];
    if (!cell) {
        cell = [[NCProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CONTENTVIEWCELL_REUSEIDENTIFIER];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NCSourceFile * file = self.project.sourceFiles[indexPath.row];
    
    cell.textLabel.text = file.filename;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NCEditorViewController * controller = [[UIStoryboard storyboardWithName:MainStoryBoardName bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:NSStringFromClass([NCEditorViewController class])];
    
    NCEditorViewController * editVC = [[NCEditorViewController alloc] init];
    
    editVC.mode = self.mode;
    editVC.sourceFile = self.project.sourceFiles[indexPath.row];
    editVC.interpreter = self.interpreter;
    
    [self.navigationController pushViewController:editVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        
        NCSourceFile * file = self.project.sourceFiles[indexPath.row] ;
        
        [self ShowAlert:[NSString stringWithFormat:@"Are you sure you wnat to delete file \"%@?\"",file.filename] comfirmHandler:^{
            NSError * error = nil;
            [[NCProjectManager sharedManager] removeSourceFile:file project:self.project error:&error];
            if (error) {
                NSLog(@"error remove file %@,: %@",file.filename, error);
            }
            else {
                [self.tableView reloadData];
            }
        }];
    }
}

-(void)didTapAddNew{
//    NCAddNewFileViewController * controller = [[UIStoryboard storyboardWithName:MainStoryBoardName bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:NSStringFromClass([NCAddNewFileViewController class])];
    NCAddNewFileViewController * controller = [[NCAddNewFileViewController alloc] init];
    
    controller.currentProject = self.project;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)addNewFileViewController:(NCAddNewFileViewController*)addNewController willPushtoEditController:(NCEditorViewController*)editController{
    if (!editController.interpreter) {
        editController.interpreter = self.interpreter;
    }
    editController.mode = self.mode;
}

@end
