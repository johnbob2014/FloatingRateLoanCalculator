//
//  FRLCMainRETVC.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FRLCMainRETVC.h"
#import "FloatingRateLoan.h"

@interface FRLCMainRETVC ()

@end

@implementation FRLCMainRETVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *b = [UIButton newAutoLayoutView];
    [b setStyle:UIButtonStyleSuccess];
    [b setTitle:@"New Journey!" forState:UIControlStateNormal];
   
    
    [self.view addSubview:b];
    [b autoCenterInSuperview];
    
    FloatingRateLoan *frl = [FloatingRateLoan new];
    frl.aTotal = 315000.0;
    frl.nYearCount = 20;
    frl.repayType = 0;
    frl.iRateForYearArray = @[@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25,@4.25];
    
    NSMutableDictionary *lastDic;
    
    for (int i = 0; i < 20; i++) {
        
        if (i > 0){
            lastDic = [frl calculateDataForYear:i previousDictionary:lastDic];
        }else{
            lastDic = [frl calculateDataForYear:i previousDictionary:nil];
        }
        
        //NSArray *inte = [lastDic valueForKey:kInterestForMonth];
        NSLog(@"\n%@",lastDic);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
