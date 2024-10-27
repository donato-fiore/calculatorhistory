#import <dlfcn.h>

#import "Headers.h"
#import "Utils.h"
#import "CHViewController.h"
#import "CHHistoryManager.h"

%hook UITableViewCell
%property (nonatomic, strong) UILabel *resultLabel;
%end

NSInteger specialBehavior;
bool bypassDefault;

%hook DisplayView
%property (nonatomic, strong) UINavigationBar *navbar;
%property (nonatomic, strong) UINavigationItem *navItem;

- (void)didMoveToSuperview {
	%orig;

    DisplayView *displayView = (DisplayView *)self;
    
    specialBehavior = kInvalid;
    bypassDefault = false;

    displayView.navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
    [appearance configureWithTransparentBackground];
    displayView.navbar.standardAppearance = appearance;

    displayView.navItem = [[UINavigationItem alloc] init];
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium scale:UIImageSymbolScaleMedium];
    UIImage *historyImage = [UIImage systemImageNamed:@"clock.arrow.circlepath" withConfiguration:config];
    UIBarButtonItem *historyButton = [[UIBarButtonItem alloc] initWithImage:historyImage style:UIBarButtonItemStylePlain target:self action:@selector(history)];
    historyButton.tintColor = [UIColor systemOrangeColor];
    displayView.navItem.leftBarButtonItem = historyButton;

    [displayView.navbar setItems:@[displayView.navItem]];
    [self addSubview:displayView.navbar];
}

%new
- (void)history {
	CalculatorHistoryViewController *vc = [[CalculatorHistoryViewController alloc] init];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
	nav.modalPresentationStyle = UIModalPresentationFormSheet;
	[((UIView *)self).window.rootViewController presentViewController:nav animated:YES completion:nil];
}

%end

int (*orig_CalculatePerformExpression)(char* expr, int significantDigits, int flags, char* answer);
int hooked_CalculatePerformExpression(char* expr, int significantDigits, int flags, char* answer) {
    bypassDefault = false;
	bool ret = orig_CalculatePerformExpression(expr, significantDigits, flags, answer);

	NSString *expression = [NSString stringWithUTF8String:expr];
	NSString *answerString = [NSString stringWithUTF8String:answer];

    NSString *formatted = parseExpression(expression);
    if ([formatted length] == 0 || [answerString length] == 0 || [expression containsString:@".)"]) return ret;
    
    NSString *result = [NSString stringWithFormat:@"%@ = %@", formatted, answerString];
    NSLog(@"[calc] original format: %@", result);

    NSMutableString *mutableResult = [result mutableCopy];
    NSString *regexPattern = @"\\d+\\.?\\d*"; // match numbers
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regexPattern options:0 error:nil];
    NSArray* matches = [regex matchesInString:result options:0 range:NSMakeRange(0, result.length)];
    for (NSTextCheckingResult *match in matches) {
        NSString *strNumber = [result substringWithRange:match.range];
        NSLog(@"[calc] match: %@", strNumber);

        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

        NSNumber *number = [numberFormatter numberFromString:strNumber];
        if ([number doubleValue] > 100000) {
            numberFormatter.numberStyle = NSNumberFormatterScientificStyle;
            numberFormatter.maximumFractionDigits = 2;
        }

        if ([number doubleValue] < 1 && [number doubleValue] > 0) {
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            numberFormatter.maximumFractionDigits = 10;
        }

        NSRange rangeOfOriginalNumber = [mutableResult rangeOfString:strNumber];
        if (rangeOfOriginalNumber.location != NSNotFound) {
            numberFormatter.locale = [NSLocale currentLocale];
            NSLog(@"[calc] replacing %@ with %@", strNumber, [numberFormatter stringFromNumber:number]);
            [mutableResult replaceCharactersInRange:rangeOfOriginalNumber withString:[numberFormatter stringFromNumber:number]];
        }
    }

    result = [mutableResult copy];
    NSLog(@"[calc] new format: %@", result);

    if ([[result componentsSeparatedByString:@" = "].firstObject containsString:@"E"] && [[result componentsSeparatedByString:@" = "].firstObject containsString:@">>"]) {
        NSRange range = rangeOfNthOccurrence(result, @">>", 1);

        if (range.location != NSNotFound) {
            NSString *first = [result substringToIndex:range.location];
            if (first.length == 0) {
                range = rangeOfNthOccurrence(result, @">>", 2);
                first = [[result substringToIndex:range.location] stringByReplacingOccurrencesOfString:@">>" withString:@""];
            }

            NSString *second = [[[result substringFromIndex:range.location + range.length] componentsSeparatedByString:@" = "].firstObject stringByReplacingOccurrencesOfString:@">>" withString:@""];
            NSString *third = [result componentsSeparatedByString:@" = "].lastObject;

            if ([result containsString:@"√"]) {
                result = [NSString stringWithFormat:@">>%@>>%@ = %@", first, second, third];
            } else {
                result = [NSString stringWithFormat:@"(%@)>>%@>> = %@", first, second, third];
            }
        }
    }
    
    [[CHHistoryManager sharedManager] append:result];

    NSLog(@"[calc] logging: %@", result);
	
    return ret;
}

%hook CalculatorModel

- (void)buttonPressed:(NSInteger)buttonID {
    switch (buttonID) {
        case 4:
            specialBehavior = kPercent;
            break;
        case 33:
            specialBehavior = kInverse;
            break;
        case 34:
            specialBehavior = kRadical;
            break;
        case 35:
            specialBehavior = kRadical;
            break;
        case 36:
            specialBehavior = kRadical;
            bypassDefault = true;
            break;
        case 38:
            specialBehavior = kLogarithm;
            bypassDefault = true;
            break;
        case 44:
            specialBehavior = kScientificNotation;
            bypassDefault = true;
            break;
        case 56:
            specialBehavior = kLogarithm;
            bypassDefault = true;
            break;
        case 57:
            specialBehavior = kLogarithm;
            break;
        default:
            if (!bypassDefault) specialBehavior = kInvalid;
            break;
    }

    %orig;
}

%end


%ctor {
    int (*CalculatePerformExpression)(char *, int, int, char *);
	void *handle = dlopen("/System/Library/PrivateFrameworks/Calculate.framework/Calculate", RTLD_LAZY);
	CalculatePerformExpression = dlsym(handle, "CalculatePerformExpression");

	MSHookFunction(CalculatePerformExpression, (void *)hooked_CalculatePerformExpression, (void **)&orig_CalculatePerformExpression);

	%init(DisplayView = objc_getClass("Calculator.DisplayView"), CalculatorModel = objc_getClass("Calculator.CalculatorModel"));
}
