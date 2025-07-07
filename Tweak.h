#import <UIKit/UIKit.h>

#ifdef DEBUG
#define NSLog(...)                      NSLog(__VA_ARGS__);
#else
#define NSLog(...) {}
#endif

typedef NS_ENUM(NSInteger, SpecialBehavior) {
    SpecialBehavior_none = -1,
    SpecialBehavior_percent,
    SpecialBehavior_radical,
    SpecialBehavior_reciprocal,
    SpecialBehavior_scientificNotation,
    SpecialBehavior_logarithm,
};

typedef NS_ENUM(NSInteger, CalculatorButtonID) {
    CalculatorButton_none = 0,
    CalculatorButton_clear,
    unknown,
    CalculatorButton_negate,
    CalculatorButton_percent,
    CalculatorButton_divide,
    CalculatorButton_multiply,
    CalculatorButton_subtract,
    CalculatorButton_add, // 8
    CalculatorButton_equals,
    CalculatorButton_decimal,
    CalculatorButton_digit0,
    CalculatorButton_digit1,
    CalculatorButton_digit2,
    CalculatorButton_digit3,
    CalculatorButton_digit4,
    CalculatorButton_digit5, // 16
    CalculatorButton_digit6,
    CalculatorButton_digit7,
    CalculatorButton_digit8,
    CalculatorButton_digit9,
    CalculatorButton_openParenthesis,
    CalculatorButton_closeParenthesis,
    CalculatorButton_memoryClear,
    CalculatorButton_memoryAdd, // 24
    CalculatorButton_memorySubtract,
    CalculatorButton_memoryRecall,
    CalculatorButton_shift, // 2nd key
    CalculatorButton_square,
    CalculatorButton_cube,
    CalculatorButton_power,
    CalculatorButton_exponential,
    CalculatorButton_exponentialBase10, // 32
    CalculatorButton_reciprocal,
    CalculatorButton_squareRoot,
    CalculatorButton_cubeRoot,
    CalculatorButton_root,
    CalculatorButton_logarithmNatural,
    CalculatorButton_logarithmBase10,
    CalculatorButton_factorial,
    CalculatorButton_sine, // 40
    CalculatorButton_cosine,
    CalculatorButton_tangent,
    CalculatorButton_eulerNumber,
    CalculatorButton_timesPowerOfTen,
    CalculatorButton_radians,
    CalculatorButton_hyperbolicSine,
    CalculatorButton_hyperbolicCosine,
    CalculatorButton_hyperbolicTangent, // 48
    CalculatorButton_pi,
    CalculatorButton_random,
    CalculatorButton_allClear,
    unknown2, // 52
    CalculatorButton_degrees,
    CalculatorButton_exponentialBaseY,
    CalculatorButton_exponentialBase2, // 55
    CalculatorButton_logarithm,
    CalculatorButton_logarithmBase2,
    CalculatorButton_inverseSine,
    CalculatorButton_inverseCosine,
    CalculatorButton_inverseTangent,
    CalculatorButton_inverseHyperbolicSine,
    CalculatorButton_inverseHyperbolicCosine,
    CalculatorButton_inverseHyperbolicTangent,
};

@interface DisplayView : UIView
- (UILabel *)accessibilityValueLabel;
@end

@interface CalculatorKeypadButton : UIView
- (NSInteger)accessibilityCalculatorButtonID;
@end

@interface DisplayView (CalculatorHistory)
@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *navigationItem;
@end