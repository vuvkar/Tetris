//
//  PlayViewController.m
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "PlayViewController.h"


@interface PlayViewController () <GameEngineDelegate, FigureDelegate, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet BoardView *board;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *RightSwipeGestureRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *LeftSwipeGestureRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *comingFigureView;
@property (strong, nonatomic) IBOutlet PopUpView *PausePopUp;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *highestScoreLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *levelPassProgressBar;
@property (nonatomic, strong) AVAudioPlayer *backgroundPlayer;
@property (nonatomic, strong) AVAudioPlayer *effectsPlayer;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property BOOL allowAudio;

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.PausePopUp removeFromSuperview];
    [GameEngine sharedEngine].delegate = self;
    self.allowAudio = YES;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.board
                                                          attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CellSize * BoardColumnsSize]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.board
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute: NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:CellSize * BoardRowSize]];
    NSString *background = [[NSBundle mainBundle] pathForResource:@"backgroundMusic" ofType:@"wav"];
    NSError *soundError = nil;
    self.backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:background]
                                                                   error:&soundError];
    [self.backgroundPlayer setDelegate:self];
    self.backgroundPlayer.numberOfLoops = -1;
    [self.backgroundPlayer play];
    
}


- (IBAction)rotate:(id)sender {
    [GameEngine sharedEngine].shouldRotate = YES;
}


- (IBAction)resumeAction:(id)sender {
    [self.PausePopUp removeAnimate];
    [[GameEngine sharedEngine] startTact];
}

- (IBAction)restartAction:(id)sender {
    [[GameEngine sharedEngine] endGame];
    for (FigureView *subview in [self.board subviews]) {
        if([subview isMemberOfClass:[FigureView class]])
            [subview removeFromSuperview];
    }
    [self.comingFigureView.subviews[0] removeFromSuperview];
    [GameEngine sharedEngine].delegate = self;
    [self.PausePopUp removeAnimate];
#warning  addHighestScore
    self.levelPassProgressBar.progress = 0.0;
    self.scoreLabel.text = @"0";
}

- (IBAction)mainMenuAction:(id)sender {
    [[GameEngine sharedEngine] endGame];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)audioControlAction:(id)sender {
    if(self.allowAudio)
    {
        self.allowAudio = NO;
        [self.backgroundPlayer stop];
        self.audioButton.titleLabel.text = @"Unmute";
    }
    else
    {
        self.allowAudio = YES;
        [self.backgroundPlayer play];
        self.audioButton.titleLabel.text = @"Mute";
    }
    
}

-(void)levelIsChanged:(int)newLevel
{
    self.levelLabel.text = [[NSNumber numberWithInt:newLevel] stringValue];
    if(self.allowAudio)
    {
    NSString *effect = [[NSBundle mainBundle] pathForResource:@"levelup" ofType:@"wav"];
    NSError *soundError = nil;
    self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:effect]
                                                                error:&soundError];
    [self.effectsPlayer setDelegate:self];
    [self.effectsPlayer play];
    }
}

-(void)moveFigure:(Figure *)figure
{
    [self.board updateFigurePlace:figure];
}

- (IBAction)PauseButtonAction:(id)sender {
    [[GameEngine sharedEngine].timer invalidate];
    [self.PausePopUp showInView:self.view animated:YES];
}

-(void)pauseGame
{
    [self PauseButtonAction:nil];
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
    if(self.allowAudio)
    {
    NSString *effect = [[NSBundle mainBundle] pathForResource:@"move" ofType:@"wav"];
    NSError *soundError = nil;
    self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:effect]
                                                                   error:&soundError];
    [self.effectsPlayer setDelegate:self];
    [self.effectsPlayer play];
    }
    [self.board moveFigureDown:figure andHowManyRows:rows];
}

- (void)rowsAreDeleted:(NSMutableArray <NSNumber *> *)rows
{
    if(self.allowAudio)
    {
    NSString *effect = [[NSBundle mainBundle] pathForResource:@"rowClear" ofType:@"wav"];
    self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:effect]
                                                                error:nil];
    [self.effectsPlayer setDelegate:self];
    [self.effectsPlayer play];
    }
    [self.board deleteRowsAtIndexes:rows];
    self.levelPassProgressBar.progress = [GameEngine sharedEngine].deletedRows / RowsNeedToDeleteToChangeLevel;
    self.scoreLabel.text = [[NSNumber numberWithInt:[GameEngine sharedEngine].score] stringValue];
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
