//
//  NCMainViewController.m
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS) on 2018/2/26.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCMainViewController.h"
#import "NCMainViewCell.h"
#import "NCProject.h"
#import "NCProjectContentViewController.h"
#import "NCEditorViewController.h"
#import "Common.h"
#import "NCBuiltinManager.h"

@interface NCMainViewController ()<UITableViewDelegate,UITableViewDataSource>

//@property  (nonatomic) IBOutlet UITableView * tableView;
//
//@property (nonatomic) IBOutlet UIButton * playgroundButton;

@property  (nonatomic) UITableView * tableView;

@property (nonatomic) UIButton * playgroundButton;

@property (nonatomic) NSMutableArray * projectList;

@end

@implementation NCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [NCBuiltinManager addAll];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.playgroundButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.playgroundButton setTitle:@"playground" forState:UIControlStateNormal];
    [self.playgroundButton addTarget:self action:@selector(didTapGotoPlaygound:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playgroundButton];
    
    if (self.isPresented) {
        UIBarButtonItem *btnClose = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(didTapCloseButton:)];
        self.navigationItem.leftBarButtonItems = @[btnClose];
    }
    UIBarButtonItem *btn0 = [[UIBarButtonItem alloc] initWithTitle:@"New Project"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(didTapNewProject:)];
    self.navigationItem.rightBarButtonItems = @[btn0];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.projectList = [NSMutableArray arrayWithObject:[[NCProjectManager sharedManager] defaultProject]];
    
    [self.tableView reloadData];
    
//    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.baidu.com"]];
//    NSLog(@"%@",data);
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGFloat buttonHeight = 50;
    CGSize mainSize = self.view.frame.size;
    self.playgroundButton.frame = CGRectMake(0, mainSize.height-buttonHeight, mainSize.width, buttonHeight);
    self.tableView.frame = CGRectMake(0, 0, mainSize.width, mainSize.height-buttonHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.projectList.count;
}

#define MAINVIEWCELL_REUSEIDENTIFIER @"mainViewCell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NCMainViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:MAINVIEWCELL_REUSEIDENTIFIER];
    if (!cell) {
        cell = [[NCMainViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MAINVIEWCELL_REUSEIDENTIFIER];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NCProject * project = self.projectList[indexPath.row];
    
    cell.textLabel.text = project.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NCProjectContentViewController * controller = [[UIStoryboard storyboardWithName:MainStoryBoardName bundle:[NSBundle bundleForClass:self.class]] instantiateViewControllerWithIdentifier:NSStringFromClass([NCProjectContentViewController class])];
    
    controller.project = self.projectList[indexPath.row];
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)didTapNewProject :(id)sender{
    
}

-(IBAction)didTapGotoPlaygound:(id)sender{
    [self goToPlayground];
}

-(void)didTapCloseButton:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)goToPlayground{
    if (![[NCProjectManager sharedManager] playgroundExist]) {
        [[NCProjectManager sharedManager] createPlayground];
    }
    
    NCProjectContentViewController * controller = [[NCProjectContentViewController alloc] init];
    
    controller.mode = NCInterpretorModeCommandLine;
    controller.project = [NCProjectManager sharedManager].playground;
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
