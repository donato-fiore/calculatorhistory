#import <Foundation/Foundation.h>

@interface CHHistoryManager : NSObject
@property (nonatomic, strong) NSUserDefaults *defaults;

+ (instancetype)sharedManager;
- (NSArray *)history;
- (NSArray *)dates;
- (void)append:(NSString *)equation;
- (void)remove:(int)index;
- (void)clear;

@end
