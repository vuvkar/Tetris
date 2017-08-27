//
//  PlayViewController.m
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "PlayViewController.h"


@interface PlayViewController () <GameEngineDelegate, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet BoardView *board;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *RightSwipeGestureRecognizer;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *LeftSwipeGestureRecognizer;
@property (strong, nonatomic) IBOutlet PopUpView *gameIsEndedPopUpView;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *comingFigureView;
@property (strong, nonatomic) IBOutlet PopUpView *PausePopUp;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *highestScoreLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *levelPassProgressBar;
@property AudioManager *player;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property BOOL allowAudio;
@property (weak, nonatomic) IBOutlet UILabel *finalScore;

@end

@implementation PlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.PausePopUp removeFromSuperview];
    [self.gameIsEndedPopUpView removeFromSuperview];
    [GameEngine sharedEngine].delegate = self;
    [[GameEngine sharedEngine] startGame];
    self.allowAudio = YES;
    self.player = [[AudioManager alloc] init];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.board
                                                          attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CellSize * BoardColumnsNumber]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.board
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute: NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:CellSize * BoardRowsNumber]];
        self.highestScoreLabel.text = [[NSNumber numberWithInt: [DataManager sharedManaer].highestScore] stringValue];
    [self.player playBackground];
}

#pragma mark IBActions

- (IBAction)exitWithSaving:(id)sender
{
    [[DataManager sharedManaer] saveCurrentGameWithScore:[self.scoreLabel.text intValue] andLevel:[self.levelLabel.text intValue]];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)exitWithoutSaving:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rotate:(id)sender
{
    [GameEngine sharedEngine].shouldRotate = YES;
}
- (IBAction)resumeAction:(id)sender
{
    [self.PausePopUp removeAnimate];
    [[GameEngine sharedEngine] startTact];
}
- (IBAction)restartAction:(id)sender
{
    [[GameEngine sharedEngine] clearBoard];
    [self.board clearBoard];
    [self.comingFigureView.subviews[0] removeFromSuperview];
    [self.PausePopUp removeAnimate];
    self.highestScoreLabel.text = [[NSNumber numberWithInt: [DataManager sharedManaer].highestScore] stringValue];
    self.levelPassProgressBar.progress = 0.0;
    self.scoreLabel.text = @"0";
    [[GameEngine sharedEngine] startGame];
}
- (IBAction)mainMenuAction:(id)sender
{
    [[GameEngine sharedEngine] endGame];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)audioControlAction:(id)sender
{
    if(self.allowAudio)
    {
        self.allowAudio = NO;
        [self.player stopBackground];
        [self.audioButton setTitle:@"Unmute" forState:UIControlStateNormal];
    }
    else
    {
        self.allowAudio = YES;
        [self.player playBackground];
        [self.audioButton setTitle:@"Mute" forState:UIControlStateNormal];
    }
    
}
- (IBAction)PauseButtonAction:(id)sender
{
    [[GameEngine sharedEngine].timer invalidate];
    [self.PausePopUp showInView:self.view animated:YES];
}
- (IBAction)takeReight:(id)sender
{
    [GameEngine sharedEngine].shouldTheFigureGoLeftOrRight = YES;
    [GameEngine sharedEngine].goingDirection = Right;
}
- (IBAction)takeLeft:(id)sender
{
    [GameEngine sharedEngine].shouldTheFigureGoLeftOrRight = YES;
    [GameEngine sharedEngine].goingDirection = Left;
}
- (IBAction)swipeDown:(id)sender
{
    [GameEngine sharedEngine].didSwipeDown = YES;
}


#pragma mark GameEngine delegate

-(void)gameIsEnded
{
    self.finalScore.text = self.scoreLabel.text;
    [self.gameIsEndedPopUpView showInView:self.view animated:YES];
}

-(void)levelIsChanged:(int)newLevel
{
    self.levelLabel.text = [[NSNumber numberWithInt:newLevel] stringValue];
    if(self.allowAudio)
    {
        [self.player playLevelUp];
    }
}

-(void)figureHasChangedPlace:(Directions)direction withCount:(int)count
{
    if(self.allowAudio)
        [self.player playMoveDown];
    [self.board  takeFigureToDirection:direction withCount:(int)count];
}

-(void)pauseGame
{
    [[DataManager sharedManaer] saveCurrentGameWithScore:[self.scoreLabel.text intValue] andLevel:[self.levelLabel.text intValue]];
    [self PauseButtonAction:nil];
}


-(void)newFigureIsGenerated:(Figure *)figure
{
    if([self.comingFigureView.subviews count] > 0)
        [self.comingFigureView.subviews[0] removeFromSuperview];
    FigureView *temp = [[FigureView alloc] initForGeneratedFigure:figure];
    [self.comingFigureView addSubview:temp];
    temp.center = CGPointMake(self.comingFigureView.frame.size.width / 2, self.comingFigureView.frame.size.height / 2 - 3) ;
}

- (void)newFigureIsCreated:(Figure*)figure withAnchor:(MatrixPoint *)anchor
{
    self.board.figureViewAnchorPoint = anchor;
    [self.board createFigureView:figure];
}

-(void)figureIsRotated:(Figure *)figure withAnchor:(MatrixPoint *)anchor
{
    self.board.figureViewAnchorPoint = anchor;
    [self.board rotate:figure];
}

- (void)rowsAreDeleted:(NSMutableArray <NSNumber *> *)rows
{
    if(self.allowAudio)
    {
        [self.player playDeleteRow];
    }
    [self.board deleteRowsAtIndexes:rows];
    self.levelPassProgressBar.progress = [GameEngine sharedEngine].deletedRows / RowsNeedToDeleteToChangeLevel;
    self.scoreLabel.text = [[NSNumber numberWithInt:[GameEngine sharedEngine].score] stringValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)stickFigure
{
    [self.board stickFigure];
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
