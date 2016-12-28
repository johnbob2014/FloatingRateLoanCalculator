//
//  FRLStorer+Assistant.h
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/28.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FRLStorer+CoreDataClass.h"
#import "FloatingRateLoan.h"

#define EntityName_FRLStorer @"FRLStorer"

@interface FRLStorer (Assistant)

+ (FRLStorer *)newFRLStorerWithFloatingRateLoan:(FloatingRateLoan *)frl inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray <FRLStorer *> *)fetchFRLStorersWithQueryDate:(NSDate *)queryDate inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSInteger)removeFRLStorersWithQueryDate:(NSDate *)queryDate inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray <FRLStorer *> *)fetchAllFRLStorersInManagedObjectContext:(NSManagedObjectContext *)context;

@end
