//
//  HousingProvidentFundLoanRateVC.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "HousingProvidentFundLoanRateVC.h"
#import "FRLCSettingManager.h"

#import "GCDetailTableViewCell.h"

@interface HousingProvidentFundLoanRateVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation HousingProvidentFundLoanRateVC{
    NSArray *dataDicArray;
    UITableView *myTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"公积金贷款利率";
    
    dataDicArray = [FRLCSettingManager defaultManager].loanRateArrayForHousingProvidentFund;
    dataDicArray = dataDicArray.reverseObjectEnumerator.allObjects;
    
    [self initTableView];
}

#pragma mark - TableView

- (void)initTableView{
    myTableView = [UITableView newAutoLayoutView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:myTableView];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
//    [myTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topInfoView withOffset:10];
//    [myTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:buttonContainerView withOffset:-10];
//    [myTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
//    [myTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataDicArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    NSDictionary *currentDic = dataDicArray[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@       %.2f%%        %.2f%%",currentDic[kAdjustDate],[currentDic[kRateLessOrEqual5Years] floatValue],[currentDic[kRateMoreThan5Years] floatValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    GCDetailTableViewCell *cell = [[GCDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    cell.contentView.alpha = 1.0;
    cell.contentView.backgroundColor = [UIColor flatGrayColor];
    
    cell.labelOffset = 40;
    cell.labelCount = 3;
    
    [cell.labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //[obj setStyle:UILabelStyleBrownBold];
        switch (idx) {
            case 0:
                obj.text = NSLocalizedString(@"       调整时间", @"");
                break;
            case 1:
                obj.text = NSLocalizedString(@"五年及以下", @"");
                break;
            case 2:
                obj.text = NSLocalizedString(@"五年以上", @"");
                break;
            default:
                break;
        }
    }];
    
    return cell;

}

@end
