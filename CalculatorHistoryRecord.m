#import "CalculatorHistoryRecord.h"

@implementation CalculatorHistoryRecord

- (instancetype)initWithExpression:(NSString *)expression date:(NSDate *)date {
    self = [super init];
    if (self) {
        _expression = expression;
        _date = date;
    }
    return self;
}

- (instancetype)initWithExpression:(NSString *)expression {
    return [self initWithExpression:expression date:[NSDate date]];
}

@end