//
//  JLDragCardView.h
//  JLCardAnimation
//
//  Created by job on 16/8/31.
//  Copyright © 2016年 job. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ROTATION_ANGLE M_PI/8
#define CLICK_ANIMATION_TIME 0.5
#define RESET_ANIMATION_TIME 0.3

@class JLDragCardView;
@protocol JLDragCardDelegate <NSObject>

-(void)swipCard:(JLDragCardView *)cardView Direction:(BOOL) isRight;

-(void)moveCards:(CGFloat)distance;

-(void)moveBackCards;

-(void)adjustOtherCards;


@end



@interface JLDragCardView : UIView

@property (weak,   nonatomic) id <JLDragCardDelegate> delegate;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (assign, nonatomic) CGAffineTransform originalTransform;
@property (assign, nonatomic) CGPoint originalPoint;
@property (assign, nonatomic) CGPoint originalCenter;
@property (assign, nonatomic) BOOL canPan;
@property (strong, nonatomic) NSDictionary *infoDict;
@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) UILabel *numLabel;
@property (strong, nonatomic) UIButton *noButton;
@property (strong, nonatomic) UIButton *yesButton;

-(void) leftButtonClickAction;

-(void) rightButtonClickAction;

@end
