#import <UIKit/UIKit.h>

@class CalculatorHistoryRecord;

@interface CalculatorHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UITableView *_tableView;
    NSArray<CalculatorHistoryRecord *> *_data;
}
@end
