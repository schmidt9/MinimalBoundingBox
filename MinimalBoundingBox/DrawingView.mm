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
const int kPointsCount = 10;


@implementation DrawingView
{
    NSMutableArray<NSValue *> *_points;
    NSMutableArray<NSValue *> *_boundingBoxPoints;
    NSMutableArray<NSValue *> *_hullPoints;
    CGRect _pointsDrawingRect;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.layer.borderColor = [UIColor redColor].CGColor;
    self.layer.borderWidth = 1;
}

- (void)drawRect:(CGRect)rect
{
    // points drawing rect

    [UIColor.blueColor setStroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:_pointsDrawingRect];
    [path stroke];

    // draw points

    for (NSValue *value in _points) {
        [UIColor.magentaColor setFill];
        CGPoint point = value.CGPointValue;
        CGRect pointRect = CGRectMake(
            point.x - kPointSize / 2,
            point.y - kPointSize / 2,
            kPointSize,
            kPointSize);
        path = [UIBezierPath bezierPathWithOvalInRect:pointRect];
        [path fill];

        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:10]};
        NSString *str = [NSString stringWithFormat:@"(%.02f;%.02f)", point.x, point.y];
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:str attributes:attributes];
        [text drawAtPoint:point];
    }

    // draw bounding box

    [UIColor.greenColor setStroke];
    path = [UIBezierPath new];

    for (NSValue *value in _boundingBoxPoints) {
        CGPoint point = value.CGPointValue;

        if (value == _boundingBoxPoints.firstObject) {
            [path moveToPoint:point];
        } else {
            [path addLineToPoint:point];
        }
    }

    [path closePath];
    [path stroke];

    // draw hull path

    [UIColor.darkGrayColor setStroke];
    path = [UIBezierPath new];

    for (NSValue *value in _hullPoints) {
        CGPoint point = value.CGPointValue;

        if (value == _hullPoints.firstObject) {
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
    CGFloat margin = self.frame.size.width / 5;
    CGFloat drawingWidth = self.frame.size.width - margin * 2;
    CGFloat drawingHeight = self.frame.size.height - margin * 2;

    _pointsDrawingRect = CGRectMake(margin, margin, drawingWidth, drawingHeight);
    _points = [NSMutableArray new];

    for (int i = 0; i < kPointsCount; ++i) {
        CGFloat x = arc4random_uniform((uint32_t)drawingWidth) + margin;
        CGFloat y = arc4random_uniform((uint32_t)drawingHeight) + margin;
        CGPoint point = CGPointMake(x, y);
        [_points addObject:[NSValue valueWithCGPoint:point]];
    }

//    [_points addObject:[NSValue valueWithCGPoint:CGPointMake(80, 80)]];
//    [_points addObject:[NSValue valueWithCGPoint:CGPointMake(150, 90)]];
//    [_points addObject:[NSValue valueWithCGPoint:CGPointMake(120, 200)]];
}

- (void)calculateBoundingBox
{
    std::vector<MinimalBoundingBox::Point> cppPoints;

    for (NSValue *value in _points) {
        CGPoint point = value.CGPointValue;
        auto cppPoint = MinimalBoundingBox::Point(point.x, point.y);
        cppPoints.push_back(cppPoint);
    }

    auto cppBoundingBox = MinimalBoundingBox::calculate(cppPoints);
    auto cppBoundingBoxPoints = cppBoundingBox.boundingPoints;

    NSLog(@"%@", NSStringFromCGRect(self.frame));

    _boundingBoxPoints = [NSMutableArray new];

    for (auto &cppPoint : cppBoundingBoxPoints) {
        CGPoint point = CGPointMake(cppPoint.x, cppPoint.y);
        [_boundingBoxPoints addObject:[NSValue valueWithCGPoint:point]];
        NSLog(@"%@", NSStringFromCGPoint(point));
    }

    _hullPoints = [NSMutableArray new];
    auto cppHullPoints = cppBoundingBox.hullPoints;
    NSLog(@"HULL POINTS");

    for (auto &cppPoint : cppHullPoints) {
        CGPoint point = CGPointMake(cppPoint.x, cppPoint.y);
        [_hullPoints addObject:[NSValue valueWithCGPoint:point]];
        NSLog(@"%@", NSStringFromCGPoint(point));
    }
}

@end
