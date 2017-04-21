//
//  ViewController.m
//  //
//  Created by Mac on 5/19/16.
//
//

#import "ViewController.h"

@interface ViewController ()

-(UIView*) viewWithFrame:(CGRect)rect withColor: (UIColor*) color andSuperView: (UIView*) superView;
@property (weak, nonatomic) UIView* boardView;
@property (strong, nonatomic) NSMutableArray* blackRectArray;
@property (strong, nonatomic) NSMutableArray* whiteRectArray;
@property (strong, nonatomic) NSMutableArray* whiteChessArray;
@property (strong, nonatomic) NSMutableArray* redChessArray;
@property (weak, nonatomic) UIView* draggingView;
@property (assign, nonatomic) CGPoint touchOffset;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    CGFloat boardViewWidth = MIN(CGRectGetWidth(self.view.bounds),CGRectGetHeight(self.view.bounds));
    CGFloat widthOfCell=boardViewWidth/8;
    CGRect boardViewRect = CGRectMake(0,0,boardViewWidth,boardViewWidth);
    UIView* boardView = [self viewWithFrame: boardViewRect withColor: [UIColor whiteColor] andSuperView: self.view];
    boardView.center=self.view.center;
    self.boardView=boardView;
    NSMutableArray* blackRectArray = [[NSMutableArray alloc]init];
    NSMutableArray* whiteChessArray = [[NSMutableArray alloc]init];
    NSMutableArray* redChessArray = [[NSMutableArray alloc]init];
 
    
    for (int i=0; i<8; i++)
    {
        for (int j=0; j<8; j++)
        {
            CGRect rect = CGRectMake(j * widthOfCell, i* widthOfCell, widthOfCell, widthOfCell);
            if(((j % 2 == 1) && (i % 2 == 1)) ||  ((j % 2 == 0) && (i % 2 == 0)))
            {
                UIView* view =[self viewWithFrame: rect withColor: [UIColor blackColor] andSuperView: boardView];
                [blackRectArray addObject: view];
                
            }
        }
    }
    for (int i =0; i<8; i++)
    {
        UIView* view = [self createChess: blackRectArray rectAtIndex: i andColor: [UIColor redColor] ];
        [redChessArray addObject: view];
    }
    for (NSUInteger i =[blackRectArray count]-1; i>=[blackRectArray count] - 8; i--)
    {
        UIView* view = [self createChess: blackRectArray rectAtIndex: i andColor: [UIColor whiteColor] ];
        [whiteChessArray addObject: view];
    }
    
    self.blackRectArray=blackRectArray;
    self.whiteChessArray=whiteChessArray;
    self.redChessArray=redChessArray;
}




-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint pointOnMainView = [touch locationInView:self.view];
    UIView* touchView =[self.view hitTest:pointOnMainView withEvent:event];
   
    if((![touchView isEqual:self.view])&([self.whiteChessArray containsObject:touchView] | [self.redChessArray containsObject:touchView])){
     
        self.draggingView = touchView;
        [self.view bringSubviewToFront:self.draggingView];
        
        CGPoint touchPoint = [touch locationInView:self.draggingView];
        
        self.touchOffset = CGPointMake(CGRectGetMidX(self.draggingView.bounds) - touchPoint.x,
                                       CGRectGetMidY(self.draggingView.bounds) - touchPoint.y);
    }
        else
        {
            self.draggingView=nil;
        }
    
    [UIView transitionWithView:
     self.draggingView duration:0.1 options: UIViewAnimationOptionCurveLinear animations:^{
         self.draggingView.transform = CGAffineTransformMakeScale(1.2f,1.2f);
         self.draggingView.alpha=0.3f;} completion:nil];
    }



-(void) touchesMoved: (NSSet *) touches withEvent: (UIEvent*) event
{
    if(self.draggingView){
        
        UITouch* touch = [touches anyObject];
        CGPoint pointOnMainView = [touch locationInView:self.boardView];
        
        
        CGPoint correctedPoint = CGPointMake (pointOnMainView.x + self.touchOffset.x,
                                         pointOnMainView.y + self.touchOffset.y);
        
        self.draggingView.center = correctedPoint;
    }
}



-(void) touchesEnded: (NSSet *) touches withEvent: (UIEvent*) event
{
    [self onTouchesEnded];
}

-(void) onTouchesEnded{
    
    [UIView transitionWithView:
     self.draggingView duration:0.1 options: UIViewAnimationOptionCurveLinear animations:^{
         self.draggingView.transform = CGAffineTransformIdentity;
         self.draggingView.alpha=1.f;} completion:nil];
    
    
    CGPoint centerPoint= self.draggingView.center;
   // UIView* firstView = self.blackRectArray[1];
    //CGPoint closePoint = firstView.center;
    
    CGFloat minDistance =CGRectGetWidth(self.boardView.bounds)*CGRectGetWidth(self.boardView.bounds) + CGRectGetHeight(self.boardView.bounds)*CGRectGetHeight(self.boardView.bounds);
    [self calculateDistanceBetweenPoints: centerPoint and: self.view.center];
    CGPoint closePoint = self.draggingView.center;
    
    
    
    
    for (UIView* obj in self.blackRectArray){
        
        
        if([self blackRectIsFree: obj]){
        CGFloat distance = [self calculateDistanceBetweenPoints:centerPoint and: obj.center];
        if(distance < minDistance){
        minDistance = distance;
        closePoint = obj.center;
        }
     }
   }
    
    
    
    self.draggingView.center = closePoint;
    
 //   if(!self.whiteIndex)
 //   {self.whiteChessArray[self.whiteIndex]=self.draggingView;}
    
 //   if(!self.redIndex)
  //  {self.redChessArray[self.whiteIndex]=self.draggingView;}
    
    self.draggingView = nil;
 
}


-(UIView*) createChess:(NSArray*) array rectAtIndex: (NSUInteger) index andColor: (UIColor*) color
{
    UIView* view = [array objectAtIndex: index];
    CGRect chessRect = CGRectMake(0, 0, CGRectGetWidth(view.bounds)*0.6, CGRectGetWidth(view.bounds)*0.6 );
    UIView* chessView = [self viewWithFrame: chessRect withColor: color andSuperView: self.boardView];
    chessView.center=view.center;
    return chessView;
}

-(UIView*) viewWithFrame:(CGRect)rect withColor: (UIColor*) color andSuperView: (UIView*) superView
{
    UIView* view =[[UIView alloc]initWithFrame:rect];
    view.backgroundColor = color;
    [superView addSubview:view];
    superView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    return view;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) logTouches: (NSSet*) touches withMethod: (NSString*) methodName{
    NSMutableString* string = [NSMutableString stringWithString:methodName];
    
    for(UITouch* touch in touches){
        CGPoint point = [touch locationInView: self.view];
        [string appendFormat: @" %@", NSStringFromCGPoint(point)];
    }
    NSLog(@"touch:   %@",string);
}

- (float) calculateDistanceBetweenPoints:(CGPoint)point1 and: (CGPoint) point2{
    
    float dx = (point2.x-point1.x);
    float dy = (point2.y-point1.y);
    return sqrt(dx*dx + dy*dy);
}



- (BOOL) blackRectIsFree: (UIView*) rect {
    
         BOOL blackRectIsFree = YES;
    
    for (UIView* chess in self.redChessArray)
    {
        if(CGPointEqualToPoint (rect.center, chess.center))
        {
            blackRectIsFree = NO;
            return blackRectIsFree;
        }
     
    }
    for (UIView* chess in self.whiteChessArray)
    {
        if(CGPointEqualToPoint (rect.center, chess.center))
        {
            blackRectIsFree = NO;
            return blackRectIsFree;
        }
        
    }

    blackRectIsFree = YES;
    return blackRectIsFree;
 }

/* NSMutableArray* deltas =[[NSMutableArray alloc]init];
 
 for (UIView* rect in self.blackRectArray)
 {
 CGFloat dx = CGRectGetMidX(rect.bounds)-self.draggingView.center.x;
 CGFloat dy = CGRectGetMidY(rect.bounds)-self.draggingView.center.y;
 if(dx<dy)
 [deltas addObject:[NSNumber numberWithFloat:dx]];
 else
 [deltas addObject:[NSNumber numberWithFloat:dy]];
 }
 
 CGFloat deltaMin=[[deltas objectAtIndex:0] floatValue];
 for (int i = 0; i<[deltas count]; i++)
 {
 CGFloat deltaCurrent=[[deltas objectAtIndex:i] floatValue];
 
 if (deltaCurrent<deltaMin)
 {
 deltaMin=deltaCurrent;
 self.index = i;
 }
 }
 
 
 UIView* closeView = [self.blackRectArray objectAtIndex: self.index];
 
 CGPoint landing = CGPointMake (CGRectGetMidX(closeView.bounds),
 CGRectGetMidY(closeView.bounds))/
 
 self.draggingView.center = self.view.center;
 
 //self.draggingView = nil;*/

@end


/*
 Вот такой вот урок по тачам. Решил жесты и тачи в один урок не объединять, а относительно простой функционал тачей решил дополнить практическим примером :)
 
 Уровень супермен (остальных уровней не будет)
 
 1. Создайте шахматное поле (8х8), используйте черные сабвьюхи
 2. Добавьте балые и красные шашки на черные клетки (используйте начальное расположение в шашках)
 3. Реализуйте механизм драг'н'дроп подобно тому, что я сделал в примере, но с условиями:
 4. Шашки должны ставать в центр черных клеток.
 5. Даже если я отпустил шашку над центром белой клетки - она должна переместиться в центр ближайшей к отпусканию черной клетки.
 6. Шашки не могут становиться друг на друга
 7. Шашки не могут быть поставлены за пределы поля.
 
 Вот такое вот веселое практическое задание :)
 

 
 */
