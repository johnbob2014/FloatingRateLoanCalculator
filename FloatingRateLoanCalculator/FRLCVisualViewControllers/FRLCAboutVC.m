//
//  FRLCAboutVC.m
//  FloatingRateLoanCalculator
//
//  Created by BobZhang on 16/12/28.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FRLCAboutVC.h"
#import "FRLCSettingManager.h"

@interface FRLCAboutVC ()
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *versonLabel;
@property (nonatomic,strong) UITextView *detailTextView;
@property (nonatomic,strong) UILabel *bottomLabel;
@end

@implementation FRLCAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.title=NSLocalizedString(@"关于",@"About");
    
    [self initAboutUI];
    
}

-(void)initAboutUI{
    
    UITapGestureRecognizer *threeTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(threeTapGR:)];
    threeTapGR.numberOfTapsRequired = 3;
    threeTapGR.numberOfTouchesRequired = 1;
    self.imageView=[[UIImageView alloc]initForAutoLayout];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:threeTapGR];
    [self.imageView setImage:[UIImage imageNamed:@"37-List 300_300"]];
    [self.view addSubview:self.imageView];
    [self.imageView autoSetDimensionsToSize:CGSizeMake(80, 80)];
    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:80];
    [self.imageView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.view withOffset:-80];
    
    self.nameLabel=[[UILabel alloc]initForAutoLayout];
    self.nameLabel.text=NSLocalizedString(@"浮动利率", @"FRLC");
    self.nameLabel.font=[UIFont bodyFontWithSizeMultiplier:1.6];
    [self.view addSubview:self.nameLabel];
    [self.nameLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.imageView withOffset:-10];
    [self.nameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.imageView withOffset:10];
    
    self.versonLabel=[[UILabel alloc]initForAutoLayout];
    self.versonLabel.text=[FRLCSettingManager defaultManager].appVersion;
    self.versonLabel.font=[UIFont bodyFontWithSizeMultiplier:0.8];
    [self.view addSubview:self.versonLabel];
    [self.versonLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self.nameLabel];
    [self.versonLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.imageView withOffset:-10];
    
    self.bottomLabel=[[UILabel alloc]initForAutoLayout];
    self.bottomLabel.numberOfLines = 0;
    self.bottomLabel.font = [UIFont bodyFontWithSizeMultiplier:0.8];
    self.bottomLabel.text=NSLocalizedString(@"手机 & 微信 : +86 17096027537\n邮箱 : johnbob2014@icloud.com\n2016 CTP Technology Co.,Ltd",@"Phone & WeChat : +86 17096027537\nEmail : johnbob2014@icloud.com\n2016 CTP Technology Co.,Ltd");
    self.bottomLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:self.bottomLabel];
    [self.bottomLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.bottomLabel autoSetDimension:ALDimensionHeight toSize:100];
    
    UITapGestureRecognizer *threeTouch_OneTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(threeTouch_OneTapGR:)];
    threeTouch_OneTapGR.numberOfTapsRequired = 1;
    threeTouch_OneTapGR.numberOfTouchesRequired = 3;
    
    self.detailTextView=[[UITextView alloc]initForAutoLayout];
    [self.detailTextView addGestureRecognizer:threeTouch_OneTapGR];
    self.detailTextView.editable=NO;
    self.detailTextView.font=[UIFont bodyFontWithSizeMultiplier:1.0];
    self.detailTextView.text=NSLocalizedString(@"真正好用的专业贷款计算器。", @"Reaally powerful loan calculator.");
    
    self.detailTextView.backgroundColor = RandomFlatColor;
    self.detailTextView.textColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.detailTextView.backgroundColor isFlat:YES];
    
    [self.view addSubview:self.detailTextView];
    [self.detailTextView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageView withOffset:20];
    [self.detailTextView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [self.detailTextView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    [self.detailTextView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.bottomLabel withOffset:-20];
}

- (void)threeTouch_OneTapGR:(UITapGestureRecognizer *)sender{
    if (DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
        [FRLCSettingManager defaultManager].debugMode = ![FRLCSettingManager defaultManager].debugMode;
        
        if ([FRLCSettingManager defaultManager].debugMode){
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"进入调试模式",@"Enter debug mode" )];
        }else{
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"退出调试模式",@"Quite debug mode" )];
        }
    
    //[SVProgressHUD dismissWithDelay:3.0];
    
}

- (void)threeTapGR:(UITapGestureRecognizer *)sender{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"请稍后...",@"Wait a moment...")];
    [FRLCSettingManager updateAppInfoWithCompletionBlock:^{
        [SVProgressHUD dismiss];
        
        __block UITextField *tf;
        UIAlertController *alertController = [UIAlertController singleTextFieldAlertControllerWithTitle:NSLocalizedString(@"FRLC", @"FRLC")
                                                                                                message:NSLocalizedString(@"请输入调试码",@"Enter debug code")
                                                                                        okActionHandler:^(UIAlertAction *action) {
                                                                                            [self checkAppDebugCode:tf.text];
                                                                                        }
                                                                          textFieldConfigurationHandler:^(UITextField *textField) {
                                                                              tf = textField;
                                                                          }];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)checkAppDebugCode:(NSString *)inputString{
    NSLog(@"%@",[FRLCSettingManager defaultManager].appDebugCode);
    if([[inputString SHA256] isEqualToString:[FRLCSettingManager defaultManager].appDebugCode]){
        [FRLCSettingManager defaultManager].hasPurchasedRepayAlert = YES;
        
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"^_^ 验证成功",@"^_^ Verify Succeeded")];
    }else{
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@">_< 验证失败",@">_< Verify Failed")];
    }
    
}

@end
