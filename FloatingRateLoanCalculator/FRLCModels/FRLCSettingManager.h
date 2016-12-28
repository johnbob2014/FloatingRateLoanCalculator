//
//  FRLCSettingManager.h
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/20.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#define kAdjustDate @"AdjustDate"
#define kRateLessOrEqual5Years @"RateLessOrEqual5Years"
#define kRateMoreThan5Years @"RateMoreThan5Years"

#import <Foundation/Foundation.h>

@interface FRLCSettingManager : NSObject

#pragma mark - 类方法

/**
 *  通用设置管理器
 */
+ (instancetype)defaultManager;

/**
 *  从网络更新AppInfo信息，完成后调用指定块
 *
 *  @param completionBlock 更新完成后调用的块
 */
+ (void)updateAppInfoWithCompletionBlock:(void(^)())completionBlock;

#pragma mark - AppInfo

/**
 * appInfo上次更新时间
 */
@property (strong,nonatomic) NSDate *appInfoLastUpdateDate;

/**
 * appInfo字典
 */
@property (strong,nonatomic) NSDictionary *appInfoDictionary;

/**
 * app下载地址
 */
@property (strong,nonatomic) NSString *appURLString;

/**
 * app二维码图片
 */
@property (strong,nonatomic) UIImage *appQRCodeImage;

/**
 * app内购产品ID数组
 */
@property (strong,nonatomic) NSArray <NSString *> *appProductIDArray;

/**
 * app微信ID
 */
@property (strong,nonatomic) NSString *appWXID;

/**
 * app调试码
 */
@property (strong,nonatomic) NSString *appDebugCode;

/**
 * app版本号
 */
@property (strong,nonatomic) NSString *appVersion;

#pragma mark - LoanRate

/**
 * 贷款利率 字典
 */
@property (strong,nonatomic) NSDictionary *loanRateDictionary;

/**
 * 公积金贷款利率 数组
 */
@property (strong,nonatomic) NSArray <NSDictionary *> *loanRateArrayForHousingProvidentFund;

/**
 * 商业贷款利率 数组
 */
@property (strong,nonatomic) NSArray <NSDictionary *> *loanRateArrayForCommerce;

/**
 * 查询利率
 */
- (float)loanRateOfType:(enum LoanCreditorType)lloanCreditorType moreThan5Years:(BOOL)moreThan5Years beforeDate:(NSDate *)aDate;

#pragma mark - 各项设置

/**
 * 是否处于调试模式
 */
@property (assign,nonatomic) BOOL debugMode;

/**
 * 是否购买还款提醒
 */
@property (assign,nonatomic) BOOL hasPurchasedRepayAlert;

@end
