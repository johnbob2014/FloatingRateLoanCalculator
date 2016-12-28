//
//  FRLStorer+Assistant.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/28.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FRLStorer+Assistant.h"

@implementation FRLStorer (Assistant)

+ (FRLStorer *)newFRLStorerWithFloatingRateLoan:(FloatingRateLoan *)frl inManagedObjectContext:(NSManagedObjectContext *)context{
    FRLStorer *storer = [NSEntityDescription insertNewObjectForEntityForName:EntityName_FRLStorer inManagedObjectContext:context];
    
    storer.archivedData = [NSKeyedArchiver archivedDataWithRootObject:frl];
    storer.queryDate = [NSDate date];
    
    // 保存修改后的信息
    [context save:NULL];
    
    return storer;
}

+ (NSArray <FRLStorer *> *)fetchFRLStorersWithQueryDate:(NSDate *)queryDate inManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_FRLStorer];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"queryDate = %@",queryDate];
    NSError *fetchError;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    return matches;
}

+ (NSInteger)removeFRLStorersWithQueryDate:(NSDate *)queryDate inManagedObjectContext:(NSManagedObjectContext *)context{
    NSInteger number = 0;
    for (FRLStorer *storer in [FRLStorer fetchFRLStorersWithQueryDate:queryDate inManagedObjectContext:context]) {
        [context deleteObject:storer];
        if ([context save:NULL]) number++;
    }
    return number;
}

+ (NSArray <FRLStorer *> *)fetchAllFRLStorersInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_FRLStorer];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"queryDate" ascending:YES]];
    NSError *fetchError;
    NSArray <FRLStorer *> *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) NSLog(@"Fetch All FRLStorers Error : %@",fetchError.localizedDescription);
    return matches;
}

@end
