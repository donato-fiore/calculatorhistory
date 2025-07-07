#import "CalculatorHistoryRecordManager.h"
#import "CalculatorHistoryRecord.h"

@implementation CalculatorHistoryRecordManager

+ (instancetype)sharedManager {
    static CalculatorHistoryRecordManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CalculatorHistoryRecordManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        _defaults = [NSUserDefaults standardUserDefaults];
    }

    return self;
}

- (NSArray <CalculatorHistoryRecord *> *)historyRecords {
    NSArray *history = [_defaults objectForKey:@"CHEquations"];
    NSArray *dates = [_defaults objectForKey:@"CHDates"];

    if (!history || !dates || history.count != dates.count) return @[];
    
    NSMutableArray *records = [NSMutableArray arrayWithCapacity:history.count];
    
    for (NSInteger i = 0; i < history.count; i++) {
        CalculatorHistoryRecord *record = [[CalculatorHistoryRecord alloc] initWithExpression:history[i] 
                                                                      date:[NSDate dateWithTimeIntervalSince1970:[dates[i] doubleValue]]];
        [records addObject:record];
    }
    
    return records;
}

- (void)addRecord:(CalculatorHistoryRecord *)record {
    NSMutableArray *history = [[_defaults objectForKey:@"CHEquations"] mutableCopy] ?: [NSMutableArray array];
    NSMutableArray *dates = [[_defaults objectForKey:@"CHDates"] mutableCopy] ?: [NSMutableArray array];
    
    [history insertObject:record.expression atIndex:0];
    [dates insertObject:@([record.date timeIntervalSince1970]) atIndex:0];
    
    [_defaults setObject:history forKey:@"CHEquations"];
    [_defaults setObject:dates forKey:@"CHDates"];
}

- (void)removeRecordAtIndex:(NSInteger)index {
    NSMutableArray *history = [[_defaults objectForKey:@"CHEquations"] mutableCopy];
    NSMutableArray *dates = [[_defaults objectForKey:@"CHDates"] mutableCopy];
    
    if (index < 0 || index >= history.count || index >= dates.count) return;
    
    [history removeObjectAtIndex:index];
    [dates removeObjectAtIndex:index];
    
    [_defaults setObject:history forKey:@"CHEquations"];
    [_defaults setObject:dates forKey:@"CHDates"];
}

- (void)clearHistory {
    [_defaults removeObjectForKey:@"CHEquations"];
    [_defaults removeObjectForKey:@"CHDates"];
}

@end
