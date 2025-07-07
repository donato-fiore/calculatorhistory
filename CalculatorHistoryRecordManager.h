#import <Foundation/Foundation.h>

@class CalculatorHistoryRecord;

@interface CalculatorHistoryRecordManager : NSObject {
    NSUserDefaults *_defaults;
}
+ (instancetype)sharedManager;
- (NSArray <CalculatorHistoryRecord *> *)historyRecords;
- (void)addRecord:(CalculatorHistoryRecord *)record;
- (void)removeRecordAtIndex:(NSInteger)index;
- (void)clearHistory;

@end
