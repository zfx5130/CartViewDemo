//
//  JLCardViewController.m
//  JLCardAnimation
//
//  Created by job on 16/9/1.
//  Copyright © 2016年 job. All rights reserved.
//

#import "JLCardViewController.h"
#import "JLDragCardView.h"
#import "CardHeader.h"

#define CARD_NUM 5
#define MIN_INFO_NUM 10
#define CARD_SCALE 0.95


@interface JLCardViewController()<JLDragCardDelegate>

@property (strong, nonatomic)  NSMutableArray *allCards;
@property (assign, nonatomic) CGPoint lastCardCenter;
@property (assign, nonatomic) CGAffineTransform lastCardTransform;
@property (strong, nonatomic) NSMutableArray *sourceObject;
@property (assign, nonatomic) NSInteger page;

@property (strong, nonatomic) UIButton *liekBtn;
@property (strong, nonatomic) UIButton *disLikeBtn;

@property (assign, nonatomic) BOOL flag;

@end


@implementation JLCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ZTDraggableView";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.allCards = [NSMutableArray array];
    self.sourceObject = [NSMutableArray array];
    self.page = 0;
    
    [self addControls];
    [self addCards];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestSourceData:YES];
    });
    
}


#pragma mark - 添加控件
-(void)addControls{
    
    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [reloadBtn setTitle:@"重置" forState:UIControlStateNormal];
    reloadBtn.frame = CGRectMake(self.view.center.x-25, self.view.frame.size.height-60, 50, 30);
    [reloadBtn addTarget:self action:@selector(refreshAllCards) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reloadBtn];
    
    
    self.disLikeBtn       = [UIButton buttonWithType:UIButtonTypeCustom];
    self.disLikeBtn.frame = CGRectMake(lengthFit(80), CARD_HEIGHT+lengthFit(100), 60, 60);
    [self.disLikeBtn setImage:[UIImage imageNamed:@"dislikeBtn"] forState:UIControlStateNormal];
    [self.disLikeBtn addTarget:self action:@selector(leftButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.disLikeBtn];
    
     self.liekBtn       = [UIButton buttonWithType:UIButtonTypeCustom];
     self.liekBtn.frame = CGRectMake(self.view.frame.size.width-lengthFit(80)-60 , CARD_HEIGHT+lengthFit(100), 60, 60);
     [self.liekBtn setImage:[UIImage imageNamed:@"likeBtn"] forState:UIControlStateNormal];
     [self.liekBtn addTarget:self action:@selector(rightButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
      [self.view addSubview:self.liekBtn];
    
    
}

#pragma mark - 刷新所有卡片
-(void)refreshAllCards{
    
    self.sourceObject=[@[] mutableCopy];
    self.page = 0;
    
    for (int i=0; i<_allCards.count ;i++) {
        
        JLDragCardView *card=self.allCards[i];
        
        CGPoint finishPoint = CGPointMake(-CARD_WIDTH, 2*PAN_DISTANCE+card.frame.origin.y);
        
        [UIView animateKeyframesWithDuration:0.5 delay:0.06*i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            
            card.center = finishPoint;
            card.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
            
        } completion:^(BOOL finished) {
            
            card.yesButton.transform=CGAffineTransformMakeScale(1, 1);
            card.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
            card.hidden=YES;
            card.center=CGPointMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH, self.view.center.y);
            
            if (i==_allCards.count-1) {
                [self requestSourceData:YES];
            }
        }];
    }
}

#pragma mark - 请求数据
-(void)requestSourceData:(BOOL)needLoad{
    
    /*
     在此添加网络数据请求代码
     */
    
    NSMutableArray *objectArray = [@[] mutableCopy];
    for (int i = 1; i<=10; i++) {
        [objectArray addObject:@{@"number":[NSString stringWithFormat:@"%ld",self.page*10+i],@"image":[NSString stringWithFormat:@"%d.jpeg",i]}];
    }
    
    [self.sourceObject addObjectsFromArray:objectArray];
    self.page++;
    
    //如果只是补充数据则不需要重新load卡片，而若是刷新卡片组则需要重新load
    if (needLoad) {
        [self loadAllCards];
    }
    
}

#pragma mark - 重新加载卡片
-(void)loadAllCards{
    
    for (int i=0; i<self.allCards.count; i++) {
        JLDragCardView *draggableView=self.allCards[i];
        
        if ([self.sourceObject firstObject]) {
            draggableView.infoDict=[self.sourceObject firstObject];
            [self.sourceObject removeObjectAtIndex:0];
            [draggableView layoutSubviews];
            draggableView.hidden=NO;
        }else{
            draggableView.hidden=YES;//如果没有数据则隐藏卡片
        }
    }
    
    for (int i=0; i<_allCards.count ;i++) {
        
        JLDragCardView *draggableView=self.allCards[i];
        
        CGPoint finishPoint = CGPointMake(self.view.center.x, CARD_HEIGHT/2 + 40);
        
        [UIView animateKeyframesWithDuration:0.5 delay:0.06*i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            
            draggableView.center = finishPoint;
            draggableView.transform = CGAffineTransformMakeRotation(0);
            
            if (i>0&&i<CARD_NUM-1) {
                JLDragCardView *preDraggableView=[_allCards objectAtIndex:i-1];
                draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
                CGRect frame=draggableView.frame;
                frame.origin.y=preDraggableView.frame.origin.y+(preDraggableView.frame.size.height-frame.size.height)+10*pow(0.7,i);
                draggableView.frame=frame;
                
            }else if (i==CARD_NUM-1) {
                JLDragCardView *preDraggableView=[_allCards objectAtIndex:i-1];
                draggableView.transform=preDraggableView.transform;
                draggableView.frame=preDraggableView.frame;
            }
        } completion:^(BOOL finished) {
            
        }];
        
        draggableView.originalCenter=draggableView.center;
        draggableView.originalTransform=draggableView.transform;
        
        if (i==CARD_NUM-1) {
            self.lastCardCenter=draggableView.center;
            self.lastCardTransform=draggableView.transform;
        }
    }
}

#pragma mark - 首次添加卡片
-(void)addCards{
    for (int i = 0; i<CARD_NUM; i++) {
        
        JLDragCardView *draggableView = [[JLDragCardView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH, self.view.center.y-CARD_HEIGHT/2, CARD_WIDTH, CARD_HEIGHT)];
        
        if (i>0&&i<CARD_NUM-1) {
            draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
        }else if(i==CARD_NUM-1){
            draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i-1), pow(CARD_SCALE, i-1));
        }
        draggableView.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
        draggableView.delegate = self;
        
        [_allCards addObject:draggableView];
        if (i==0) {
            draggableView.canPan=YES;
        }else{
            draggableView.canPan=NO;
        }
    }
    
    for (int i=(int)CARD_NUM-1; i>=0; i--){
        [self.view addSubview:_allCards[i]];
    }
}

#pragma mark - 滑动后续操作
-(void)swipCard:(JLDragCardView *)cardView Direction:(BOOL)isRight {
    
    if (isRight) {
        [self like:cardView.infoDict];
    }else{
        [self unlike:cardView.infoDict];
        
    }
    
    [_allCards removeObject:cardView];
    cardView.transform = self.lastCardTransform;
    cardView.center = self.lastCardCenter;
    cardView.canPan=NO;
    [self.view insertSubview:cardView belowSubview:[_allCards lastObject]];
    [_allCards addObject:cardView];
    
    if ([self.sourceObject firstObject]!=nil) {
        cardView.infoDict=[self.sourceObject firstObject];
        [self.sourceObject removeObjectAtIndex:0];
        [cardView layoutSubviews];
        if (self.sourceObject.count<MIN_INFO_NUM) {
            [self requestSourceData:NO];
        }
    }else{
        cardView.hidden=YES;//如果没有数据则隐藏卡片
    }
    
    for (int i = 0; i<CARD_NUM; i++) {
        JLDragCardView*draggableView=[_allCards objectAtIndex:i];
        draggableView.originalCenter=draggableView.center;
        draggableView.originalTransform=draggableView.transform;
        if (i==0) {
            draggableView.canPan=YES;
        }
    }
    //        NSLog(@"%d",_sourceObject.count);
}

#pragma mark - 滑动中更改其他卡片位置
-(void)moveCards:(CGFloat)distance{
    
    if (fabs(distance)<=PAN_DISTANCE) {
        for (int i = 1; i<CARD_NUM-1; i++) {
            JLDragCardView *draggableView=_allCards[i];
            JLDragCardView *preDraggableView=[_allCards objectAtIndex:i-1];
            
            draggableView.transform=CGAffineTransformScale(draggableView.originalTransform, 1+(1/CARD_SCALE-1)*fabs(distance/PAN_DISTANCE)*0.6, 1+(1/CARD_SCALE-1)*fabs(distance/PAN_DISTANCE)*0.6);//0.6为缩减因数，使放大速度始终小于卡片移动速度
            
            CGPoint center=draggableView.center;
            center.y=draggableView.originalCenter.y-(draggableView.originalCenter.y-preDraggableView.originalCenter.y)*fabs(distance/PAN_DISTANCE)*0.6;//此处的0.6同上
            draggableView.center=center;
        }
    }
    if (distance > 0) {
        self.liekBtn.transform=CGAffineTransformMakeScale(1+0.1*fabs(distance/PAN_DISTANCE), 1+0.1*fabs(distance/PAN_DISTANCE));
    } else {
        self.disLikeBtn.transform=CGAffineTransformMakeScale(1+0.1*fabs(distance/PAN_DISTANCE), 1+0.1*fabs(distance/PAN_DISTANCE));
    }
}

#pragma mark - 滑动终止后复原其他卡片
-(void)moveBackCards{
    for (int i = 1; i<CARD_NUM-1; i++) {
        JLDragCardView *draggableView=_allCards[i];
        [UIView animateWithDuration:RESET_ANIMATION_TIME
                         animations:^{
                             draggableView.transform=draggableView.originalTransform;
                             draggableView.center=draggableView.originalCenter;
                         }];
    }
}

#pragma mark - 滑动后调整其他卡片位置
-(void)adjustOtherCards{
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         for (int i = 1; i<CARD_NUM-1; i++) {
                             JLDragCardView *draggableView=_allCards[i];
                             JLDragCardView *preDraggableView=[_allCards objectAtIndex:i-1];
                             draggableView.transform=preDraggableView.originalTransform;
                             draggableView.center=preDraggableView.originalCenter;
                         }
                     }completion:^(BOOL complete){
                        self.disLikeBtn.transform = CGAffineTransformMakeScale(1, 1);
                        self.liekBtn.transform = CGAffineTransformMakeScale(1, 1);
                     }];
    
}

#pragma mark - 喜欢
-(void)like:(NSDictionary*)userInfo{
    
    /*
     在此添加“喜欢”的后续操作
     */
    
    NSLog(@"like:%@",userInfo[@"number"]);
}

#pragma mark - 不喜欢
-(void)unlike:(NSDictionary*)userInfo{
    
    /*
     在此添加“不喜欢”的后续操作
     */
    
    NSLog(@"unlike:%@",userInfo[@"number"]);
}



-(void)rightButtonClickAction {
    if (_flag == YES) {
        return;
    }
    _flag = YES;
    JLDragCardView *dragView=self.allCards[0];
    CGPoint finishPoint = CGPointMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH*2/3, 2*PAN_DISTANCE+dragView.frame.origin.y);
    [UIView animateWithDuration:CLICK_ANIMATION_TIME
                     animations:^{
                        self.liekBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         dragView.center = finishPoint;
                         dragView.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
                     } completion:^(BOOL finished) {
                         self.liekBtn.transform = CGAffineTransformMakeScale(1, 1);
                          [self swipCard:dragView Direction:YES];
                          _flag = NO;
                     }];
    [self adjustOtherCards];
}
-(void)leftButtonClickAction {
    if (_flag == YES) {
        return;
    }
    _flag = YES;
     JLDragCardView *dragView=self.allCards[0];
    CGPoint finishPoint = CGPointMake(-CARD_WIDTH*2/3, 2*PAN_DISTANCE + dragView.frame.origin.y);
    [UIView animateWithDuration:CLICK_ANIMATION_TIME
                     animations:^{
                         self.disLikeBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         dragView.center = finishPoint;
                         dragView.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
                     } completion:^(BOOL finished) {
                          self.disLikeBtn.transform = CGAffineTransformMakeScale(1, 1);
                         [self swipCard:dragView Direction:NO];
                         _flag = NO;
                     }];
    [self adjustOtherCards];
}

@end
