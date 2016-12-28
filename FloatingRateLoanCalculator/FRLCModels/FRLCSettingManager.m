//
//  FRLCSettingManager.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/20.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#define AppID @"1190166507"

#define AppWXID @"wx"
#define AppURLString @"https://itunes.apple.com/app/id1190166507"
#define AppProductIDArray @[@"com.ZhangBaoGuo.FloatingRateLoanCalculator.RepayAlertAndExportData"]
#define AppQRCodeImage @"FRLCAppQRCodeImage.png"
#define AppDebugCode @"2170f9442e52aad52e3c3b1c3b5d6a8a143289797b6b1fdab6e67d0fc6979668"

#import "FRLCSettingManager.h"

@implementation FRLCSettingManager

+ (instancetype)defaultManager{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        // 如果没有更新过 或者 距离上次更新时间超过1天，则进行更新
        if (!self.appInfoLastUpdateDate || [[NSDate date] timeIntervalSinceDate:self.appInfoLastUpdateDate] > 24 * 60 * 60){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [FRLCSettingManager updateAppInfoWithCompletionBlock:nil];
                [FRLCSettingManager updateLoanRateWithCompletionBlock:nil];
            });
        }
    }
    return self;
}

#pragma mark - App Info
+ (void)updateAppInfoWithCompletionBlock:(void(^)())completionBlock{
    if(DEBUGMODE) NSLog(@"正在更新AppInfo...\n");
    // 更新下载链接
    NSString *appInfoURLString = @"http://www.7xpt9o.com1.z0.glb.clouddn.com/AppInfo.json";
    
    NSError *readDataError;
    NSData *appInfoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appInfoURLString] options:NSDataReadingMapped error:&readDataError];
    if (!appInfoData){
        if(DEBUGMODE) NSLog(@"从网络获取AppInfo数据出错 : %@",readDataError.localizedDescription);
        if (completionBlock) completionBlock();
        return;
    }
    
    NSError *parseJSONError;
    NSArray *appInfoDictionaryArray = [NSJSONSerialization JSONObjectWithData:appInfoData options:NSJSONReadingMutableContainers error:&parseJSONError];
    if (!appInfoDictionaryArray){
        if(DEBUGMODE) NSLog(@"解析AppInfo数据出错 : %@",parseJSONError.localizedDescription);
        if (completionBlock) completionBlock();
        return;
    }
    
    NSDictionary *appInfoDictionary = nil;
    
    for (NSDictionary *dic in appInfoDictionaryArray) {
        
        if ([dic.allKeys containsObject:@"AppID"]){
            if ([dic[@"AppID"] isEqualToString:AppID]) {
                appInfoDictionary = dic;
                break;
            }
        }
    }
    
    if (!appInfoDictionary){
        if(DEBUGMODE) NSLog(@"更新AppInfo失败！");
        if (completionBlock) completionBlock();
        return;
    }
    
    if(DEBUGMODE) NSLog(@"\n%@",appInfoDictionary);
    if(DEBUGMODE) NSLog(@"更新AppInfo成功");
    
    // 更新信息数组
    [[NSUserDefaults standardUserDefaults] setValue:appInfoDictionary forKey:@"appInfoDictionary"];
    
    // 更新最后更新时间
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"appInfoLastUpdateDate"];
    
    // 更新下载链接
    if ([appInfoDictionary.allKeys containsObject:@"AppURLString"]){
        NSString *appURLString = appInfoDictionary[@"AppURLString"];
        if(DEBUGMODE) NSLog(@"\nappURLString : %@",appURLString);
        [[NSUserDefaults standardUserDefaults] setValue:appURLString forKey:@"appURLString"];
    }
    
    // 更新二维码图片
    if ([appInfoDictionary.allKeys containsObject:@"AppQRCodeImageURLString"]){
        NSString *appQRCodeImageURLString = appInfoDictionary[@"AppQRCodeImageURLString"];
        
        NSError *readImageDataError;
        NSData *appQRCodeImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appQRCodeImageURLString] options:NSDataReadingMapped error:&readImageDataError];
        
        if (appQRCodeImageData){
            [[NSUserDefaults standardUserDefaults] setValue:appQRCodeImageData forKey:@"appQRCodeImageData"];
            if(DEBUGMODE) NSLog(@"更新AppQRCodeImage成功");
            
        }else{
            if(DEBUGMODE) NSLog(@"从网络获取AppQRCodeImage数据出错 : %@",readImageDataError.localizedDescription);
            if(DEBUGMODE) NSLog(@"更新AppQRCodeImage失败！");
        }
    }else{
        if(DEBUGMODE) NSLog(@"未找到AppQRCodeImage！");
    }
    
    // 更新内购项目数组
    if ([appInfoDictionary.allKeys containsObject:@"AppProductIDArray"]){
        NSArray <NSString *> *appProductIDArray = appInfoDictionary[@"AppProductIDArray"];
        if(DEBUGMODE) NSLog(@"\nappProductIDArray :\n%@",appProductIDArray);
        [[NSUserDefaults standardUserDefaults] setValue:appProductIDArray forKey:@"appProductIDArray"];
    }
    
    // 更新微信ID
    if ([appInfoDictionary.allKeys containsObject:@"AppWXID"]){
        NSString *appWXID = appInfoDictionary[@"AppWXID"];
        if(DEBUGMODE) NSLog(@"appWXID : %@",appWXID);
        [[NSUserDefaults standardUserDefaults] setValue:appWXID forKey:@"appWXID"];
    }
    
    // 更新AppDebugCode 更新之前先清空！！！
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"appDebugCode"];
    if ([appInfoDictionary.allKeys containsObject:@"AppDebugCode"]){
        NSString *appDebugCode = appInfoDictionary[@"AppDebugCode"];
        if(DEBUGMODE) NSLog(@"appDebugCode : %@",appDebugCode);
        [[NSUserDefaults standardUserDefaults] setValue:appDebugCode forKey:@"appDebugCode"];
    }
    
    // 更新AppVersion
    if ([appInfoDictionary.allKeys containsObject:@"AppVersion"]){
        NSString *appVersion = appInfoDictionary[@"AppVersion"];
        if(DEBUGMODE) NSLog(@"appVersion : %@",appVersion);
        [[NSUserDefaults standardUserDefaults] setValue:appVersion forKey:@"appVersion"];
    }
    
    // 保存数据！！！
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (completionBlock) completionBlock();
}

// 以下属性只有获取方法，更新在上面方法中完成
- (NSDate *)appInfoLastUpdateDate{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"appInfoLastUpdateDate"];
}

- (NSDictionary *)appInfoDictionary{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"appInfoDictionary"];
}

- (NSString *)appURLString{
    NSString *appURLString = [[NSUserDefaults standardUserDefaults] objectForKey:@"appURLString"];
    if (appURLString) return appURLString;
    else return AppURLString;
}

- (UIImage *)appQRCodeImage{
    NSData *appQRCodeImageData = [[NSUserDefaults standardUserDefaults] valueForKey:@"appQRCodeImageData"];
    if (appQRCodeImageData) return [UIImage imageWithData:appQRCodeImageData];
    else return [UIImage imageNamed:AppQRCodeImage];
}

- (NSArray<NSString *> *)appProductIDArray{
    NSArray<NSString *> *appProductIDArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"appProductIDArray"];
    if (appProductIDArray) return appProductIDArray;
    else return AppProductIDArray;
}

- (NSString *)appWXID{
    NSString *appWXID = [[NSUserDefaults standardUserDefaults] objectForKey:@"appWXID"];
    if (appWXID) return appWXID;
    else return AppWXID;
}

- (NSString *)appDebugCode{
    NSString *appDebugCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"appDebugCode"];
    if (appDebugCode) return appDebugCode;
    else return AppDebugCode;
}

- (NSString *)appVersion{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"appVersion"];
}

#pragma mark - LoanRate

+ (void)updateLoanRateWithCompletionBlock:(void(^)())completionBlock{
    if(DEBUGMODE) NSLog(@"正在更新LoanRate...\n");
    // 更新下载链接
    NSString *appInfoURLString = @"http://www.7xpt9o.com1.z0.glb.clouddn.com/LoanRate.json";
    
    NSError *readDataError;
    NSData *loanRateData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appInfoURLString] options:NSDataReadingMapped error:&readDataError];
    if (!loanRateData){
        if(DEBUGMODE) NSLog(@"从网络获取LoanRate数据出错 : %@",readDataError.localizedDescription);
        if (completionBlock) completionBlock();
        return;
    }
    
    NSError *parseJSONError;
    NSDictionary *loanRateDictionary = [NSJSONSerialization JSONObjectWithData:loanRateData options:NSJSONReadingMutableContainers error:&parseJSONError];
    if (!loanRateDictionary){
        if(DEBUGMODE) NSLog(@"解析LoanRate数据出错 : %@",parseJSONError.localizedDescription);
        if (completionBlock) completionBlock();
        return;
    }
    
    //NSLog(@"%@",loanRateDictionary);
    
    if ([loanRateDictionary.allKeys containsObject:@"Housing Provident Fund"]){
        NSArray <NSDictionary *> *hpfArray = loanRateDictionary[@"Housing Provident Fund"];
        if(DEBUGMODE) NSLog(@"\nHousing Provident Fund Array :\n%@",hpfArray);
        [[NSUserDefaults standardUserDefaults] setValue:hpfArray forKey:@"Housing Provident Fund"];
    }


}

- (NSArray<NSDictionary *> *)loanRateArrayForHousingProvidentFund{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"Housing Provident Fund"];
}


- (float)loanRateOfType:(enum LoanCreditorType)lloanCreditorType moreThan5Years:(BOOL)moreThan5Years beforeDate:(NSDate *)aDate{
    
    NSArray <NSDictionary *> *queryArray = [NSArray new];
    if (lloanCreditorType == LoanCreditorTypeHousingProvidentFund) queryArray = self.loanRateArrayForHousingProvidentFund;
    else if (lloanCreditorType == LoanCreditorTypeCommerce) queryArray = self.loanRateArrayForCommerce;
    
    __block NSTimeInterval smallestTI = 0.0;
    __block NSUInteger resultIndex = 0;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    [queryArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDate *queryDate = [dateFormatter dateFromString:obj[kAdjustDate]];
        
        NSTimeInterval deltaTI = [aDate timeIntervalSinceDate:queryDate];
        
        if (deltaTI > 0){
            if (smallestTI == 0.0) smallestTI = deltaTI;
            if (smallestTI > deltaTI){
                smallestTI = deltaTI;
                resultIndex = idx;
            }
        }
    }];
    
    NSDictionary *resultDic = queryArray[resultIndex];
    
    float resultLoanRate;
    
    if (moreThan5Years) resultLoanRate = [resultDic[kRateMoreThan5Years] floatValue];
    else resultLoanRate = [resultDic[kRateLessOrEqual5Years] floatValue];
    
    return resultLoanRate;
}

#pragma mark - Items

- (BOOL)debugMode{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"debugMode"];
}

- (void)setDebugMode:(BOOL)debugMode{
    [[NSUserDefaults standardUserDefaults] setBool:debugMode forKey:@"debugMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasPurchasedRepayAlert{
    BOOL hasPurchasedRepayAlert = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPurchasedRepayAlert"];
    return hasPurchasedRepayAlert;
}

- (void)setHasPurchasedRepayAlert:(BOOL)hasPurchasedRepayAlert{
    [[NSUserDefaults standardUserDefaults] setBool:hasPurchasedRepayAlert forKey:@"hasPurchasedRepayAlert"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
