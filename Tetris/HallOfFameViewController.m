//
//  HallOfFameViewController.m
//  Tetris
//
//  Created by Vahe Karamyan on 25.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "HallOfFameViewController.h"

@interface HallOfFameViewController ()
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *goldAttributes;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *silverAttributes;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *bronzeAttributes;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lastGameAttributes;


@end

@implementation HallOfFameViewController
- (IBAction)goBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *gold = [[DataManager sharedManaer].allData objectForKey:@"Gold"];
    NSArray *silver = [[DataManager sharedManaer].allData objectForKey:@"Silver"];
    NSArray *bronze = [[DataManager sharedManaer].allData objectForKey:@"Bronze"];
    NSArray *last = [[DataManager sharedManaer].allData objectForKey:@"lastGame"];
    for(int i = 0; i < 2; i++){
        ((UILabel *)self.goldAttributes[2 - i]).text = [gold[i] stringValue];
        ((UILabel *)self.silverAttributes[2 - i]).text = [silver[i] stringValue];
        ((UILabel *)self.bronzeAttributes[2 - i]).text = [bronze[i] stringValue];
        ((UILabel *)self.lastGameAttributes[2 - i]).text = [last[i] stringValue];
    }
    ((UILabel *)self.goldAttributes[0]).text = gold[2];
     ((UILabel *)self.silverAttributes[0]).text = silver[2];
     ((UILabel *)self.bronzeAttributes[0]).text = bronze[2];
     ((UILabel *)self.lastGameAttributes[0]).text = last[2];
    // Do any additional setup after loading the view.
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
