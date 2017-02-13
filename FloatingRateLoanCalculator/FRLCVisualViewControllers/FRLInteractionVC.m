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
#import "HousingProvidentFundLoanRateVC.h"
#import "InAppPurchaseProductListVC.h"
#import "FRLHistoryListVC.h"
#import "FRLStorer+CoreDataClass.h"
#import "KxMenu.h"
#import "FRLCAboutVC.h"
#import "WXApi.h"

#define kLastFRLData @"kLastFRLData"
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
    
    NSArray <NSString *> *yearCountArray;
    
    RETableViewSection *loanInfoSection;
    
    RETextItem *totalTextItem;
    REPickerItem *yearCountPickerItem;
    REDateTimeItem *dateTimeItem;
    RESegmentedItem *repayTypeSegItem;
    RESegmentedItem *creditorTypeSegItem;
    RETextItem *customRateItem;
    
    UIButton *calculateButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.title = NSLocalizedString(@"浮动利率贷款计算器",@"Floating Rate Loan Calculator");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showMenu:)];
    
    yearCountArray = @[ NSLocalizedString(@"1年",@"1 year"),
                        NSLocalizedString(@"2年",@"2 years"),
                        NSLocalizedString(@"3年",@"3 years"),
                        NSLocalizedString(@"4年",@"4 years"),
                        NSLocalizedString(@"5年",@"5 years"),
                        NSLocalizedString(@"6年",@"6 years"),
                        NSLocalizedString(@"7年",@"7 years"),
                        NSLocalizedString(@"8年",@"8 years"),
                        NSLocalizedString(@"9年",@"9 years"),
                        NSLocalizedString(@"10年",@"10 years"),
                        NSLocalizedString(@"11年",@"11 years"),
                        NSLocalizedString(@"12年",@"12 years"),
                        NSLocalizedString(@"13年",@"13 years"),
                        NSLocalizedString(@"14年",@"14 years"),
                        NSLocalizedString(@"15年",@"15 years"),
                        NSLocalizedString(@"16年",@"16 years"),
                        NSLocalizedString(@"17年",@"17 years"),
                        NSLocalizedString(@"18年",@"18 years"),
                        NSLocalizedString(@"19年",@"19 years"),
                        NSLocalizedString(@"20年",@"20 years"),
                        NSLocalizedString(@"21年",@"21 years"),
                        NSLocalizedString(@"22年",@"22 years"),
                        NSLocalizedString(@"23年",@"23 years"),
                        NSLocalizedString(@"24年",@"24 years"),
                        NSLocalizedString(@"25年",@"25 years"),
                        NSLocalizedString(@"26年",@"26 years"),
                        NSLocalizedString(@"27年",@"27 years"),
                        NSLocalizedString(@"28年",@"28 years"),
                        NSLocalizedString(@"29年",@"29 years"),
                        NSLocalizedString(@"30年",@"30 years")];

    
    settingManager = [FRLCSettingManager defaultManager];
    
    self.currentFRL = [FloatingRateLoan new];
    self.currentFRL.firstRepayDate = [NSDate date];
    self.currentFRL.nYearCount = 3;
    
    if (DEBUGMODE){
        self.currentFRL.aTotal = 315000;
        self.currentFRL.nYearCount = 20;
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.currentFRL.firstRepayDate = [dateFormatter dateFromString:@"2015-05-01"];
    }
    
    [self initButton];
    [self initTableView];
    
    [self updateIRateForYearSection];
    
}

- (BOOL)addAndObservePraiseCountToDecideWhetherToContinue{
    settingManager.praiseCount++;
    
    if (settingManager.praiseCount == 5){
        
        [self askForPraise];
        settingManager.praiseCount = 0;
        return NO;
    }else{
        return YES;
    }
}

- (void)askForPraise{
    NSString *alertTitle = NSLocalizedString(@"浮动利率计算器",@"Floating Rate");
    NSString *alertMessage = NSLocalizedString(@"没有广告是不是很清爽？作者也不容易，抽空给个好评呗！🙏",@"Is it cool without any advertisements? The author is toil and moil. So take a little time to praise me, please!🙏");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"去给好评",@"Praise") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:settingManager.appURLString]];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"残忍拒绝",@"I'm busy.") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    if (iOS9) alertController.preferredAction = okAction;
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showMenu:(UIBarButtonItem *)sender{
    float edgeLength = 20;
    CGRect rect = CGRectMake(ScreenWidth - edgeLength - 20, 0, edgeLength, edgeLength);
    
    [KxMenu setTintColor:[UIColor flatGreenColorDark]];
    [KxMenu showMenuInView:self.view
                  fromRect:rect
                 menuItems:@[
                             [KxMenuItem menuItem:NSLocalizedString(@"查询历史",@"Query History")
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(historyAction)],
                             [KxMenuItem menuItem:NSLocalizedString(@"公积金利率",@"HPF Rate")
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(hpfAction)],
                             [KxMenuItem menuItem:NSLocalizedString(@"购买和恢复",@"Purchase / Restore")
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(inAppAction)],
                             [KxMenuItem menuItem:NSLocalizedString(@"微信朋友圈",@"WeChat Timeline")
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(wxTimelineAction)],
                             [KxMenuItem menuItem:NSLocalizedString(@"微信好友",@"WeChat Session")
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(wxSessionAction)],
                             [KxMenuItem menuItem:NSLocalizedString(@"给个好评",@"Praise me")
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(praiseAction)],
                             [KxMenuItem menuItem:NSLocalizedString(@"关于",@"About")
                                            image:[UIImage imageNamed:@"image"]
                                           target:self
                                           action:@selector(aboutAction)]
                             ]];
}

- (void)historyAction{
    if(![self addAndObservePraiseCountToDecideWhetherToContinue]) return;
    
    FRLHistoryListVC *vc = [FRLHistoryListVC new];
    vc.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)hpfAction{
    [self.navigationController pushViewController:[HousingProvidentFundLoanRateVC new] animated:YES];
}

- (void)inAppAction{
    [self.navigationController pushViewController:[InAppPurchaseProductListVC new] animated:YES];
}

- (void)wxTimelineAction{
    [self wxShare:WXSceneTimeline];
}

- (void)wxSessionAction{
    [self wxShare:WXSceneSession];
}

- (void)praiseAction{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[FRLCSettingManager defaultManager].appURLString]];
}

- (void)aboutAction{
    FRLCAboutVC *aboutVC = [FRLCAboutVC new];
    aboutVC.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:aboutVC animated:YES];
}

#pragma mark - Simple WX Share

- (void)wxShare:(enum WXScene)wxScene{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]){
        if(DEBUGMODE) NSLog(@"WeChat uninstalled or not support!");
        return;
    }
    
    WXWebpageObject *webpageObject=[WXWebpageObject new];
    webpageObject.webpageUrl = [FRLCSettingManager defaultManager].appURLString;
    
    WXMediaMessage *mediaMessage=[WXMediaMessage alloc];
    // WXWebpageObject : 会话显示title、description、thumbData（图标较小)，朋友圈显示title、thumbData（图标较小),两者都发送webpageUrl
    // WXImageObject   : 会话显示分享的图片，并以thumbData作为缩略图，朋友圈只显示分享的图片,两者都发送imageData
    mediaMessage.title = NSLocalizedString(@"浮动利率贷款计算器", @"Floating Rate Loan Calculator");
    mediaMessage.description = NSLocalizedString(@"还款金额不对？来试试更专业的计算器吧！每年贷款利率自定义，更有公积金利率自动填充！",@"Wrong monthly repayment? Try this professional loan rate calculator! Custom rate for every year!");
    mediaMessage.mediaObject = webpageObject;
    mediaMessage.thumbData = UIImageJPEGRepresentation([UIImage imageNamed:@"37-List 300_300"], 0.5);
    
    SendMessageToWXReq *req=[SendMessageToWXReq new];
    req.message=mediaMessage;
    req.bText=NO;
    req.scene= wxScene;
    
    BOOL succeeded=[WXApi sendReq:req];
    if(DEBUGMODE) NSLog(@"SendMessageToWXReq : %@",succeeded? @"Succeeded" : @"Failed");
}

- (void)initButton{
    calculateButton = [UIButton newAutoLayoutView];
    [calculateButton setTitle:NSLocalizedString(@"开始计算",@"Calculate") forState:UIControlStateNormal];
    [calculateButton setStyle:UIButtonStyleSuccess];
    [calculateButton addTarget:self action:@selector(calculateBtnTD) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:calculateButton];
    [calculateButton autoSetDimension:ALDimensionHeight toSize:40];
    [calculateButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 10, 10, 10) excludingEdge:ALEdgeTop];
}

- (void)initTableView{
    WEAKSELF(weakSelf);
    
    self.loanTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.loanTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loanTableView];
    [self.loanTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [self.loanTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:calculateButton withOffset:-10];
    
    self.reTVManager = [[RETableViewManager alloc] initWithTableView:self.loanTableView delegate:self];
    
    loanInfoSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"贷款信息",@"Loan Information")];
    
    totalTextItem = [RETextItem itemWithTitle:NSLocalizedString(@"贷款总额",@"Total")
                                                  value:nil
                                            placeholder:NSLocalizedString(@"请输入贷款总额（单位：元）",@"Enter the total loan")];
    totalTextItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    totalTextItem.keyboardType = UIKeyboardTypeDecimalPad;
    
    NSArray *valueArray = DEBUGMODE ? @[NSLocalizedString(@"20年",@"20 years")] :@[NSLocalizedString(@"3年",@"3 years")];
    yearCountPickerItem = [REPickerItem itemWithTitle:NSLocalizedString(@"贷款年限",@"Term")
                                                value:valueArray
                                          placeholder:NSLocalizedString(@"请选择",@"Choose an item")
                                              options:@[yearCountArray]];
    yearCountPickerItem.onChange = ^(REPickerItem *item){
        weakSelf.currentFRL.nYearCount = [yearCountArray indexOfObject:item.value.firstObject] + 1;
        [weakSelf updateIRateForYearSection];
        [weakSelf.loanTableView scrollsToTop];
    };
    
    dateTimeItem=[REDateTimeItem itemWithTitle:NSLocalizedString(@"首次还款",@"First repay date")
                                                         value:self.currentFRL.firstRepayDate
                                                   placeholder:nil
                                                        format:@"yyyy-MM"
                                                datePickerMode:UIDatePickerModeDate];
    dateTimeItem.onChange = ^(REDateTimeItem *item){
        weakSelf.currentFRL.firstRepayDate = item.value;
        [weakSelf updateIRateForYearSection];
    };
    dateTimeItem.inlineDatePicker=YES;
    
    repayTypeSegItem=[RESegmentedItem itemWithTitle:NSLocalizedString(@"还款方式",@"Repay style")
                                              segmentedControlTitles:@[NSLocalizedString(@"等额本金",@"Average C"),NSLocalizedString(@"等额本息",@"Average C&I")]
                                                               value:0
                                            switchValueChangeHandler:^(RESegmentedItem *item) {
                                                NSLog(@"Value: %ld", (long)item.value);
                                                self.currentFRL.repayType = item.value;
                                            }];
    
    customRateItem = [RETextItem itemWithTitle:NSLocalizedString(@"自定利率",@"Custom rate")
                                         value:[NSString stringWithFormat:@"%.2f",[FRLCSettingManager defaultManager].lastCustomRate]
                                  placeholder:nil];
    customRateItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    customRateItem.onEndEditing = ^(RETextItem *item){
        [FRLCSettingManager defaultManager].lastCustomRate = [item.value floatValue];
        [weakSelf updateIRateForYearSection];
    };
    customRateItem.onReturn = ^(RETextItem *item){
        [FRLCSettingManager defaultManager].lastCustomRate = [item.value floatValue];
        [weakSelf updateIRateForYearSection];
    };
    customRateItem.keyboardType = UIKeyboardTypeDecimalPad;

    creditorTypeSegItem = [RESegmentedItem itemWithTitle:NSLocalizedString(@"使用利率",@"Rate to use")
                             segmentedControlTitles:@[NSLocalizedString(@"公积金",@"HPF loan rate"),NSLocalizedString(@"自定义",@"Custom rate")]
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
    
    /*
    RETableViewSection *buttonSection=[RETableViewSection sectionWithHeaderTitle:nil];
    buttonSection.headerHeight = SectionHeaderHeight;
    RETableViewItem *buttonItem = [RETableViewItem itemWithTitle:NSLocalizedString(@"开始计算",@"Calculate")
                                                   accessoryType:UITableViewCellAccessoryNone
                                                selectionHandler:^(RETableViewItem *item) {
                                                    [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
                                                    [weakSelf calculateBtnTD];
                                                }];
    buttonItem.textAlignment = NSTextAlignmentCenter;
    [buttonSection addItem:buttonItem];
    */
    
    [self.reTVManager addSectionsFromArray:@[loanInfoSection]];

}

- (void)calculateBtnTD{
    if(![self addAndObservePraiseCountToDecideWhetherToContinue]) return;
    
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
    
    /*
    NSData *frlData = [NSKeyedArchiver archivedDataWithRootObject:self.currentFRL];
    [[NSUserDefaults standardUserDefaults] setObject:frlData forKey:kLastFRLData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    */
    [FRLStorer newFRLStorerWithFloatingRateLoan:self.currentFRL inManagedObjectContext:AppContext];
    
    
    FRLResultVC *resultVC = [FRLResultVC new];
    resultVC.currentFRL = self.currentFRL;
    resultVC.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (BOOL)checkInput{
    BOOL checkOK = YES;
    NSString *errorString;
    
    if ([totalTextItem.value floatValue] <= 0){
        errorString = NSLocalizedString(@"贷款总额不能为0。",@"The total loan can not be 0.");
        checkOK = NO;
    }
    
    for (RETextItem *iRateItem in iRateForYearItemMA) {
        if ([iRateItem.value floatValue] <= 0){
            errorString = NSLocalizedString(@"利率不能为0。",@"The loan rate can not be 0.");
            checkOK = NO;
        }
    }
    
    if (errorString){
        UIAlertController *ac = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"错误",@"Error") message:errorString];
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
            NSDate *aDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-01-01",(long)currentYear]];
            
            if (yearIndex == 0) aDate = self.currentFRL.firstRepayDate;
            
            loanRate = [settingManager loanRateOfType:LoanCreditorTypeHousingProvidentFund moreThan5Years:self.currentFRL.nYearCount > 5 ? YES : NO beforeDate:aDate];
        }else if (creditorTypeSegItem.value == LoanCreditorTypeCustom){
            loanRate = [customRateItem.value floatValue];
        }
        
        RETextItem *iRateItem=[RETextItem itemWithTitle:yearCountArray[yearIndex]
                                                      value:[[NSString alloc]initWithFormat:@"%.2f",loanRate]
                                                placeholder:NSLocalizedString(@"本年利率",@"Rate for year")];
        iRateItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
        iRateItem.keyboardType = UIKeyboardTypeDecimalPad;
        [iRateForYearItemMA addObject:iRateItem];
    }
    
    self.iRateForYearSection = [[RETableViewSection alloc] initWithHeaderTitle:NSLocalizedString(@"年度利率",@"Rates")];
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
