//
// Created by Alexander Kormanovsky on 16.04.2021.
//

#include <float.h>
#include "MinimalBoundingBox.hpp"

namespace minimal_bounding_box {

    /**
     * Calculates the minimum bounding box
     */
    MinimalBoundingBox::BoundingBox
    MinimalBoundingBox::calculate(const std::vector<Point> &points)
    {
        // calculate the convex hull

        auto hullPoints = monotoneChainConvexHull(points);

        // check if no bounding box available

        if (hullPoints.size() <= 1) {
            return {};
        }

        Rect minBox;
        double minAngle = 0;

        for (int i = 0; i < hullPoints.size(); ++i) {
            auto nextIndex = i + 1;

            auto current = hullPoints[i];
            auto next = hullPoints[nextIndex % hullPoints.size()];

            auto segment = Segment(current, next);

            // min / max points

            auto top = DBL_MAX * -1;
            auto bottom = DBL_MAX;
            auto left = DBL_MAX;
            auto right = DBL_MAX * -1;

            // get angle of segment to x axis

            auto angle = angleToXAxis(segment);
            printf("POINT (%f;%f) DEG %f\n", current.x, current.y, angle * (180 / M_PI));

            // rotate every point and get min and max values for each direction

            for (auto &p : hullPoints) {
                auto rotatedPoint = rotateToXAxis(p, angle);

                top = std::max(top, rotatedPoint.y);
                bottom = std::min(bottom, rotatedPoint.y);

                left = std::min(left, rotatedPoint.x);
                right = std::max(right, rotatedPoint.x);
            }

            // create axis aligned bounding box

            auto box = Rect({left, bottom}, {right, top});

            if (minBox.isEmpty() || minBox.getArea() > box.getArea()) {
                minBox = box;
                minAngle = angle;
            }
        }

        // get bounding box dimensions using axis aligned box,
        // larger side is considered as height

        auto minBoxPoints = minBox.getPoints();

        auto v1 = minBoxPoints[0] - minBoxPoints[1];
        auto v2 = minBoxPoints[1] - minBoxPoints[2];
        printf("V1 (%f,%f) V2 (%f,%f)\n", v1.x, v1.y, v2.x, v2.y);

        auto width = std::min(abs(v1.x), abs(v2.y));
        auto height = std::max(abs(v1.x), abs(v2.y));

        // rotate axis aligned box back

        for (auto &point : minBoxPoints) {
            point = rotateToXAxis(point, -minAngle);
        }


        auto heightPoint1 = (abs(v1.x) > abs(v2.y))
                            ? minBoxPoints[0]
                            : minBoxPoints[1];
        auto heightPoint2 = (abs(v1.x) > abs(v2.y))
                            ? minBoxPoints[1]
                            : minBoxPoints[2];

        auto a1 = angleToXAxis(Segment(minBoxPoints[0], minBoxPoints[1]));
        auto a2 = angleToXAxis(Segment(minBoxPoints[1], minBoxPoints[2]));
        auto heightAngle = angleToXAxis(Segment(heightPoint1, heightPoint2));
        auto widthAngle = (heightAngle > 0) ? heightAngle - M_PI_2 : heightAngle + M_PI_2;
        printf("A1 %f A2 %f HEIGHT A %f WIDTH A %f\n", a1 * (180 /M_PI), a2 * (180 /M_PI), heightAngle * (180 /M_PI), widthAngle * (180 /M_PI));

        return {minBoxPoints, hullPoints, width, height, widthAngle, heightAngle};
    }

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
    double
    MinimalBoundingBox::cross(const Point &o, const Point &a, const Point &b)
    {
        return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
    }

    bool
    MinimalBoundingBox::isDoubleEqual(double v1, double v2)
    {
        return std::abs(v1 - v2) < DBL_EPSILON;
    }

    std::vector<MinimalBoundingBox::Point>
    MinimalBoundingBox::monotoneChainConvexHull(const std::vector<MinimalBoundingBox::Point> &points)
    {
        // break if only one point as input
        if (points.size() <= 1) {
            return points;
        }

        auto sortedPoints = points;

        // sort vectors
        std::sort(sortedPoints.begin(), sortedPoints.end(), [&](const Point &p1, const Point &p2) -> bool {
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
        auto counter = 0;

        // iterate for lowerHull

        for (int i = 0; i < pointLength; ++i) {
            while (counter >= 2 && cross(hullPoints[counter - 2], hullPoints[counter - 1], sortedPoints[i]) <= 0) {
                counter--;
            }

            hullPoints[counter++] = sortedPoints[i];
        }

        // iterate for upperHull

        for (int i = (int) pointLength - 2, j = counter + 1; i >= 0; i--) {
            while (counter >= j && cross(hullPoints[counter - 2], hullPoints[counter - 1], sortedPoints[i]) <= 0) {
                counter--;
            }

            hullPoints[counter++] = sortedPoints[i];
        }

        // remove duplicate start points

        hullPoints.erase(hullPoints.begin() + counter, hullPoints.end());

        return hullPoints;
    }

    double
    MinimalBoundingBox::angleToXAxis(const Segment &s)
    {
        auto delta = s.a - s.b;
        return -atan(delta.y / delta.x);
    }

    MinimalBoundingBox::Point
    MinimalBoundingBox::rotateToXAxis(const Point &p, double angle)
    {
        auto newX = p.x * cos(angle) - p.y * sin(angle);
        auto newY = p.x * sin(angle) + p.y * cos(angle);
        return {newX, newY};
    }

}

