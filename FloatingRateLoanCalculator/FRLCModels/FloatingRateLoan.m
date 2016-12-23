//
//  FloatingRateLoan.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/16.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

/*
static NSString * const kTotalForMonth=@"kTotalForMonth";
static NSString * const KPrincipalForMonth=@"KPrincipalForMonth";
static NSString * const kInterestForMonth=@"kInterestForMonth";
static NSString * const kRestPrincipal=@"kRestPrincipal";
static NSString * const kAllPayed=@"kAllPayed";
static NSString * const kAllPayedPlusRestPrincipal=@"kAllPayedPlusRestPrincipal";
*/

#import "FloatingRateLoan.h"

@interface FloatingRateLoan()

@property(assign,nonatomic,readwrite) NSInteger firstRepayYear;

@property(assign,nonatomic,readwrite) NSInteger firstRepayMonth;

@property(assign,nonatomic,readwrite) NSInteger calculateYearCount;

@end

@implementation FloatingRateLoan

- (void)setNYearCount:(NSInteger)nYearCount{
    _nYearCount = nYearCount;
    self.calculateYearCount = nYearCount;
}

- (void)setFirstRepayDate:(NSDate *)firstRepayDate{
    _firstRepayDate = firstRepayDate;
    
    NSDateComponents *dateComponents = [[NSCalendar autoupdatingCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.firstRepayDate];
    
    self.firstRepayYear = dateComponents.year;
    self.firstRepayMonth = dateComponents.month;
}

- (void)setFirstRepayMonth:(NSInteger)firstRepayMonth{
    _firstRepayMonth = firstRepayMonth;
    if (firstRepayMonth != 1) self.calculateYearCount = self.nYearCount + 1;
}


-(NSMutableDictionary <NSString *,NSArray *> *)calculateDataForYear:(NSInteger)yearIndex previousDictionary:(NSMutableDictionary <NSString *,NSArray *> *)previousDictionary{
    
    // 当年年度利率
    float iCurrentRateForMonth = 0.0;
    if (yearIndex > self.nYearCount) return nil;
    else if (yearIndex < self.nYearCount) iCurrentRateForMonth = [self.iRateForYearArray[yearIndex] floatValue] / 12.0 / 100.0;
    else if (yearIndex == self.nYearCount){
        // 如果不是从1月开始还款，则会多出一个还款年度，使用数组的最后一个利率进行计算
        // 不论用户是否提供了最后一个年度的利率，都可以完成计算
        iCurrentRateForMonth = [[self.iRateForYearArray lastObject] floatValue] / 12.0 / 100.0;
    }
    
    // 计算每个还款年度的月数、剩余还款月数
    // 当前年度的月数
    int monthCountForCurrentYear = 12;
    // 剩余期次
    NSUInteger nLeftMonthCount = self.nYearCount * 12;
    
    NSDateComponents *dateComponents = [[NSCalendar autoupdatingCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.firstRepayDate];
    int monthCountForFirstYear = 12 - dateComponents.month + 1;
    int monthCountForLastYear = 12 - monthCountForFirstYear;
    
    //首年的月数
    if (yearIndex == 0) {
        monthCountForCurrentYear = monthCountForFirstYear;
    }
    else if (yearIndex > 0 && yearIndex < self.nYearCount){
        monthCountForCurrentYear = 12;
        nLeftMonthCount = self.nYearCount * 12 - monthCountForFirstYear - (yearIndex - 1) * 12;
    }
    //尾年的月数（多出的一个还款年度）
    else if (yearIndex == self.nYearCount) {
        monthCountForCurrentYear = monthCountForLastYear;
        nLeftMonthCount = monthCountForCurrentYear;
    }
    
    // 上年剩余本金
    float aLeftTotal = self.aTotal;
    if (yearIndex > 0 && previousDictionary){
        aLeftTotal = [[[previousDictionary valueForKey:kRestPrincipal] lastObject] floatValue];
    }
    
    double principalForMonth=0;//当月本金
    double interestForMonth=0;//当月利息
    double totalForMonth=0;//当月总额
    double restPrincipal=0;//剩余本金
    
    double allPayed=0;//已还本金、利息合计
    if (yearIndex > 0 && previousDictionary){
        allPayed = [[[previousDictionary valueForKey:kAllPayed] lastObject] floatValue];
    }
    
    double allPayedPlusRestPrincipal=0;//待还本金、利息合计
    
    NSMutableDictionary *newDictionary=[[NSMutableDictionary alloc]initWithCapacity:6];
    
    NSMutableArray *totalForMonthArray=[[NSMutableArray alloc]initWithCapacity:monthCountForCurrentYear];
    NSMutableArray *principalForMonthArray=[[NSMutableArray alloc]initWithCapacity:monthCountForCurrentYear];
    NSMutableArray *interestForMonthArray=[[NSMutableArray alloc]initWithCapacity:monthCountForCurrentYear];
    NSMutableArray *restPrincipalArray=[[NSMutableArray alloc]initWithCapacity:monthCountForCurrentYear];
    NSMutableArray *allPayedArray=[[NSMutableArray alloc]initWithCapacity:monthCountForCurrentYear];
    NSMutableArray *allPayedPlusRestPrincipalArray=[[NSMutableArray alloc]initWithCapacity:monthCountForCurrentYear];
    
    if (_repayType==0) {
        //等额本金
        //每月还款额为：a/n
        principalForMonth = aLeftTotal /nLeftMonthCount;
        for (int i=0; i<monthCountForCurrentYear; i++) {
            restPrincipal = aLeftTotal - i*principalForMonth;//计算用
            interestForMonth = restPrincipal * iCurrentRateForMonth;
            totalForMonth = principalForMonth + interestForMonth;
            allPayed += totalForMonth;
            restPrincipal = restPrincipal - principalForMonth;//存储用
            if(i == nLeftMonthCount - 1)
                restPrincipal = 0;
            allPayedPlusRestPrincipal=allPayed+restPrincipal;
            
            totalForMonthArray[i]=[[NSNumber alloc]initWithDouble:totalForMonth];
            principalForMonthArray[i]=[[NSNumber alloc]initWithDouble:principalForMonth];
            interestForMonthArray[i]=[[NSNumber alloc]initWithDouble:interestForMonth];
            allPayedArray[i]=[[NSNumber alloc]initWithDouble:allPayed];
            restPrincipalArray[i]=[[NSNumber alloc]initWithDouble:restPrincipal];
            allPayedPlusRestPrincipalArray[i]=[[NSNumber alloc]initWithDouble:allPayedPlusRestPrincipal];
        }
    }
    else if (_repayType==1) {
        //等额本息
        double principalPayed=0;
        //每月还款额为：b=a*i*(1+i)^n/[(1+i)^n-1]
        totalForMonth=aLeftTotal  * iCurrentRateForMonth * powf(1+iCurrentRateForMonth,nLeftMonthCount)/(powf(1+iCurrentRateForMonth,nLeftMonthCount)-1);
        for (int i=0; i<monthCountForCurrentYear;i++) {
            //第n月还款利息为：（a×i－b）×（1＋i）的（n－1）次方＋b
            interestForMonth=(aLeftTotal *iCurrentRateForMonth - totalForMonth) * powf(1+iCurrentRateForMonth,i) + totalForMonth;
            principalForMonth=totalForMonth-interestForMonth;
            principalPayed+=principalForMonth;
            restPrincipal=aLeftTotal -principalPayed;
            if(i== nLeftMonthCount - 1)
                restPrincipal=0;
            
            allPayed += totalForMonth;
            //allPayed=(i+1)*totalForMonth;
            allPayedPlusRestPrincipal=allPayed+restPrincipal;
            
            totalForMonthArray[i]=[[NSNumber alloc]initWithDouble:totalForMonth];
            principalForMonthArray[i]=[[NSNumber alloc]initWithDouble:principalForMonth];
            interestForMonthArray[i]=[[NSNumber alloc]initWithDouble:interestForMonth];
            allPayedArray[i]=[[NSNumber alloc]initWithDouble:allPayed];
            restPrincipalArray[i]=[[NSNumber alloc]initWithDouble:restPrincipal];
            allPayedPlusRestPrincipalArray[i]=[[NSNumber alloc]initWithDouble:allPayedPlusRestPrincipal];
        }
    }
    
    [newDictionary setObject:totalForMonthArray forKey:kTotalForMonth];
    [newDictionary setObject:principalForMonthArray forKey:KPrincipalForMonth];
    [newDictionary setObject:interestForMonthArray forKey:kInterestForMonth];
    [newDictionary setObject:restPrincipalArray forKey:kRestPrincipal];
    [newDictionary setObject:allPayedArray forKey:kAllPayed];
    [newDictionary setObject:allPayedPlusRestPrincipalArray forKey:kAllPayedPlusRestPrincipal];
    
    
    
    return newDictionary;
}

- (NSMutableDictionary<NSString *,NSDictionary *> *)calculateData{
    NSMutableDictionary<NSString *,NSDictionary *> *detailMD = [NSMutableDictionary new];
    
    NSDateComponents *dateComponents = [[NSCalendar autoupdatingCurrentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.firstRepayDate];
    
    int firstYear = dateComponents.year;
    int firstMonth = dateComponents.month;
    
    int yearCount = self.nYearCount;
    if (firstMonth != 1) yearCount += 1;
    
    NSMutableDictionary *lastDic;
    
    for (int yearIndex = 0; yearIndex < yearCount; yearIndex++) {
        
        if (yearIndex > 0)
            lastDic = [self calculateDataForYear:yearIndex previousDictionary:lastDic];
        else
            lastDic = [self calculateDataForYear:yearIndex previousDictionary:nil];
        
        if (lastDic) [detailMD setObject:lastDic forKey:[NSString stringWithFormat:@"%d",firstYear + yearIndex]];
    }
    
    return detailMD;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    FloatingRateLoan *newFRL = [FloatingRateLoan new];
    newFRL.aTotal = [aDecoder decodeFloatForKey:@"aTotal"];
    newFRL.nYearCount = [aDecoder decodeIntegerForKey:@"nYearCount"];
    newFRL.firstRepayDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"firstRepayDate"];
    newFRL.iRateForYearArray = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"iRateForYearArray"];
    newFRL.repayType = [aDecoder decodeIntegerForKey:@"repayType"];
    return newFRL;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeFloat:self.aTotal forKey:@"aTotal"];
    [aCoder encodeInteger:self.nYearCount forKey:@"nYearCount"];
    [aCoder encodeObject:self.firstRepayDate forKey:@"firstRepayDate"];
    [aCoder encodeObject:self.iRateForYearArray forKey:@"iRateForYearArray"];
    [aCoder encodeInteger:self.repayType forKey:@"repayType"];
}

@end
