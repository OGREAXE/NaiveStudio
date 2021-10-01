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
#import "NCServerManager.h"

@interface NCProjectContentViewController ()<UITableViewDataSource, UITableViewDelegate,NCAddNewFileViewControllerDelegate>

//@property  (nonatomic) IBOutlet UITableView * tableView;

@property  (nonatomic) UITableView * tableView;

@property (nonatomic) NCScriptInterpreter * interpreter;

@property  (nonatomic) UILabel * startServerLabel;

@property  (nonatomic) UISwitch * startServerSwitch;

@end

@implementation NCProjectContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat bottomBarBottom = 60;
    CGFloat bottomBarHeight = 40;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - bottomBarHeight)];
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
    
    self.startServerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - bottomBarHeight - bottomBarBottom, self.view.bounds.size.width - 100, bottomBarHeight)];
    [self updateServerInfo];
    
    self.startServerLabel.textAlignment = NSTextAlignmentCenter;
    
    self.startServerSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.startServerLabel.frame), self.view.bounds.size.height - bottomBarHeight - bottomBarBottom, 100, bottomBarHeight)];
    self.startServerSwitch.on = [NCServerManager sharedManager].isServerRunning;
    [self.startServerSwitch addTarget:self action:@selector(didChangeSwitchValue:) forControlEvents:UIControlEventValueChanged];;
    
    [self.view addSubview:self.startServerLabel];
    [self.view addSubview:self.startServerSwitch];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.interpreter = [[NCScriptInterpreter alloc] init];
    self.interpreter.project = self.project;
    
    self.view.backgroundColor = [UIColor whiteColor];
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

-(void)updateServerInfo{
    if ([NCServerManager sharedManager].isServerRunning) {
        self.startServerLabel.text = [NSString stringWithFormat:@"服务器 %@:%d",[NCServerManager sharedManager].host,[NCServerManager sharedManager].port];
    }
    else {
        self.startServerLabel.text = @"启动服务器";
    }
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

-(void)didChangeSwitchValue:(UIControl*)switchControl{
    if (switchControl == self.startServerSwitch) {
        if (self.startServerSwitch.isOn) {
            [[NCServerManager sharedManager] startServer];
        }
        else {
            [[NCServerManager sharedManager] stopServer];
        }
        
        [self updateServerInfo];
    }
}

@end
