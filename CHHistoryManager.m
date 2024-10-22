#import "CHHistoryManager.h"

@implementation CHHistoryManager

+ (instancetype)sharedManager {
    static CHHistoryManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CHHistoryManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        self.defaults = [NSUserDefaults standardUserDefaults];
    }

    return self;
}

- (NSArray *)history {
    NSArray *history = [self.defaults objectForKey:@"CHEquations"];
    if (!history) return @[];
    
    return history;
}

- (NSArray *)dates {
    NSArray *dates = [self.defaults objectForKey:@"CHDates"];
    if (!dates) return @[];
    
    return dates;
}

- (void)append:(NSString *)equation {
    NSMutableArray *history = [[self history] mutableCopy];
    NSMutableArray *dates = [[self dates] mutableCopy];
    
    [history insertObject:equation atIndex:0];
    NSString *date = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    [dates insertObject:date atIndex:0];
    
    [self.defaults setObject:history forKey:@"CHEquations"];
    [self.defaults setObject:dates forKey:@"CHDates"];
    [self.defaults synchronize];
}

- (void)remove:(int)index {
    NSMutableArray *history = [[self history] mutableCopy];
    NSMutableArray *dates = [[self dates] mutableCopy];
    
    [history removeObjectAtIndex:index];
    [dates removeObjectAtIndex:index];
    
    [self.defaults setObject:history forKey:@"CHEquations"];
    [self.defaults setObject:dates forKey:@"CHDates"];
    [self.defaults synchronize];
}

- (void)clear {
    [self.defaults removeObjectForKey:@"CHEquations"];
    [self.defaults removeObjectForKey:@"CHDates"];
    [self.defaults synchronize];
}

@end
