#import "UIImage+CalculatorHistory.h"

@implementation UIImage (CalculatorHistory)

+ (UIImage *)calc_systemImageWithName:(NSString *)name {
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium scale:UIImageSymbolScaleMedium];
    return [UIImage systemImageNamed:name withConfiguration:config];
}

@end