#import "UIFont+Rounded.h"

@implementation UIFont (Rounded)

+ (UIFont *)roundedFontOfSize:(CGFloat)size weight:(UIFontWeight)weight {
    UIFont *systemFont = [UIFont systemFontOfSize:size weight:weight];
    UIFontDescriptor *descriptor = [systemFont.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
    
    if (descriptor) {
        return [UIFont fontWithDescriptor:descriptor size:size];
    }
    
    return systemFont;
}

@end
