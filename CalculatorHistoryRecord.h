#import <Foundation/Foundation.h>

@interface CalculatorHistoryRecord : NSObject

@property (nonatomic, strong) NSString *expression;
@property (nonatomic, strong) NSDate *date;

- (instancetype)initWithExpression:(NSString *)expression date:(NSDate *)date;
- (instancetype)initWithExpression:(NSString *)expression;

@end