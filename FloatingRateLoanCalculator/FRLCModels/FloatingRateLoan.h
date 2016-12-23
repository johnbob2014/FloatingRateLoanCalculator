//
//  FloatingRateLoan.h
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/16.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

/*
static NSString * const kTotalForMonth;
static NSString * const KPrincipalForMonth;
static NSString * const kInterestForMonth;
static NSString * const kRestPrincipal;
static NSString * const kAllPayed;
static NSString * const kAllPayedPlusRestPrincipal;
*/

#import <Foundation/Foundation.h>

@interface FloatingRateLoan : NSObject <NSCoding>

/**
 贷款名称
 */
@property(copy,nonatomic) NSString *loanName;

/**
 上次计算时间
 */
@property(strong,nonatomic) NSDate *lastCalculateDate;

/**
 必需，首次还款年月
 */
@property(strong,nonatomic) NSDate *firstRepayDate;

/**
 只读，首次还款年
 */
@property(assign,nonatomic,readonly) NSInteger firstRepayYear;

/**
 只读，首次还款月
 */
@property(assign,nonatomic,readonly) NSInteger firstRepayMonth;

/**
 必需，贷款总额
 */
@property(assign,nonatomic) float aTotal;

/**
 必需，贷款年数
 */
@property(assign,nonatomic) NSInteger nYearCount;

/**
 只读，计算年数
 */
@property(assign,nonatomic,readonly) NSInteger calculateYearCount;

/**
 必需，贷款年利率 数组
 */
@property(strong,nonatomic) NSArray <NSNumber *> *iRateForYearArray;

/**
 必需，还款类型
 */
@property(assign,nonatomic) LoanRepayType repayType;

/**
 计算结果

 @return 以 年份字符串、详情字典 为键值对的可变字典
 */
- (NSMutableDictionary<NSString *,NSDictionary *> *)calculateData;

@end
