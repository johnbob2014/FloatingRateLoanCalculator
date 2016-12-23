//
//  GCDetailTableViewCell.h
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/21.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

typedef NS_ENUM(NSInteger,AlignmentStyle){
    AlignmentStyleLeft = 0,
    AlignmentStyleRight
};

#import <UIKit/UIKit.h>

@interface GCDetailTableViewCell : UITableViewCell

/**
 标签个数
 */
@property (assign,nonatomic) NSInteger labelCount;

/**
 标签偏移
 */
@property (assign,nonatomic) float labelOffset;

/**
 对齐方式
 */
@property (assign,nonatomic) AlignmentStyle alignmentStyle;

/**
 标签数组
 */
@property (strong,nonatomic) NSArray <UILabel *> *labelArray;

@end
