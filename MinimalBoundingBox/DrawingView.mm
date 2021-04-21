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
const CGFloat kCenterSize = 5.0;
const int kPointsCount = 10;
const CGFloat kAlignmentTolerance = 5.0;


double
normalizeDegrees(double degrees, double maxDegrees)
{
    degrees = fmod(degrees, maxDegrees);

    if (degrees >= maxDegrees) {
        degrees -= maxDegrees;
    } else if (degrees < 0) {
        degrees += maxDegrees;
    }

    return abs(fmod(degrees, maxDegrees)); // avoid -0 and 360
}

@implementation DrawingView
{
    NSMutableArray<NSValue *> *_points;
    NSMutableArray<NSValue *> *_boundingBoxPoints;
    NSMutableArray<NSValue *> *_hullPoints;
    double _boundingBoxWidth;
    double _boundingBoxHeight;
    double _widthAngle;
    double _heightAngle;
    bool _isAligned;
    CGRect _pointsDrawingRect;
    CGPoint _boundingBoxCenter;
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

        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:8]};
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

    if (_boundingBoxPoints) {
        // avoid warning on closing empty path
        [path closePath];
    }

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

    // draw center

    [UIColor.redColor setFill];
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(_boundingBoxCenter.x - kCenterSize / 2, _boundingBoxCenter.y - kCenterSize / 2, kCenterSize, kCenterSize)];
    [path fill];

    // draw angle string

    NSString *angleString = [NSString stringWithFormat:
        @"Bounding box:\nwidth %f height %f\nwidth angle to X axis %f deg\nheight angle to X axis %f deg\nis aligned (using tolerance %f deg) %@",
        _boundingBoxWidth,
        _boundingBoxHeight,
        _widthAngle * (180 / M_PI),
        _heightAngle * (180 / M_PI),
        kAlignmentTolerance,
        _isAligned ? @"YES" : @"NO"];
    NSAttributedString *angleAttributedString = [[NSAttributedString alloc] initWithString:angleString attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:8]}];
    [angleAttributedString drawAtPoint:CGPointMake(4, 4)];

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
}

- (void)calculateBoundingBox
{
    std::vector<MinimalBoundingBox::Point> cppPoints;

    for (NSValue *value in _points) {
        CGPoint point = value.CGPointValue;
        auto cppPoint = MinimalBoundingBox::Point(point.x, point.y);
        cppPoints.push_back(cppPoint);
    }

    auto cppBoundingBox = MinimalBoundingBox::calculate(cppPoints, kAlignmentTolerance);
    auto cppBoundingBoxPoints = cppBoundingBox.boundingPoints;

    NSLog(@"BOUNDING BOX POINTS");

    _boundingBoxPoints = [NSMutableArray new];

    for (auto &cppPoint : cppBoundingBoxPoints) {
        CGPoint point = CGPointMake(cppPoint.x, cppPoint.y);
        [_boundingBoxPoints addObject:[NSValue valueWithCGPoint:point]];
        NSLog(@"%@", NSStringFromCGPoint(point));
    }

    NSLog(@"HULL POINTS");

    _hullPoints = [NSMutableArray new];
    auto cppHullPoints = cppBoundingBox.hullPoints;

    for (auto &cppPoint : cppHullPoints) {
        CGPoint point = CGPointMake(cppPoint.x, cppPoint.y);
        [_hullPoints addObject:[NSValue valueWithCGPoint:point]];
        NSLog(@"%@", NSStringFromCGPoint(point));
    }

    _widthAngle = cppBoundingBox.widthAngle;
    _heightAngle = cppBoundingBox.heightAngle;
    _boundingBoxWidth = cppBoundingBox.width;
    _boundingBoxHeight = cppBoundingBox.height;
    _isAligned = cppBoundingBox.isAligned;

    _boundingBoxCenter = CGPointMake(cppBoundingBox.center.x, cppBoundingBox.center.y);
}

@end
