#import <UIKit/UIKit.h>

@interface UIFont (Rounded)

/**
 * Returns a rounded font of the specified size and weight.
 *
 * @param size The font size.
 * @param weight The font weight.
 * @return A UIFont object with rounded characteristics.
 */
+ (UIFont *)roundedFontOfSize:(CGFloat)size weight:(UIFontWeight)weight;

@end