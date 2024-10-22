#import <UIKit/UIKit.h>

@interface CalculatorHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) UITableView *tableView;
- (void)addNoHistoryLabel;
@end
