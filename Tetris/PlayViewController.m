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

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [GameEngine sharedEngine].delegate = self;
}
- (IBAction)rotate:(id)sender {
    [GameEngine sharedEngine].shouldRotate = YES;
}

-(void)moveFigure:(Figure *)figure
{
    [self.board updateFigurePlace:figure];
}

-(void)rotateFigure:(Figure *)figure
{
    [self.board rotate:figure];
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

- (void)newFigureIsCreated:(Figure*)figure
{
    [self.board createFigure:figure];
    figure.delegate = self;
}

- (void)moveFigureDown:(Figure *)figure
{
    [self.board moveFigureDown:figure];
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
