//
//  DrawingView.h
//  MinimalBoundingBox
//
//  Created by Alexander Kormanovsky on 16.04.2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawingView : UIView

- (void)calculateMinimalBoundingBox;
@end

NS_ASSUME_NONNULL_END
