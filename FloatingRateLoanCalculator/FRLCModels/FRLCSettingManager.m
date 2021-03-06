//
//  FRLCSettingManager.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/20.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#define AppID @"1190166507"
#define AppWXID @"wxd8095af0c6b13296"

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

#pragma mark - App Info
+ (void)updateAppInfoWithCompletionBlock:(void(^)())completionBlock{
    if(DEBUGMODE) NSLog(@"正在更新AppInfo...\n");
    // 更新下载链接
    NSString *appInfoURLString = @"https://oixoepy7l.qnssl.com/AppInfo.json";//www.7xpt9o.com1.z0.glb.clouddn.com
    
    NSError *readDataError;
    NSData *appInfoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appInfoURLString] options:NSDataReadingMapped error:&readDataError];
    
    if (!appInfoData){
        if(DEBUGMODE) NSLog(@"从网络获取AppInfo数据出错 : %@",readDataError.localizedDescription);
        if(DEBUGMODE) NSLog(@"\n从本地获取AppInfo数据...");
        NSURL *localFileURL = [[NSBundle mainBundle] URLForResource:@"AppInfo" withExtension:@"json"];
        appInfoData = [NSData dataWithContentsOfURL:localFileURL options:NSDataReadingMapped error:&readDataError];
    }
    
    if (!appInfoData){
        if(DEBUGMODE) NSLog(@"\n从本地获取AppInfo数据出错 : %@",readDataError.localizedDescription);
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
//    NSString *appURLString = [[NSUserDefaults standardUserDefaults] objectForKey:@"appURLString"];
//    if (appURLString) return appURLString;
//    else return AppURLString;
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"appURLString"];
}

- (UIImage *)appQRCodeImage{
    NSData *appQRCodeImageData = [[NSUserDefaults standardUserDefaults] valueForKey:@"appQRCodeImageData"];
//    if (appQRCodeImageData) return [UIImage imageWithData:appQRCodeImageData];
//    else return [UIImage imageNamed:AppQRCodeImage];
    return [UIImage imageWithData:appQRCodeImageData];
}

- (NSArray<NSString *> *)appProductIDArray{
    NSArray<NSString *> *appProductIDArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"appProductIDArray"];
//    if (appProductIDArray) return appProductIDArray;
//    else return AppProductIDArray;
    return appProductIDArray;
}

- (NSString *)appWXID{
    NSString *appWXID = [[NSUserDefaults standardUserDefaults] objectForKey:@"appWXID"];
    if (appWXID) return appWXID;
    else return AppWXID;
}

- (NSString *)appDebugCode{
//    NSString *appDebugCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"appDebugCode"];
//    if (appDebugCode) return appDebugCode;
//    else return AppDebugCode;
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"appDebugCode"];
}

- (NSString *)appVersion{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"appVersion"];
}

#pragma mark - LoanRate

+ (void)updateLoanRateWithCompletionBlock:(void(^)())completionBlock{
    if(DEBUGMODE) NSLog(@"正在更新LoanRate...\n");
    // 更新下载链接
    NSString *appInfoURLString = @"https://oixoepy7l.qnssl.com/LoanRate.json";
    
    NSError *readDataError;
    NSData *loanRateData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appInfoURLString] options:NSDataReadingMapped error:&readDataError];
    if (!loanRateData){
        if(DEBUGMODE) NSLog(@"从网络获取LoanRate数据出错 : %@",readDataError.localizedDescription);
        if(DEBUGMODE) NSLog(@"\n从本地获取LoanRate数据...");
        NSURL *localFileURL = [[NSBundle mainBundle] URLForResource:@"LoanRate" withExtension:@"json"];
        loanRateData = [NSData dataWithContentsOfURL:localFileURL options:NSDataReadingMapped error:&readDataError];
    }
    
    if (!loanRateData){
        if(DEBUGMODE) NSLog(@"\n从本地获取LoanRate数据出错 : %@",readDataError.localizedDescription);
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

- (NSString *)lastLoanName{
    NSString *placemark = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastLoanName"];
    return placemark;
}

- (void)setLasttPlacemark:(NSString *)lastLoanName{
    [[NSUserDefaults standardUserDefaults] setValue:lastLoanName forKey:@"lastLoanName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)lastRepayDay{
    NSString *placemark = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastRepayDay"];
    return placemark;
}

- (void)setLastRepayDay:(NSString *)lastRepayDay{
    [[NSUserDefaults standardUserDefaults] setValue:lastRepayDay forKey:@"lastRepayDay"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)lastCustomRate{
    float rate = [[NSUserDefaults standardUserDefaults] floatForKey:@"lastCustomRate"];
    if (rate == 0.0) rate = 4.25;
    return rate;
}

- (void)setLastCustomRate:(float)lastCustomRate{
    [[NSUserDefaults standardUserDefaults] setFloat:lastCustomRate forKey:@"lastCustomRate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)praiseCount{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"praiseCount"];
}

- (void)setPraiseCount:(NSInteger)praiseCount{
    [[NSUserDefaults standardUserDefaults] setInteger:praiseCount forKey:@"praiseCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
