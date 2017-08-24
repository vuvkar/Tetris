//
//  PlayViewController.m
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "PlayViewController.h"


@interface PlayViewController () <GameEngineDelegate, FigureDelegate>
@property (weak, nonatomic) IBOutlet BoardView *board;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *RightSwipeGestureRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *LeftSwipeGestureRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *comingFigureView;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [GameEngine sharedEngine].delegate = self;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.board
                                                          attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CellSize * BoardColumnsSize]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.board
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute: NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:CellSize * BoardRowSize]];
}
- (IBAction)rotate:(id)sender {
    [GameEngine sharedEngine].shouldRotate = YES;
}

-(void)levelIsChanged:(int)newLevel
{
    self.levelLabel.text = [[NSNumber numberWithInt:newLevel] stringValue];
}

-(void)moveFigure:(Figure *)figure
{
    [self.board updateFigurePlace:figure];
}

-(void)rotateFigure:(Figure *)figure
{
    [self.board rotate:figure];
}

-(void)newFigureIsGenerated:(Figure *)figure
{
    if([self.comingFigureView.subviews count] > 0)
        [self.comingFigureView.subviews[0] removeFromSuperview];
    FigureView *temp = [[FigureView alloc] initForGeneratedFigure:figure];
    [self.comingFigureView addSubview:temp];
    temp.center = CGPointMake(self.comingFigureView.frame.size.width / 2, self.comingFigureView.frame.size.height / 2 - 3) ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)takeReight:(id)sender {
    [GameEngine sharedEngine].shouldTheFigureGoLeftOrRight = YES;
    [GameEngine sharedEngine].goingDirection = Right;
}
- (IBAction)takeLeft:(id)sender {
    [GameEngine sharedEngine].shouldTheFigureGoLeftOrRight = YES;
    [GameEngine sharedEngine].goingDirection = Left;
}
- (IBAction)swipeDown:(id)sender {
    [GameEngine sharedEngine].didSwipeDown = YES;
}

- (void)newFigureIsCreated:(Figure*)figure
{
    [self.board createFigure:figure];
    figure.delegate = self;
}

- (void)moveFigureDown:(Figure *)figure andHowManyRows:(int)rows
{
    //    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"chocolate_grows" ofType:@"wav"];
    //    SystemSoundID soundID;
    //    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundID);
    //    AudioServicesPlaySystemSound(soundID);
    [self.board moveFigureDown:figure andHowManyRows:rows];
}

- (void)rowsAreDeleted:(NSMutableArray <NSNumber *> *)rows
{
    [self.board deleteRowsAtIndexes:rows];
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
