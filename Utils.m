#import "Utils.h"

NSInteger indexOf(NSString *string, NSString *substring) {
    NSRange range = [string rangeOfString:substring];
    if (range.location > 0) return range.location;
    return NSNotFound;
}

NSRange rangeOfNthOccurrence(NSString *string, NSString *substring, NSInteger occurrence) {
    if (occurrence <= 0 || string.length == 0 || substring.length == 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    
    NSRange searchRange = NSMakeRange(0, string.length);
    NSRange foundRange = NSMakeRange(NSNotFound, 0);
    
    for (NSInteger i = 0; i < occurrence; i++) {
        NSRange range = [string rangeOfString:substring options:0 range:searchRange];
        if (range.location == NSNotFound) {
            return NSMakeRange(NSNotFound, 0);
        }
        foundRange = range;
        searchRange = NSMakeRange(NSMaxRange(range), string.length - NSMaxRange(range));
    }
    
    return foundRange;
}

NSString *superscript(NSString *string) {
    return [NSString stringWithFormat:@">>%@>>", string];
}

NSString *subscript(NSString *string) {
    return [NSString stringWithFormat:@"<<%@<<", string];
}

NSString *relativeDateFormat(NSDate *date) {
    NSString *day;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([[NSCalendar currentCalendar] isDateInToday:date]) {
        day = @"Today";
    } else if ([[NSCalendar currentCalendar] isDateInYesterday:date]) {
        day = @"Yesterday";
    } else {
        [dateFormatter setDateFormat:@"MMM d, yyyy"];
        day = [dateFormatter stringFromDate:date];
    }

    [dateFormatter setDateFormat:@"h:mm a"];
    NSString *time = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@||%@", day, time];
}

bool isLabelTruncated(UILabel *label) {
    CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName: label.font}];
    return size.width > label.frame.size.width;
}

NSAttributedString *formatExpression(NSString *equation) {
    NSString *regexPattern = @"E\\d+";
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regexPattern options:0 error:nil];
    NSArray *matches = [regex matchesInString:equation options:0 range:NSMakeRange(0, equation.length)];

    for (NSInteger i = matches.count - 1; i >= 0; i--) {
        NSTextCheckingResult *match = matches[i];
        NSRange matchRange = [match range];
        NSString *matchString = [equation substringWithRange:matchRange];

        equation = [equation stringByReplacingCharactersInRange:matchRange withString:[NSString stringWithFormat:@"×10>>%@>>", [matchString substringFromIndex:1]]];
    }

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:equation attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20]}];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor systemOrangeColor] range:NSMakeRange(0, indexOf(equation, @"=") + 1)];
    
    NSRegularExpression *superScriptRegex = [NSRegularExpression regularExpressionWithPattern:@">>(.*?)>>" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *superScriptMatches = [superScriptRegex matchesInString:[attributedString string] options:0 range:NSMakeRange(0, [[attributedString string] length])];
    for (NSTextCheckingResult *match in superScriptMatches) {
        NSRange matchRange = [match rangeAtIndex:1];
        [attributedString addAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12], NSBaselineOffsetAttributeName: @10} range:matchRange];
    }

    NSRegularExpression *subScriptRegex = [NSRegularExpression regularExpressionWithPattern:@"<<(.*?)<<" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *subScriptMatches = [subScriptRegex matchesInString:[attributedString string] options:0 range:NSMakeRange(0, [[attributedString string] length])];
    for (NSTextCheckingResult *match in subScriptMatches) {
        NSRange matchRange = [match rangeAtIndex:1];
        [attributedString addAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12], NSBaselineOffsetAttributeName: @(-10)} range:matchRange];
    }

    [attributedString.mutableString replaceOccurrencesOfString:@"<<" withString:@"" options:0 range:NSMakeRange(0, [attributedString.mutableString length])];
    [attributedString.mutableString replaceOccurrencesOfString:@">>" withString:@"" options:0 range:NSMakeRange(0, [attributedString.mutableString length])];

    return attributedString;
}

NSString *parseExpression(NSString *expression) {
    NSLog(@"[calc] parsing expression: %@", expression);

    if ([expression isEqualToString:@"pi"] || [expression isEqualToString:@"exp(1)"]) return @"";
    expression = [expression stringByReplacingOccurrencesOfString:@"3.141592653589793238462643383279503" withString:@"π"];
    expression = [expression stringByReplacingOccurrencesOfString:@"2.718281828459045235360287471352662" withString:@"e"];

    if (specialBehavior == kRadical && (![expression containsString:@"pow"] || ![expression containsString:@"/"])) {
        NSLog(@"[calc] invalidating specialB");
        specialBehavior = kInvalid;
    }
    if ([expression containsString:@"pow("] && [expression containsString:@")*("]) specialBehavior = kScientificNotation;
    if (specialBehavior == kLogarithm && ![expression containsString:@"log("]) specialBehavior = kInvalid;
    if ([expression containsString:@"log("]) specialBehavior = kLogarithm;

    if ([expression containsString:@"pow("] && [expression containsString:@"1.0/"]) {
        NSLog(@"[calc] power with inverse");
        NSArray *components = [expression componentsSeparatedByString:@",(1.0/"];
        NSString *radicand = [components.firstObject componentsSeparatedByString:@"pow("].lastObject;
        NSString *index = [components.lastObject stringByReplacingOccurrencesOfString:@"))" withString:@""];

        NSLog(@"[calc] components: %@", components);
        NSLog(@"[calc] radicand: %@", radicand);
        NSLog(@"[calc] index: %@", index);
        NSString *fom = [NSString stringWithFormat:@"%@√(%@)", superscript(index), radicand];
        NSLog(@"[calc] formatted: %@", fom);
        return fom;
    }

    switch (specialBehavior) {
        case kPercent:
            specialBehavior = kInvalid;
            expression = [expression componentsSeparatedByString:@"/"].firstObject;
            expression = [expression stringByReplacingOccurrencesOfString:@"(" withString:@""];
            expression = [expression stringByReplacingOccurrencesOfString:@")" withString:@""];
            expression = [NSString stringWithFormat:@"%@\uFF05", expression];
            if ([expression isEqualToString:@"0\uFF05"]) return @"";
            return expression;
        case kRadical: {
                NSLog(@"[calc] using radical");
                specialBehavior = kInvalid;
                NSArray *components = [expression componentsSeparatedByString:@","];
                NSString *radicand = [components.firstObject componentsSeparatedByString:@"("].lastObject;
                if ([radicand isEqualToString:@"0"]) return @"";
                NSString *index = [components.lastObject componentsSeparatedByString:@"/"].lastObject;
                index = [index stringByReplacingOccurrencesOfString:@")" withString:@""];
                if ([index isEqualToString:@"2"]) return [NSString stringWithFormat:@"√(%@)", radicand];
                if ([index isEqualToString:@"3"]) return [NSString stringWithFormat:@"∛(%@)", radicand];

                NSLog(@"[calc] %@ sqrt(%@)", index, radicand);

                return [NSString stringWithFormat:@"%@√(%@)", superscript(index), radicand];
        }
        case kInverse:
            expression = [[expression componentsSeparatedByString:@"("].lastObject stringByReplacingOccurrencesOfString:@")" withString:@""];
            return [NSString stringWithFormat:@"%@>>-1>>", expression];
        case kScientificNotation: {
            specialBehavior = kInvalid;
            NSArray *components = [expression componentsSeparatedByString:@")*("];
            
            NSString *coefficient = [components.lastObject stringByReplacingOccurrencesOfString:@")" withString:@""];
            NSString *exponent = [components.firstObject componentsSeparatedByString:@","].lastObject;
            return [NSString stringWithFormat:@"%@×10%@", coefficient, superscript(exponent)];
        }
        case kLogarithm: {
            specialBehavior = kInvalid;
            NSArray *components = [expression componentsSeparatedByString:@"log("];
            NSString *base = [components.lastObject stringByReplacingOccurrencesOfString:@")" withString:@""];
            NSString *argument = [[components[1] componentsSeparatedByString:@"("].lastObject stringByReplacingOccurrencesOfString:@")/" withString:@""];
            return [NSString stringWithFormat:@"log%@(%@)", subscript(base), argument];
        }
    }

    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdfghijklmnopqrstuvwxyz"];
    bool basicExpression = ([expression.lowercaseString rangeOfCharacterFromSet:validChars].location == NSNotFound);

    if (basicExpression) {
        expression = [expression stringByReplacingOccurrencesOfString:@"(" withString:@" "];
        expression = [expression stringByReplacingOccurrencesOfString:@")" withString:@" "];
        expression = [expression stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        expression = [expression stringByReplacingOccurrencesOfString:@"*" withString:@"×"];
        expression = [expression stringByReplacingOccurrencesOfString:@"/" withString:@"÷"];
    } else {
        NSArray *components = [expression componentsSeparatedByString:@"("];
        if ([components.firstObject isEqualToString:@"exp"]) {
            expression = [NSString stringWithFormat:@"e%@", superscript([components.lastObject componentsSeparatedByString:@")"].firstObject)];
        } else if ([components.firstObject isEqualToString:@"pow"]) {
            NSString *base = [components.lastObject componentsSeparatedByString:@","].firstObject;
            NSString *exponent = [[[components.lastObject componentsSeparatedByString:@","].lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            expression = [NSString stringWithFormat:@"%@%@", base, superscript(exponent)];
        }

        for (NSString *trigFunction in @[@"sin", @"cos", @"tan"]) {
            if ([components.firstObject containsString:trigFunction]) {
                NSString *function = [components.firstObject stringByReplacingOccurrencesOfString:@"d" withString:@""];
                if ([components.firstObject hasPrefix:@"a"]) {
                    function = [function substringFromIndex:[@"a" length]];
                    function = [NSString stringWithFormat:@"%@⁻¹", function];
                }
                expression = [NSString stringWithFormat:@"%@(%@", function, components.lastObject];
            }
        }
    }

    NSLog(@"[calc] final expression: %@", expression);

    return expression;
}

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
