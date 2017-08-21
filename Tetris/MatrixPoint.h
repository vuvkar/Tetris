//
//  MatrixPoint.h
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MatrixPoint : NSObject

@property int row;
@property int column;

+(instancetype) initWithRow:(int)row andColumn:(int)column;
-(void) moveDown;
-(void) moveLeft;
-(void) moveRight;
-(void) moveUp;

@end
