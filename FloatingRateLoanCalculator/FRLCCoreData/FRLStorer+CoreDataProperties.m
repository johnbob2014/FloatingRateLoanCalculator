//
//  FRLStorer+CoreDataProperties.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/28.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FRLStorer+CoreDataProperties.h"

@implementation FRLStorer (CoreDataProperties)

+ (NSFetchRequest<FRLStorer *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"FRLStorer"];
}

@dynamic queryDate;
@dynamic archivedData;

@end
