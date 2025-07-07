#import <UIKit/UIKit.h>

@interface UIImage (CalculatorHistory)

/**
 * Returns a system image with the specified name and applies a configuration to it.
 * If the image is not found, it returns nil.
 *
 * @param name The name of the system image.
 * @return The system image.
 */
+ (UIImage *)calc_systemImageWithName:(NSString *)name;

@end