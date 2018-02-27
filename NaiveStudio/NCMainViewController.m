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

@interface NCMainViewController ()

@property  (nonatomic) IBOutlet UITableView * tableView;

@property (nonatomic) IBOutlet UIButton * playgroundButton;

@property (nonatomic) NSMutableArray * projectList;

@end

@implementation NCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *btn0 = [[UIBarButtonItem alloc] initWithTitle:@"New Project"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(didTapNewProject:)];
    self.navigationItem.rightBarButtonItems = @[btn0];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.title= @"Naive!";
    
    self.projectList = [NSMutableArray arrayWithObject:[[NCProjectManager sharedManager] defaultProject]];
    
    [self.tableView reloadData];
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
    NCProjectContentViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([NCProjectContentViewController class])];
    
    controller.project = self.projectList[indexPath.row];
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)didTapNewProject :(id)sender{
    
}

-(IBAction)didTapGotoPlaygound:(id)sender{
    if (![[NCProjectManager sharedManager] playgroundExist]) {
        [[NCProjectManager sharedManager] createPlayground];
    }
    
    NCProjectContentViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([NCProjectContentViewController class])];
    
    controller.mode = NCInterpretorModeCommandLine;
    controller.project = [NCProjectManager sharedManager].playground;
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end
