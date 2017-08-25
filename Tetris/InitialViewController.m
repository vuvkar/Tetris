//
//  InitialViewController.m
//  Tetris
//
//  Created by Vahe Karamyan on 23.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "InitialViewController.h"

@interface InitialViewController ()

@property (strong, nonatomic) IBOutlet PopUpView *popUpView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *enterUsernameTextField;

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.popUpView showInView:self.view animated:YES];
    }
    else{
        [self.popUpView removeFromSuperview];
        self.usernameLabel.text = [DataManager sharedManaer].currentPlayerName;
    }
   ///  Do any additional setup after loading the view.
}
- (IBAction)saveUsername:(id)sender {
    [[DataManager sharedManaer] changeUsername:self.enterUsernameTextField.text];
    self.usernameLabel.text = self.enterUsernameTextField.text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)changeUsername:(id)sender {
    [self.popUpView showInView:self.view animated:YES];
}

- (IBAction)closePopup:(id)sender {
    [self.popUpView removeAnimate];
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
