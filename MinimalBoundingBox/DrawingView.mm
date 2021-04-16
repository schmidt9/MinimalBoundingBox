//
//  DrawingView.m
//  MinimalBoundingBox
//
//  Created by Alexander Kormanovsky on 16.04.2021.
//

#import "DrawingView.h"

const CGFloat kPointSize = 10.0;

@implementation DrawingView
{
    NSMutableArray<NSValue *> *_points;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // draw points

    [UIColor.magentaColor setFill];

    for (NSValue *value in _points) {
        CGPoint point = value.CGPointValue;
        CGRect pointRect = CGRectMake(
            point.x - kPointSize / 2,
            point.y - kPointSize / 2,
            kPointSize,
            kPointSize);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:pointRect];
        [path fill];
    }
}

- (void)calculateMinimalBoundingBox
{
    [self generateRandomPoints];
    [self setNeedsDisplay];
}

- (void)generateRandomPoints
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    _points = [NSMutableArray new];

    for (int i = 0; i < 10; ++i) {
        CGFloat x = arc4random_uniform((uint32_t)width);
        CGFloat y = arc4random_uniform((uint32_t)height);
        CGPoint point = CGPointMake(x, y);
        [_points addObject:[NSValue valueWithCGPoint:point]];
    }
}

@end
