//
//  FRLHistoryListVC.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/28.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FRLHistoryListVC.h"
#import "FloatingRateLoan.h"
#import "FRLStorer+CoreDataClass.h"
#import "FRLCAppDelegate.h"
#import "FRLResultVC.h"

@interface FRLHistoryListVC ()<UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) NSArray *frlStorerArray;

@end

@implementation FRLHistoryListVC{
    UITableView *myTableView;
    NSArray *currentGroupArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"查询历史", @"");
    
    myTableView = [UITableView newAutoLayoutView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:myTableView];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self updateData]; 
}

#pragma mark - TableView

- (void)updateData{

    self.frlStorerArray = [FRLStorer fetchAllFRLStorersInManagedObjectContext:AppContext];
    currentGroupArray = self.frlStorerArray;
    /*
    if (currentGroupArray.count > 0){
        self.title = [NSString stringWithFormat:@"%@ - %lu",NSLocalizedString(@"查询历史", @""),(unsigned long)currentGroupArray.count];
    }
    */
    [myTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  currentGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    //cell.accessoryType = UITableViewCellAccessoryDetailButton;
    FRLStorer *storer = currentGroupArray[indexPath.row];
    FloatingRateLoan *frl = [NSKeyedUnarchiver unarchiveObjectWithData:storer.archivedData];
    NSMutableString *ms = [NSMutableString new];
    [ms appendFormat:@"%lu   ",(unsigned long)(indexPath.row + 1)];
    
    [ms appendFormat:@"%.2f    ",frl.aTotal];
    [ms appendFormat:@"%ld年    ",(long)frl.nYearCount];
    [ms appendString:frl.repayType == 0 ? @"等额本金":@"等额本息"];
    
    cell.textLabel.text = ms;
    cell.detailTextLabel.text = [storer.queryDate stringWithFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FRLStorer *storer = currentGroupArray[indexPath.row];
    FloatingRateLoan *frl = [NSKeyedUnarchiver unarchiveObjectWithData:storer.archivedData];
    
    FRLResultVC *vc = [FRLResultVC new];
    vc.currentFRL = frl;
    vc.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FRLStorer *storer = currentGroupArray[indexPath.row];
        [AppContext deleteObject:storer];
        [AppContext save:NULL];
        [self updateData];
    }
}

@end
