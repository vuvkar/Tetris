//
//  InitialViewController.m
//  Tetris
//
//  Created by Vahe Karamyan on 23.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "InitialViewController.h"

@interface InitialViewController ()

@property (strong, nonatomic) IBOutlet UIView *popUpView;

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
    self.view.backgroundColor=[UIColor lightGrayColor];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showInView:self.view animated:YES];
    }
    else
        [self.popUpView removeFromSuperview];
   ///  Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAnimate
{
    self.popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.popUpView.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.popUpView.alpha = 1;
        self.popUpView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)removeAnimate
{
    [UIView animateWithDuration:.25 animations:^{
        self.popUpView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.popUpView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.popUpView removeFromSuperview];
            self.view.backgroundColor = Green;
            
        }
    }];
}

- (IBAction)changeUsername:(id)sender {
    [self showInView:self.view animated:YES];
}

- (IBAction)closePopup:(id)sender {
    [self removeAnimate];
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self.popUpView];
    self.popUpView.center = self.view.center;
    self.popUpView.layer.cornerRadius = 5;
    self.popUpView.layer.shadowOpacity = 0.8;
    self.popUpView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    if (animated) {
        [self showAnimate];
    }
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
