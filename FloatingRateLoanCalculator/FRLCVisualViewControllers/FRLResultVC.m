//
//  FRLResultVC.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/21.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
#define ShareButtonHeight 30
#define RowHeightOfTableView 25

#import "FRLResultVC.h"
#import "GCDetailTableViewCell.h"

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface FRLResultVC ()<UITableViewDataSource,UITableViewDelegate>

@property (assign,nonatomic) NSInteger currentYear;

@end

@implementation FRLResultVC{
    
    NSString *lastYearKey;
    
    NSMutableDictionary<NSString *,NSDictionary *> *resultData;
    NSInteger currentIndex;
    NSDictionary *currentYearDictionary;
    NSArray<NSNumber *> *arrayTotalForMonth,*arrayPrincipalForMonth,*arrayInterestForMonth,*arrayRestPrincipal,*arrayAllPayed,*arrayAllPayedPlusRestPrincipal;
    
    UIView *topInfoView;
    UILabel *infoLabelInTIV;
    
    UITableView *myTableView;
    UITableViewCellEditingStyle cellEditingStyle;
    
    UIView *buttonContainerView;
    
    UIButton *bottomLeftButton,*topLeftButton,*topRightButton;
    
    UIDeviceOrientation currentOrientation;
    NSInteger labelCount;
    
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    resultData = [self.currentFRL calculateData];
    labelCount = 5;
    
    NSArray *keyArray = [resultData.allKeys sortedArrayUsingSelector:@selector(compare:)];
    self.currentYear = [keyArray.firstObject integerValue];
    lastYearKey = keyArray.lastObject;
    currentIndex = 0;
    
    [self initTopInfoView];
    [self initButtons];
    [self initTableView];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    if (size.height > size.width){
        labelCount = 5;
        currentOrientation = UIDeviceOrientationPortrait;
    }else{
        labelCount = 8;
        currentOrientation = UIDeviceOrientationLandscapeLeft | UIDeviceOrientationLandscapeRight;
    }
    
    [myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TopInfoView

- (void)initTopInfoView{
    topInfoView = [UIView newAutoLayoutView];
    topInfoView.backgroundColor = DEBUGMODE ? [[UIColor randomFlatColor] colorWithAlphaComponent:0.6] : [UIColor flatGreenColor];
    [self.view addSubview:topInfoView];
    [topInfoView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 0, 10) excludingEdge:ALEdgeBottom];
    [topInfoView autoSetDimension:ALDimensionHeight toSize:40];
    
    infoLabelInTIV = [UILabel newAutoLayoutView];
    infoLabelInTIV.textAlignment = NSTextAlignmentCenter;
    infoLabelInTIV.numberOfLines = 0;
    [infoLabelInTIV setStyle:UILabelStyleBrownBold];
    
    [topInfoView addSubview:infoLabelInTIV];
    [infoLabelInTIV autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self updateTopInfoView];
}

- (void)updateTopInfoView{
    NSMutableString *ms = [NSMutableString new];
    
    
    NSDictionary *lastYearDic = resultData[lastYearKey];
    NSArray *lastYearAllPayedArray = lastYearDic[kAllPayed];
    float allPayed = [[lastYearAllPayedArray lastObject] floatValue];
    [ms appendFormat:@"总还款:%.2f,总本金:%.2f,总利息:%.2f",allPayed,self.currentFRL.aTotal,allPayed - self.currentFRL.aTotal];

    if (currentIndex < self.currentFRL.iRateForYearArray.count)
        [ms appendFormat:@"\n当年利率: %.2f%%",[self.currentFRL.iRateForYearArray[currentIndex] floatValue]];
    
    float aTotalForYear = 0.0 , principalForYear = 0.0 , interestForYear = 0.0;
    for (int i = 0; i < arrayTotalForMonth.count;i++){
        aTotalForYear += [arrayTotalForMonth[i] floatValue];
        principalForYear += [arrayPrincipalForMonth[i] floatValue];
        interestForYear += [arrayInterestForMonth[i] floatValue];
    }
    
    [ms appendFormat:@"\n当年总额:%.2f,当年本金:%.2f,当年利息:%.2f",aTotalForYear,principalForYear,interestForYear];
    
    infoLabelInTIV.text = ms;
}

#pragma mark - Buttons

- (void)initButtons{
    buttonContainerView = [UIView newAutoLayoutView];
    buttonContainerView.backgroundColor = DEBUGMODE ? [[UIColor randomFlatColor] colorWithAlphaComponent:0.6] : ClearColor;
    [self.view addSubview:buttonContainerView];
    [buttonContainerView autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight * 2 + 10];
    [buttonContainerView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view withOffset:-20];
    [buttonContainerView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
    [buttonContainerView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.view];
    
    topLeftButton = [UIButton newAutoLayoutView];
    [topLeftButton setTitle:NSLocalizedString(@"上一年", @"") forState:UIControlStateNormal];
    [topLeftButton setStyle:UIButtonStylePrimary];
    topLeftButton.tag = 0;
    [topLeftButton addTarget:self action:@selector(previousYearBtnTD:) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:topLeftButton];
    [topLeftButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [topLeftButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [topLeftButton autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    
    topRightButton = [UIButton newAutoLayoutView];
    [topRightButton setTitle:NSLocalizedString(@"下一年", @"") forState:UIControlStateNormal];
    [topRightButton setStyle:UIButtonStylePrimary];
    topRightButton.tag = 1;
    [topRightButton addTarget:self action:@selector(nextYearBtnTD:) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:topRightButton];
    [topRightButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [topRightButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [topRightButton autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    [topRightButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:topLeftButton];
    [topRightButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:topLeftButton withOffset:10];
    
    bottomLeftButton = [UIButton newAutoLayoutView];
    [bottomLeftButton setTitle:NSLocalizedString(@"导出", @"") forState:UIControlStateNormal];
    [bottomLeftButton setStyle:UIButtonStylePrimary];
    [bottomLeftButton addTarget:self action:@selector(exportBtnTD:) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:bottomLeftButton];
    [bottomLeftButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [bottomLeftButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [bottomLeftButton autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    
    UIButton *bottomRightButton = [UIButton newAutoLayoutView];
    [bottomRightButton setTitle:NSLocalizedString(@"添加提醒", @"") forState:UIControlStateNormal];
    [bottomRightButton setStyle:UIButtonStylePrimary];
    [bottomRightButton addTarget:self action:@selector(addAlertBtnTD:) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:bottomRightButton];
    [bottomRightButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [bottomRightButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [bottomRightButton autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    [bottomRightButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:bottomLeftButton];
    [bottomRightButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:bottomLeftButton withOffset:10];
}

- (void)previousYearBtnTD:(UIButton *)button{
    if (currentIndex <= 0) return;
    
    currentIndex--;
    self.currentYear--;
}

- (void)nextYearBtnTD:(UIButton *)button{
    if (currentIndex >= self.currentFRL.nYearCount) return;
    
    currentIndex++;
    self.currentYear++;
}

- (void)setCurrentYear:(NSInteger)currentYear{
    _currentYear = currentYear;
    
    // 更新数据
    currentYearDictionary = [resultData objectForKey:[NSString stringWithFormat:@"%d",currentYear]];
    arrayTotalForMonth = currentYearDictionary[kTotalForMonth];
    arrayPrincipalForMonth = currentYearDictionary[KPrincipalForMonth];
    arrayInterestForMonth = currentYearDictionary[kInterestForMonth];
    arrayAllPayed = currentYearDictionary[kAllPayed];
    arrayRestPrincipal = currentYearDictionary[kRestPrincipal];
    arrayAllPayedPlusRestPrincipal = currentYearDictionary[kAllPayedPlusRestPrincipal];
    
    [myTableView reloadData];
    
    self.title = [NSString stringWithFormat:@"%d年",currentYear];
    
    [self updateTopInfoView];
}

- (void)exportBtnTD:(UIButton *)button{
    
}

- (void)addAlertBtnTD:(UIButton *)button{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
        
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"添加日历和提醒",@"") message:NSLocalizedString(@"将当年的还贷信息添加到日历中，并设置提醒。",@"") preferredStyle:UIAlertControllerStyleAlert];
    
//    NSLocalizedString(@"不，我不需要添加",@"")
//    NSLocalizedString(@"当天9点提醒",@"")
//    NSLocalizedString(@"1天前9点提醒",@"")
//    NSLocalizedString(@"2天前9点提醒",@"")
//    NSLocalizedString(@"1周前提醒",@"")
    
    __block UITextField *nameTF;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = NSLocalizedString(@"请输入贷款名称，方便区分",@"");
        nameTF = textField;
    }];
    
    __block UITextField *alertDayTF;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = NSLocalizedString(@"请输入每月提醒日期，默认为1号提醒",@"");
        alertDayTF = textField;
    }];
    
    UIAlertAction *ac0 = [UIAlertAction actionWithTitle:NSLocalizedString(@"添加，但不用提醒",@"")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){
                                                         [self addToCalenderWithAlertTime:-1 alertDay:[alertDayTF.text integerValue] loanName:nameTF.text];
                                                     }];
    UIAlertAction *ac1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"当天9点提醒",@"")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action){
                                                    [self addToCalenderWithAlertTime:0 alertDay:[alertDayTF.text integerValue] loanName:nameTF.text];
                                                    
                                                }];
    UIAlertAction *ac2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"1天前9点提醒",@"")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action){
                                                    [self addToCalenderWithAlertTime:1 alertDay:[alertDayTF.text integerValue] loanName:nameTF.text];
                                                    
                                                }];
    UIAlertAction *ac3 = [UIAlertAction actionWithTitle:NSLocalizedString(@"2天前9点提醒",@"")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action){
                                                    [self addToCalenderWithAlertTime:2 alertDay:[alertDayTF.text integerValue] loanName:nameTF.text];
                                                    
                                                }];
    UIAlertAction *ac4 = [UIAlertAction actionWithTitle:NSLocalizedString(@"1周前提醒",@"")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action){
                                                    [self addToCalenderWithAlertTime:3 alertDay:[alertDayTF.text integerValue] loanName:nameTF.text];
                                                    
                                                }];
    UIAlertAction *ac5 = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消",@"")
                                                  style:UIAlertActionStyleDefault
                                                handler:nil];
    [alertController addAction:ac0];
    [alertController addAction:ac1];
    [alertController addAction:ac2];
    [alertController addAction:ac3];
    [alertController addAction:ac4];
    [alertController addAction:ac5];
    
    if (iOS9) alertController.preferredAction = ac0;
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)addToCalenderWithAlertTime:(NSInteger)alertTime alertDay:(NSInteger)alertDay loanName:(NSString *)loanName{
    EKEventStore *eventStore=[[EKEventStore alloc]init];
    NSString *alertStirng=NSLocalizedString(@"未设置提醒",@"");
    //int count = arrayTotalForMonth.count;
    NSError *saveEventError;
    
    NSDate *firstAlertDate;
    if (currentIndex == 0) firstAlertDate = [self.currentFRL.firstRepayDate dateAtStartOfThisMonth];
    else{
        firstAlertDate = [[[self.currentFRL.firstRepayDate dateByAddingYears:currentIndex] dateAtStartOfThisYear] dateByAddingDays:alertDay - 1];
    }
    
    NSInteger firstYearMonthCount = 12 - self.currentFRL.firstRepayMonth + 1;
    NSInteger currentYearMonthStartIndex = currentIndex > 0 ? (currentIndex - 1) * 12 + firstYearMonthCount : 0;
    
    for (int index = 0; index<arrayTotalForMonth.count; index++) {
        EKEvent *newEvent=[EKEvent eventWithEventStore:eventStore];
        
        NSString *aTotal = [NSString stringWithFormat:@"%.2f",[arrayTotalForMonth[index] floatValue]];
        NSString *principalForMonth = [NSString stringWithFormat:@"%.2f",[arrayPrincipalForMonth[index] floatValue]];
        NSString *interestForMonth = [NSString stringWithFormat:@"%.2f",[arrayInterestForMonth[index] floatValue]];
        
        NSString *t1=NSLocalizedString(@"本月应还", @"");
        NSString *t2=NSLocalizedString(@"贷款总额", @"");
        NSString *t3=NSLocalizedString(@"总额", @"");
        NSString *t4=NSLocalizedString(@"本金", @"");
        NSString *t5=NSLocalizedString(@"利息", @"");
        NSString *t6=NSLocalizedString(@"第", @"");
        NSString *t7=NSLocalizedString(@"期", @"");
        
        NSInteger totalCount = self.currentFRL.nYearCount * 12;
        
        newEvent.title=[[NSString alloc]initWithFormat:@"%@%@%@,%@%@,%@%@【%@%ld/%ld%@】",t1,t2,aTotal,t4,principalForMonth,t5,interestForMonth,t6,(long)currentYearMonthStartIndex+index+1,(long)totalCount,t7];
        
        //如果用户设置了还款标签，则添加上
        //NSString *loanName=self.currentFRL.loanName;
        if (loanName) {
            newEvent.title=[[NSString alloc]initWithFormat:@"%@【%@】%@%@,%@%@,%@%@【%@%ld/%ld%@】",t1,loanName,t3,aTotal,t4,principalForMonth,t5,interestForMonth,t6,(long)currentYearMonthStartIndex+index+1,(long)totalCount,t7];
        }
        
        newEvent.startDate = [firstAlertDate dateByAddingMonths:index - 1];
        newEvent.endDate = newEvent.startDate;
        newEvent.allDay = YES;
        
        NSTimeInterval alarmRelativeOffset;
        
        switch (alertTime) {
                //根据用户的不同选择，添加不同类型的提醒
            case 0:
                //当天9点提醒
                alarmRelativeOffset = 9*60*60;
                alertStirng=NSLocalizedString(@"提醒时间:当天9点",@"");
                break;
            case 1:
                //1天前9点提醒
                alarmRelativeOffset = -15*60*60;
                alertStirng=NSLocalizedString(@"提醒时间:1天前9点",@"");
                break;
            case 2:
                //2天前9点提醒
                alarmRelativeOffset = -(15+24)*60*60;
                alertStirng=NSLocalizedString(@"提醒时间:2天前9点",@"");
                break;
            case 3:
                //1周前提醒
                alarmRelativeOffset = -(15+6*24)*60*60;
                alertStirng=NSLocalizedString(@"提醒时间:1周前",@"");
                break;
            
            default:
                break;
        }
        
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:alarmRelativeOffset];
        newEvent.alarms = @[alarm];
        
        EKCalendar *newCalender=[eventStore defaultCalendarForNewEvents];
        [newCalender setTitle:NSLocalizedString(@"还款提醒",@"")];
        [newEvent setCalendar:newCalender];
        
        [eventStore saveEvent:newEvent span:EKSpanThisEvent error:&saveEventError];
    }
    
    if (saveEventError) {
        NSString *m1=NSLocalizedString(@"您禁用了应用的日历访问，请到“设置”→“隐私”→“日历”中启用。", @"");
        NSString *m2=NSLocalizedString(@"系统提示:", @"");
        NSString *message=[[NSString alloc]initWithFormat:@"%@\n%@",m1,m2];
        
        NSString *errorMessage=[saveEventError localizedDescription];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"添加日历出错了",@"") message:[message stringByAppendingString:errorMessage] delegate:self cancelButtonTitle:NSLocalizedString(@"好的，我知道了",@"") otherButtonTitles: nil];
        [alert show];
    }
    else{
        NSString *message=[[NSString alloc]initWithFormat:NSLocalizedString(@"还贷信息已成功添加到日历!",@"")];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"提示",@"") message:[message stringByAppendingString:alertStirng] delegate:self cancelButtonTitle:NSLocalizedString(@"好的",@"") otherButtonTitles:nil];
        [alert show];
    }
    

}


#pragma mark - TableView

- (void)initTableView{
    myTableView = [UITableView newAutoLayoutView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[GCDetailTableViewCell class] forCellReuseIdentifier:@"Cell"];
    myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:myTableView];
    [myTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topInfoView withOffset:10];
    [myTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:buttonContainerView withOffset:-10];
    [myTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [myTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return RowHeightOfTableView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    GCDetailTableViewCell *cell = [[GCDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    cell.contentView.alpha = 1.0;
    cell.contentView.backgroundColor = [UIColor flatGrayColor];
    
    cell.labelOffset = 10;
    cell.labelCount = labelCount;
    
    [cell.labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //[obj setStyle:UILabelStyleBrownBold];
        switch (idx) {
            case 0:
                obj.text = NSLocalizedString(@"月份", @"");
                break;
            case 1:
                obj.text = NSLocalizedString(@"期次", @"");
                break;
            case 2:
                obj.text = NSLocalizedString(@"当月总额", @"");
                break;
            case 3:
                obj.text = NSLocalizedString(@"当月本金", @"");
                break;
            case 4:
                obj.text = NSLocalizedString(@"当月利息", @"");
                break;
            case 5:
                obj.text = NSLocalizedString(@"已还总额", @"");
                break;
            case 6:
                obj.text = NSLocalizedString(@"剩余本金", @"");
                break;
            case 7:
                obj.text = NSLocalizedString(@"当月一次性还清实付", @"");
                break;
            default:
                break;
        }
    }];
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *array = [currentYearDictionary objectForKey:kTotalForMonth];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ScreenWidth > 375 ? RowHeightOfTableView + 10 : RowHeightOfTableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GCDetailTableViewCell *cell = [[GCDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    cell.labelOffset = 15;
    cell.labelCount = labelCount;
    
    if (indexPath.row % 2 == 1) cell.contentView.backgroundColor = [UIColor flatGrayColor];
    
    NSInteger firstYearMonthCount = 12 - self.currentFRL.firstRepayMonth + 1;
    NSInteger currentYearMonthStartIndex = currentIndex > 0 ? (currentIndex - 1) * 12 + firstYearMonthCount : 0;
    
    NSInteger index = indexPath.row;
    [cell.labelArray enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        switch (idx) {
            case 0:
                obj.text = [NSString stringWithFormat:@"%02d月",currentIndex == 0 ? self.currentFRL.firstRepayMonth + index:index + 1];
                break;
            case 1:
                obj.text = [NSString stringWithFormat:@"%03d",currentYearMonthStartIndex + index + 1];
                break;
            case 2:
                obj.text = [NSString stringWithFormat:@"%.2f",[[currentYearDictionary objectForKey:kTotalForMonth][index] floatValue]];
                break;
            case 3:
                obj.text = [NSString stringWithFormat:@"%.2f",[[currentYearDictionary objectForKey:KPrincipalForMonth][index] floatValue]];
                break;
            case 4:
                obj.text = [NSString stringWithFormat:@"%.2f",[[currentYearDictionary objectForKey:kInterestForMonth][index] floatValue]];
                break;
            case 5:
                obj.text = [NSString stringWithFormat:@"%.2f",[[currentYearDictionary objectForKey:kAllPayed][index] floatValue]];
                break;
            case 6:
                obj.text = [NSString stringWithFormat:@"%.2f",[[currentYearDictionary objectForKey:kRestPrincipal][index] floatValue]];
                break;
            case 7:
                obj.text = [NSString stringWithFormat:@"%.2f",[[currentYearDictionary objectForKey:kAllPayedPlusRestPrincipal][index] floatValue]];
                break;
            default:
                break;
        }
    }];
    
    return cell;
}


@end