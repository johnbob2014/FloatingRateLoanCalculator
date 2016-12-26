//
//  FRLInteractionVC.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FRLInteractionVC.h"
#import "FloatingRateLoan.h"
#import <RETableViewManager.h>
#import "FRLCSettingManager.h"
#import "FRLResultVC.h"

#import "KxMenu.h"

#define SectionHeaderHeight 20

typedef BOOL (^OnChangeCharacterInRange)(RETextItem *item, NSRange range, NSString *replacementString);

@interface FRLInteractionVC ()<RETableViewManagerDelegate>

@property (strong,nonatomic) FloatingRateLoan *currentFRL;

@property (strong,nonatomic) RETableViewManager *reTVManager;
@property (nonatomic,strong) UITableView *loanTableView;

@property (strong,nonatomic) RETableViewSection *iRateForYearSection;

@end


@implementation FRLInteractionVC{
    NSMutableArray <RETextItem *> *iRateForYearItemMA;
    FRLCSettingManager *settingManager;
    
    NSArray *yearCountArray;
    
    RETableViewSection *loanInfoSection;
    
    RETextItem *totalTextItem;
    REPickerItem *yearCountPickerItem;
    REDateTimeItem *dateTimeItem;
    RESegmentedItem *repayTypeSegItem;
    RESegmentedItem *creditorTypeSegItem;
    RETextItem *customRateItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"浮动利率贷款计算器",@"");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showMenu:)];
    
    yearCountArray = @[NSLocalizedString(@"1年",@""),
                                NSLocalizedString(@"2年",@""),
                                NSLocalizedString(@"3年",@""),
                                NSLocalizedString(@"4年",@""),
                                NSLocalizedString(@"5年",@""),
                                NSLocalizedString(@"6年",@""),
                                NSLocalizedString(@"7年",@""),
                                NSLocalizedString(@"8年",@""),
                                NSLocalizedString(@"9年",@""),
                                NSLocalizedString(@"10年",@""),
                                NSLocalizedString(@"11年",@""),
                                NSLocalizedString(@"12年",@""),
                                NSLocalizedString(@"13年",@""),
                                NSLocalizedString(@"14年",@""),
                                NSLocalizedString(@"15年",@""),
                                NSLocalizedString(@"16年",@""),
                                NSLocalizedString(@"17年",@""),
                                NSLocalizedString(@"18年",@""),
                                NSLocalizedString(@"19年",@""),
                                NSLocalizedString(@"20年",@""),
                                NSLocalizedString(@"21年",@""),
                                NSLocalizedString(@"22年",@""),
                                NSLocalizedString(@"23年",@""),
                                NSLocalizedString(@"24年",@""),
                                NSLocalizedString(@"25年",@""),
                                NSLocalizedString(@"26年",@""),
                                NSLocalizedString(@"27年",@""),
                                NSLocalizedString(@"28年",@""),
                                NSLocalizedString(@"29年",@""),
                                NSLocalizedString(@"30年",@"")];

    
    settingManager = [FRLCSettingManager defaultManager];
    
    self.currentFRL = [FloatingRateLoan new];
    self.currentFRL.firstRepayDate = [NSDate date];
    self.currentFRL.nYearCount = 3;
    
    if (DEBUGMODE){
        self.currentFRL.aTotal = 315000;
        self.currentFRL.nYearCount = 20;
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.currentFRL.firstRepayDate = [dateFormatter dateFromString:@"2015-05-20"];
    }
    
    [self initLoanUI];
    
    [self updateIRateForYearSection];
    
}

- (void)showMenu:(UIBarButtonItem *)sender{
    [KxMenu showMenuInView:self.view
                  fromRect:self.view.frame
                 menuItems:@[
                             [KxMenuItem menuItem:@"查询历史"
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(historyAction)],
                             [KxMenuItem menuItem:@"公积金利率"
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(historyAction)],
                             [KxMenuItem menuItem:@"购买提醒功能"
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(historyAction)],
                             [KxMenuItem menuItem:@"给个好评"
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(historyAction)]
                             ]];
}

- (void)historyAction{
    
}

- (void)initLoanUI{
    WEAKSELF(weakSelf);
    
    self.loanTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.loanTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loanTableView];
    [self.loanTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    self.reTVManager = [[RETableViewManager alloc] initWithTableView:self.loanTableView delegate:self];
    
    loanInfoSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"贷款信息",@"")];
    
    totalTextItem = [RETextItem itemWithTitle:NSLocalizedString(@"贷款总额",@"")
                                                  value:[[NSString alloc]initWithFormat:@"%.2f",self.currentFRL.aTotal]
                                            placeholder:NSLocalizedString(@"贷款总额",@"")];
    totalTextItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    
    NSArray *valueArray = DEBUGMODE ? @[NSLocalizedString(@"20年",@"")] :@[NSLocalizedString(@"3年",@"")];
    yearCountPickerItem = [REPickerItem itemWithTitle:@"贷款年限"
                                                value:valueArray
                                          placeholder:@"请选择"
                                              options:@[yearCountArray]];
    yearCountPickerItem.onChange = ^(REPickerItem *item){
        weakSelf.currentFRL.nYearCount = [yearCountArray indexOfObject:item.value.firstObject] + 1;
        [weakSelf updateIRateForYearSection];
    };
    
    dateTimeItem=[REDateTimeItem itemWithTitle:NSLocalizedString(@"首次还款",@"")
                                                         value:self.currentFRL.firstRepayDate
                                                   placeholder:nil
                                                        format:@"yyyy-MM"
                                                datePickerMode:UIDatePickerModeDate];
    dateTimeItem.onChange = ^(REDateTimeItem *item){
        weakSelf.currentFRL.firstRepayDate = item.value;
        [weakSelf updateIRateForYearSection];
    };
    dateTimeItem.inlineDatePicker=YES;
    
    repayTypeSegItem=[RESegmentedItem itemWithTitle:NSLocalizedString(@"还款方式",@"")
                                              segmentedControlTitles:@[NSLocalizedString(@"等额本金",@""),NSLocalizedString(@"等额本息",@"")]
                                                               value:0
                                            switchValueChangeHandler:^(RESegmentedItem *item) {
                                                NSLog(@"Value: %ld", (long)item.value);
                                                self.currentFRL.repayType = item.value;
                                            }];
    
    customRateItem = [RETextItem itemWithTitle:NSLocalizedString(@"自定利率",@"")
                                        value:@"4.00"
                                  placeholder:nil];
    customRateItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    customRateItem.onEndEditing = ^(RETextItem *item){
        [weakSelf updateIRateForYearSection];
//        for (RETextItem *rateItem in weakSelf.iRateForYearSection.items) {
//            rateItem.value = item.value;
//        }
    };

    creditorTypeSegItem = [RESegmentedItem itemWithTitle:NSLocalizedString(@"使用利率",@"")
                             segmentedControlTitles:@[NSLocalizedString(@"公积金",@""),NSLocalizedString(@"自定义",@"")]
                                              value:1
                           switchValueChangeHandler:^(RESegmentedItem *item) {
                               if (item.value == LoanCreditorTypeCustom){
                                   [loanInfoSection addItem:customRateItem];
                               }else{
                                   [loanInfoSection removeItem:customRateItem];
                               }
                               
                               [weakSelf updateIRateForYearSection];
                           }];
    
    
    [loanInfoSection addItemsFromArray:@[totalTextItem,yearCountPickerItem,dateTimeItem,repayTypeSegItem,creditorTypeSegItem,customRateItem]];
    
    RETableViewSection *buttonSection=[RETableViewSection sectionWithHeaderTitle:nil];
    buttonSection.headerHeight = SectionHeaderHeight;
    RETableViewItem *buttonItem = [RETableViewItem itemWithTitle:NSLocalizedString(@"开始计算",@"")
                                                   accessoryType:UITableViewCellAccessoryNone
                                                selectionHandler:^(RETableViewItem *item) {
                                                    [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
                                                    [weakSelf calculateBtnTD];
                                                }];
    buttonItem.textAlignment = NSTextAlignmentCenter;
    [buttonSection addItem:buttonItem];
    
    [self.reTVManager addSectionsFromArray:@[loanInfoSection,buttonSection]];

}

- (void)calculateBtnTD{
    if (![self checkInput]) return;
    
    self.currentFRL.aTotal = [totalTextItem.value floatValue];
    self.currentFRL.nYearCount = [yearCountArray indexOfObject:yearCountPickerItem.value.firstObject] + 1;
    self.currentFRL.firstRepayDate = dateTimeItem.value;
    self.currentFRL.repayType = repayTypeSegItem.value;
    
    NSMutableArray <NSNumber *> *ma = [NSMutableArray new];
    for (RETextItem *iRateItem in iRateForYearItemMA) {
        [ma addObject:@([iRateItem.value floatValue])];
    }
    
    self.currentFRL.iRateForYearArray = ma;
    
    FRLResultVC *resultVC = [FRLResultVC new];
    resultVC.currentFRL = self.currentFRL;
    resultVC.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (BOOL)checkInput{
    BOOL checkOK = YES;
    NSString *errorString;
    
    if ([totalTextItem.value floatValue] <= 0){
        errorString = @"贷款总额不能为0";
        checkOK = NO;
    }
    
    for (RETextItem *iRateItem in iRateForYearItemMA) {
        if ([iRateItem.value floatValue] <= 0){
            errorString = @"利率不能为0";
            checkOK = NO;
        }
    }
    
    if (errorString){
        UIAlertController *ac = [UIAlertController informationAlertControllerWithTitle:@"错误" message:errorString];
        [self presentViewController:ac animated:YES completion:nil];
    }
    return checkOK;
}

- (void)updateIRateForYearSection{
    [self.reTVManager removeSection:self.iRateForYearSection];
    
    iRateForYearItemMA = [NSMutableArray new];
    for (int yearIndex = 0; yearIndex < self.currentFRL.calculateYearCount; yearIndex++) {
        
        NSInteger currentYear = yearIndex + self.currentFRL.firstRepayYear;
        
        float loanRate = 0.0f;
        
        if (creditorTypeSegItem.value == LoanCreditorTypeHousingProvidentFund){
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *aDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%d-01-01",currentYear]];
            
            if (yearIndex == 0) aDate = self.currentFRL.firstRepayDate;
            
            loanRate = [settingManager loanRateOfType:LoanCreditorTypeHousingProvidentFund moreThan5Years:self.currentFRL.nYearCount > 5 ? YES : NO beforeDate:aDate];
        }else if (creditorTypeSegItem.value == LoanCreditorTypeCustom){
            loanRate = [customRateItem.value floatValue];
        }
        
        RETextItem *iRateItem=[RETextItem itemWithTitle:[[NSString alloc]initWithFormat:@"%d年",currentYear]
                                                      value:[[NSString alloc]initWithFormat:@"%.2f",loanRate]
                                                placeholder:NSLocalizedString(@"本年利率",@"")];
        iRateItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
        //iRateItem.textAlignment = NSTextAlignmentRight;
        [iRateForYearItemMA addObject:iRateItem];
    }
    
    self.iRateForYearSection = [[RETableViewSection alloc] initWithHeaderTitle:@"年度利率"];
    self.iRateForYearSection.headerHeight = SectionHeaderHeight;
    [self.iRateForYearSection addItemsFromArray:iRateForYearItemMA];
    [self.reTVManager insertSection:self.iRateForYearSection atIndex:1];
    [self.loanTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RE Block

-(OnChangeCharacterInRange)createLimitInputBlockWithAllowedString:(NSString *)string{
    OnChangeCharacterInRange block=^(RETextItem *item, NSRange range, NSString *replacementString){
        NSString *allowedString=string;
        NSCharacterSet *forbidenCharacterSet=[[NSCharacterSet characterSetWithCharactersInString:allowedString] invertedSet];
        NSArray *filteredArray=[replacementString componentsSeparatedByCharactersInSet:forbidenCharacterSet];
        NSString *filteredString=[filteredArray componentsJoinedByString:@""];
        
        if (![replacementString isEqualToString:filteredString]) {
            if(DEBUGMODE) NSLog(@"The character 【%@】 is not allowed!",replacementString);
        }
        
        return [replacementString isEqualToString:filteredString];
    };
    
    return block;
}

@end
