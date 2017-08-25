//
//  PopUpView.h
//  Tetris
//
//  Created by Vahe Karamyan on 25.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definitions.h"

@interface PopUpView : UIView

- (void)showAnimate;
- (void)removeAnimate;
- (void)showInView:(UIView *)aView animated:(BOOL)animated;

@end
