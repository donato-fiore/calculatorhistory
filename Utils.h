#import "Headers.h"

@interface UIFont (Rounded)
+ (UIFont *)roundedFontOfSize:(CGFloat)size weight:(UIFontWeight)weight;
@end

extern bool inputUnitSelected;
extern NSInteger specialBehavior;
extern bool bypassDefault;

NSInteger indexOf(NSString *string, NSString *substring);
NSRange rangeOfNthOccurrence(NSString *string, NSString *substring, NSInteger occurrence);
NSString *superscript(NSString *string);
NSString *subscript(NSString *string);
NSString *relativeDateFormat(NSDate *date);
bool isLabelTruncated(UILabel *label);
NSAttributedString *formatExpression(NSString *equation);
NSString *parseExpression(NSString *expression);
