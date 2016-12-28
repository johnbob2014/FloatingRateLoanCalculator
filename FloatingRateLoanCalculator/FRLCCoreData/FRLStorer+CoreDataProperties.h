//
//  FRLStorer+CoreDataProperties.h
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/28.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FRLStorer+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FRLStorer (CoreDataProperties)

+ (NSFetchRequest<FRLStorer *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *queryDate;
@property (nullable, nonatomic, retain) NSData *archivedData;

@end

NS_ASSUME_NONNULL_END
