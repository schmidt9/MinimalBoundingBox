//
// Created by Alexander Kormanovsky on 16.04.2021.
//

#include <float.h>
#include "MinimalBoundingBox.hpp"

// MARK: Utils

/**
 * Cross the specified o, a and b.
 * Zero if collinear
 * Positive if counter-clockwise
 * Negative if clockwise
 * @param o 0
 * @param a The alpha component
 * @param b The blue component
 */
double cross(
    const MinimalBoundingBox::Point &o,
    const MinimalBoundingBox::Point &a,
    const MinimalBoundingBox::Point &b)
{
    return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
}

bool isDoubleEqual(double v1, double v2)
{
    return std::abs(v1 - v2) < DBL_EPSILON;
}

// MARK: Bounding Box

std::vector<MinimalBoundingBox::Point>
monotoneChainConvexHull(const std::vector<MinimalBoundingBox::Point> &points)
{
    using Point = MinimalBoundingBox::Point;

    // break if only one point as input
    if (points.size() <= 1) {
        return points;
    }

    auto sortedPoints = points;

    // sort vectors
    std::sort(sortedPoints.begin(), sortedPoints.end(), [](const Point &p1, const Point &p2) -> bool {
        // https://github.com/cansik/LongLiveTheSquare/blob/master/U4LongLiveTheSquare/Geometry/Vector2d.cs
        if (isDoubleEqual(p1.x, p2.x)) {
            if (isDoubleEqual(p1.y, p2.y)) {
                return false;
            }

            return (p1.y < p2.y);
        }

        return (p1.x < p2.x);
    });

    auto hullPoints = std::vector<Point>(sortedPoints.size() * 2);

    auto pointLength = sortedPoints.size();
    auto counter = 0UL;

    // iterate for lowerHull

    for (int i = 0; i < pointLength; ++i) {
        while (counter >= 2 && cross(hullPoints [counter - 2], hullPoints [counter - 1], sortedPoints [i]) <= 0) {
            counter--;
        }

        hullPoints[counter++] = sortedPoints[i];
    }

    // iterate for upperHull

    for (unsigned long i = pointLength - 2, j = counter + 1; i >= 0; i--) {
        while (counter >= j && cross(hullPoints[counter - 2], hullPoints[counter - 1], sortedPoints[i]) <= 0) {
            counter--;
        }

        hullPoints[counter++] = sortedPoints[i];
    }

    // remove duplicate start points

    hullPoints.erase(hullPoints.end() - 1);

    return hullPoints;
}