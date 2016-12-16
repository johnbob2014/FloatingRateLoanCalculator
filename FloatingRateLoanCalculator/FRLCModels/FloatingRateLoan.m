//
//  FloatingRateLoan.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/16.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

static NSString * const kTotalForMonth=@"kTotalForMonth";
static NSString * const KPrincipalForMonth=@"KPrincipalForMonth";
static NSString * const kInterestForMonth=@"kInterestForMonth";
static NSString * const kRestPrincipal=@"kRestPrincipal";
static NSString * const kAllPayed=@"kAllPayed";
static NSString * const kAllPayedPlusRestPrincipal=@"kAllPayedPlusRestPrincipal";

#import "FloatingRateLoan.h"

@interface FloatingRateLoan()

/**
 贷款期次（月数）
 */
//@property(assign,nonatomic) int nMonthCounts;

/**
 贷款月利率
 */
//@property(assign,nonatomic) float iRateForMonth;

@end

@implementation FloatingRateLoan

/*
-(float) totalInterest{
    float totalInterest=0;
    switch (_repayType) {
        case 0:
            //总利息（n+1）*a*i/2
            totalInterest=(_nMonthCounts+1)*_aTotal*_iRateForMonth/2;
            break;
        case 1:
            //总利息 Y=n*a*i*（1＋i）^n/[（1＋i）^n－1]-a
            totalInterest=_nMonthCounts*_aTotal*_iRateForMonth*powf(1+_iRateForMonth, _nMonthCounts)/(powf(1+_iRateForMonth, _nMonthCounts)-1)-_aTotal;
            break;
            
        default:
            break;
    }
    return totalInterest;
}
*/

-(NSMutableDictionary <NSString *,NSArray *> *)calculateDataForYear:(NSInteger)yearIndex previousDictionary:(NSMutableDictionary <NSString *,NSArray *> *)previousDictionary{
    
    if (yearIndex >= self.nYearCount) return nil;
    
    // 上年剩余本金
    float aLeftTotal = self.aTotal;
    if (yearIndex > 0 && previousDictionary){
        aLeftTotal = [[[previousDictionary valueForKey:kRestPrincipal] lastObject] floatValue];
    }
    
    // 剩余期次
    NSUInteger nLeftMonthCount = (self.nYearCount - yearIndex) * 12;
    
    // 当年年度利率
    float iCurrentRateForMonth = [self.iRateForYearArray[yearIndex] floatValue] / 12.0 / 100.0;
    
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
    
    NSMutableArray *totalForMonthArray=[[NSMutableArray alloc]initWithCapacity:12];
    NSMutableArray *principalForMonthArray=[[NSMutableArray alloc]initWithCapacity:12];
    NSMutableArray *interestForMonthArray=[[NSMutableArray alloc]initWithCapacity:12];
    NSMutableArray *restPrincipalArray=[[NSMutableArray alloc]initWithCapacity:12];
    NSMutableArray *allPayedArray=[[NSMutableArray alloc]initWithCapacity:12];
    NSMutableArray *allPayedPlusRestPrincipalArray=[[NSMutableArray alloc]initWithCapacity:12];
    
    if (_repayType==0) {
        //等额本金
        //每月还款额为：a/n
        principalForMonth = aLeftTotal /nLeftMonthCount;
        for (int i=0; i<12; i++) {
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
        for (int i=0; i<12;i++) {
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


@end
