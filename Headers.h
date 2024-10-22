#import <UIKit/UIKit.h>

#ifdef DEBUG
#define NSLog(...)                      NSLog(__VA_ARGS__);
#else
#define NSLog(...) {}
#endif

typedef NS_ENUM(NSInteger, SpecialBehaviors) {
    kInvalid,
    kPercent,
    kRadical,
    kInverse,
    kScientificNotation,
    kLogarithm,
};

@interface DisplayView : UIView
@property (nonatomic, strong) UINavigationBar *navbar;
@property (nonatomic, strong) UINavigationItem *navItem;
- (UILabel *)accessibilityValueLabel;
@end

@interface CalculatorKeypadButton : UIView
- (NSInteger)accessibilityCalculatorButtonID;
@end

@interface UITableViewCell (CalculatorHistory)
@property (nonatomic, strong) UILabel *resultLabel;
@end
