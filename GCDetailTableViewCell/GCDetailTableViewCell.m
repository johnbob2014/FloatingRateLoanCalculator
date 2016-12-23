//
//  GCDetailTableViewCell.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/21.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCDetailTableViewCell.h"

@implementation GCDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

- (void)setLabelCount:(NSInteger)labelCount{
    if (labelCount <= 0 || _labelCount == labelCount) return;
    
    _labelCount = labelCount;
    
    /*
    float totalWidth = self.contentView.bounds.size.width;
    NSLog(@"totalWidth: %f",totalWidth);
    float labelWidth = (totalWidth - self.labelOffset * (float)(labelCount - 1))/(float)labelCount;
    */
    
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    NSMutableArray <UILabel *> *labelMA = [[NSMutableArray alloc] initWithCapacity:labelCount];
    
    UILabel *lastLabel;
    
    for (int i = 0; i < self.labelCount; i++) {
        UILabel *newLabel = [UILabel newAutoLayoutView];
        newLabel.textAlignment = NSTextAlignmentRight;
        newLabel.font = [UIFont bodyFontWithSizeMultiplier:0.8];
        
        [self.contentView addSubview:newLabel];
        
        [newLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        //[newLabel autoSetDimension:ALDimensionWidth toSize:labelWidth];
        
        if (i == 0) [newLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        else [newLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lastLabel withOffset:self.labelOffset];
        
        lastLabel = newLabel;
        [labelMA addObject:newLabel];
    }
    
    self.labelArray = labelMA;
}

- (void)updateLabelArray{
    
}

@end
