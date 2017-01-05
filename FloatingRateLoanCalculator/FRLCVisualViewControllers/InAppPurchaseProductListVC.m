//
//  InAppPurchaseProductListVC.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/27.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "InAppPurchaseProductListVC.h"
#import <RETableViewManager.h>

#import "FRLCSettingManager.h"
#import "InAppPurchaseVC.h"

@interface InAppPurchaseProductListVC ()<RETableViewManagerDelegate>
@property (strong,nonatomic) FRLCSettingManager *settingManager;
@end

@implementation InAppPurchaseProductListVC{
    
    RETableViewManager *manager;
    UITableView *myTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initTableView];
    
}

- (void)initData{
    self.title = NSLocalizedString(@"购买和恢复", @"Purchase / Restore");
    self.settingManager = [FRLCSettingManager defaultManager];
}

#pragma mark - TableView

- (void)initTableView{
    myTableView = [UITableView newAutoLayoutView];
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    myTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:myTableView];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    manager = [[RETableViewManager alloc]initWithTableView:myTableView delegate:self];
    
    //WEAKSELF(weakSelf);
    
    RETableViewSection *purchaseSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"购买",@"Purchase") footerTitle:@""];
    
    RETableViewItem *productItem1=[RETableViewItem itemWithTitle:[[NSString alloc]initWithFormat:@"📅 %@", NSLocalizedString(@"还款日历、还款提醒、导出数据", @"Repay Calendar, Repay Alert and Export Data")] accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        [self showPurchaseVC:TransactionTypePurchase productIndexArray:@[@0]];
    }];
    
    [purchaseSection addItemsFromArray:@[productItem1]];
    
    RETableViewSection *restoreSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"恢复",@"Restore") footerTitle:@""];
    RETableViewItem *restoreItem=[RETableViewItem itemWithTitle:[[NSString alloc]initWithFormat:@"%@", NSLocalizedString(@"恢复已购", @"Restore products purchased before")] accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [self showPurchaseVC:TransactionTypeRestore productIndexArray:@[@1]];
    }];
    
    [restoreSection addItem:restoreItem];
    
    [manager addSectionsFromArray:@[purchaseSection,restoreSection]];

}

- (void)showPurchaseVC:(enum TransactionType)transactionType productIndexArray:(NSArray <NSNumber *> *)productIndexArray{
    InAppPurchaseVC *inAppPurchaseVC = [InAppPurchaseVC new];
    inAppPurchaseVC.edgesForExtendedLayout = UIRectEdgeNone;
    
    inAppPurchaseVC.productIDArray = self.settingManager.appProductIDArray;
    inAppPurchaseVC.transactionType = transactionType;
    inAppPurchaseVC.productIndexArray = productIndexArray;
    
    WEAKSELF(weakSelf);
    inAppPurchaseVC.inAppPurchaseCompletionHandler = ^(enum TransactionType transactionType,NSInteger productIndex,BOOL succeeded){
        if (succeeded) {
            switch (productIndex) {
                case 0:
                    weakSelf.settingManager.hasPurchasedRepayAlert = YES;
                    break;
                    
                default:
                    break;
            }
        }
        if(DEBUGMODE) NSLog(@"%@ %@",self.settingManager.appProductIDArray[productIndex],succeeded? @"成功！" : @"用失败！");
    };
    
    if (self.navigationController){
        [self.navigationController pushViewController:inAppPurchaseVC animated:YES];
    }else{
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:inAppPurchaseVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

@end
