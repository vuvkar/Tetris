//
//  PopUpView.m
//  Tetris
//
//  Created by Vahe Karamyan on 25.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "PopUpView.h"

@implementation PopUpView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showAnimate
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}
- (void)removeAnimate
{
    [UIView animateWithDuration:.25 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            self.backgroundColor = Green;
            
        }
    }];
}
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    self.center = aView.center;
    self.layer.cornerRadius = 5;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    if (animated) {
        [self showAnimate];
    }
}


@end
