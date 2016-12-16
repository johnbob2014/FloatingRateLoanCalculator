//
//  FloatingRateLoan.h
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/16.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

static NSString * const kTotalForMonth;
static NSString * const KPrincipalForMonth;
static NSString * const kInterestForMonth;
static NSString * const kRestPrincipal;
static NSString * const kAllPayed;
static NSString * const kAllPayedPlusRestPrincipal;

#import <Foundation/Foundation.h>

@interface FloatingRateLoan : NSObject

/**
 贷款类型，0为浮动利率，1为固定利率
 */
@property(assign,nonatomic) int loanType;

/**
 贷款名称
 */
@property(copy,nonatomic) NSString *loanName;

/**
 必需，贷款总额
 */
@property(assign,nonatomic) float aTotal;

/**
 必需，贷款期次（年数）
 */
@property(assign,nonatomic) int nYearCount;

/**
 必需，贷款年利率 数组
 */
@property(strong,nonatomic) NSArray <NSNumber *> *iRateForYearArray;

/**
 必需，还款类型，0为等额本金，1为等额本息
 */
@property(assign,nonatomic) int repayType;

-(NSMutableDictionary <NSString *,NSArray *> *)calculateDataForYear:(NSInteger)yearIndex previousDictionary:(NSMutableDictionary <NSString *,NSArray *> *)previousDictionary;

@end
