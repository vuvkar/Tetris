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

-(instancetype)sharedManaer
{
    if(sharedManager == nil)
    {
        sharedManager = [[DataManager alloc] init];
        [sharedManager load];
    }
    return sharedManager;
}

-(void)load
{
    NSArray*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*basePath = paths.firstObject;
    NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:[basePath stringByAppendingString:@"gameData"]];
    self.allData = [[NSMutableDictionary alloc] initWithDictionary:dict];
}

-(void)saveCurrentGame
{
    
}

@end
