//
//  DataManager.m
//  Tetris
//
//  Created by Vahe Karamyan on 24.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

static DataManager *sharedManager = nil;

+(instancetype)sharedManaer
{
    if(sharedManager == nil)
    {
        sharedManager = [[DataManager alloc] init];
         if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
             [sharedManager firstSetup];
        [sharedManager load];
    }
    return sharedManager;
}

-(void)changeUsername:(NSString *)username
{
    self.currentPlayerName = username;
    [self.allData setObject:username forKey:@"username"];
    [self saveAllData];
}

-(void)firstSetup
{
    NSArray *temp = [NSArray arrayWithObjects:@0, @0, @"", nil];
    self.allData = [[NSMutableDictionary alloc] initWithDictionary:@{@"Gold" : temp, @"Bronze" : temp, @"Silver" : temp, @"lastGame" : temp, @"username" : @""}];
    [self saveAllData];
}

-(void)load
{
    NSArray*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*basePath = paths.firstObject;
    NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:[basePath stringByAppendingString:@"gameData"]];
    self.allData = [[NSMutableDictionary alloc] initWithDictionary:dict];
    self.highestScore = [[self.allData objectForKey:@"Gold"][0] intValue];
    self.currentPlayerName = [self.allData objectForKey:@"username"];
}

-(void)saveCurrentGameWithScore:(int)score andLevel:(int)level
{
    self.currentGameScore = [NSNumber numberWithInt:score];
    self.currentGameLevel = [NSNumber numberWithInt:level];
    NSArray *lastGame = [[NSArray alloc] initWithObjects:self.currentGameScore, self.currentGameLevel, self.currentPlayerName, nil];
    [self.allData setObject:lastGame forKey:@"lastGame"];
    if([lastGame[0] intValue] > [[self.allData objectForKey:@"Gold"][0] intValue])
        [self.allData setObject:lastGame forKey:@"Gold"];
    else if([lastGame[0] intValue] > [[self.allData objectForKey:@"Silver"][0] intValue])
        [self.allData setObject:lastGame forKey:@"Silver"];
    else if([lastGame[0] intValue] > [[self.allData objectForKey:@"Bronze"][0] intValue])
        [self.allData setObject:lastGame forKey:@"Bronze"];
    self.highestScore = [[self.allData objectForKey:@"Gold"][0] intValue];
    [self saveAllData];
    
}

-(void)saveAllData
{
    NSArray*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*basePath = paths.firstObject;
    [self.allData writeToFile:[basePath stringByAppendingString:@"gameData"] atomically:YES];
}

@end
