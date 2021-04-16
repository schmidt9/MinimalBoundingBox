//
// Created by Alexander Kormanovsky on 16.04.2021.
//

#ifndef MinimalBoundingBox_MinimalBoundingBox
#define MinimalBoundingBox_MinimalBoundingBox

#import <vector>

namespace minimal_bounding_box {

    /**
    * Port from
    * https://github.com/cansik/LongLiveTheSquare/blob/master/U4LongLiveTheSquare/Geometry/GeoAlgos.cs
    * https://github.com/cansik/LongLiveTheSquare/blob/8aab5069763c0e1d8c451195d8855cb713aee48b/U4LongLiveTheSquare/MinimalBoundingBox.cs
    */
    class MinimalBoundingBox {

    public:

        struct Point {
            double x = 0;
            double y = 0;

            Point(){}

            Point(double x, double y)
            {
                this->x = x;
                this->y = y;
            }

            inline Point operator - (const Point &other) const
            {
                return {this->x - other.x, this->y - other.y};
            }
        };

        struct Segment {

            Point a, b;

            Segment(const Point &a, const Point &b)
            {
                this->a = a;
                this->b = b;
            }

        };

        struct Rect {

            Point location;
            Point size;

            Rect(){}

            Rect(const Point &a, const Point &c)
            {
                location = a;
                size = c - a;
            }

            bool isEmpty()
            {
                return location.x == 0 && location.y == 0 && size.x == 0 && size.y == 0;
            }

            double
            getArea()
            {
                return size.x * size.y;
            }

            std::vector<Point> getPoints()
            {
                return {
                    {location.x, location.y},
                    {location.x + size.x, location.y},
                    {location.x + size.x, location.y + size.y},
                    {location.x, location.y + size.y}
                };
            }

        };

    public:

        static Rect calculate(const std::vector<Point> &points);

    private:

        static double cross(const Point &o, const Point &a, const Point &b);

        static bool isDoubleEqual(double v1, double v2);

        static std::vector<Point> monotoneChainConvexHull(const std::vector<Point> &points);

        static double angleToAxis(const Segment &s);

        static Point rotateToXAxis(const Point &p, double angle);

    };

}




#endif //MinimalBoundingBox_MinimalBoundingBox
