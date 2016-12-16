#import <UIKit/UIKit.h>
#import "NSString+FontAwesome.h"

typedef NS_ENUM(NSUInteger, UIButtonStyle) {
    UIButtonStyleDefault,
    UIButtonStylePrimary,
    UIButtonStyleSuccess,
    UIButtonStyleInfo,
    UIButtonStyleWarning,
    UIButtonStyleDanger
};

@interface UIButton (Assistant)

- (void)setStyle:(enum UIButtonStyle)aStyle;
- (void)addAwesomeIcon:(FAIcon)icon beforeTitle:(BOOL)before;

- (void)performZoomAnimationWithXScale:(CGFloat)xScale yScale:(CGFloat)yScale zoomInDuration:(NSTimeInterval)zoomInduration zoomOutDuration:(NSTimeInterval)zoomOutduration;

@end
