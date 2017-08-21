//
//  CellView.m
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "CellView.h"

@implementation CellView

-(instancetype)init
{
    self = [super init];
    if(self)
    {
       // [self addSubview: [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell.png"]]];
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
