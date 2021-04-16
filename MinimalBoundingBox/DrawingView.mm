//
//  DrawingView.m
//  MinimalBoundingBox
//
//  Created by Alexander Kormanovsky on 16.04.2021.
//

#import "DrawingView.h"
#import "MinimalBoundingBox.hpp"

using namespace minimal_bounding_box;

const CGFloat kPointSize = 10.0;


@implementation DrawingView
{
    NSMutableArray<NSValue *> *_points;
    NSMutableArray<NSValue *> *_boundingBoxPoints;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 1;
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

    [UIColor.greenColor setFill];
    UIBezierPath *path = [UIBezierPath new];

    for (NSValue *value in _boundingBoxPoints) {
        CGPoint point = value.CGPointValue;

        if (value == _boundingBoxPoints.firstObject) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }

    [path stroke];
}

- (void)calculateMinimalBoundingBox
{
    [self generateRandomPoints];
    [self calculateBoundingBox];
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

- (void)calculateBoundingBox
{
    std::vector<MinimalBoundingBox::Point> cppPoints;

    for (NSValue *value in _points) {
        CGPoint point = value.CGPointValue;
        auto cppPoint = MinimalBoundingBox::Point(point.x, point.y);
        cppPoints.push_back(cppPoint);
    }

    auto cppBoundingBoxPoints = MinimalBoundingBox::calculate(cppPoints).getPoints();

    for (auto &cppPoint : cppBoundingBoxPoints) {
        CGPoint point = CGPointMake(cppPoint.x, cppPoint.y);
        [_boundingBoxPoints addObject:[NSValue valueWithCGPoint:point]];
    }
}

@end
