#include <UIKit/UIKit.h>

@interface DisplayView : UIView
-(CGRect)frame;
-(UILabel*)accessibilityValueLabel;
-(UIWindow*)_rootView;
@end

@interface CalculatorHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong,nonatomic) UITableView *table;
@property (strong,nonatomic) NSArray *content;
@end

@interface CalculatorKeypadButton : UIView
-(NSInteger)accessibilityCalculatorButtonID;
@end

DisplayView *displayView;

NSArray *getCalculatorHistory() {
	NSArray *history = [[NSUserDefaults standardUserDefaults] arrayForKey:@"CalculatorHistory"];
	if(history == nil) {
		history = @[];
	}
	return history;
}

NSArray *getDates() {
	NSArray *dates = [[NSUserDefaults standardUserDefaults] arrayForKey:@"HistoryDates"];
	if(dates == nil) {
		dates = @[];
	}
	return dates;
}

void addToHistory(NSString *equation) {
	NSMutableArray *history = [getCalculatorHistory() mutableCopy];
	NSMutableArray *dates = [getDates() mutableCopy];
	[history insertObject:equation atIndex:0];
	NSDate *date = [NSDate date];
	NSString *dateString = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
	[dates insertObject:dateString atIndex:0];
	[[NSUserDefaults standardUserDefaults] setObject:history forKey:@"CalculatorHistory"];
	[[NSUserDefaults standardUserDefaults] setObject:dates forKey:@"HistoryDates"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

void clearHistory() {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CalculatorHistory"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HistoryDates"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

int indexOf(NSString *string, NSString *target) {
    NSRange range = [string rangeOfString:target];
    if (range.length > 0) {
        return range.location;
    } else {
        return -1;
    }
}

@implementation CalculatorHistoryViewController
-(void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithRed: 0.20 green: 0.20 blue: 0.20 alpha: 1.00];
	
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
	UINavigationItem *navItem = [[UINavigationItem alloc] init];
	navItem.title = @"History";

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
	UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)];
	navItem.leftBarButtonItem = doneButton;
	navItem.rightBarButtonItem = clearButton;

	navBar.tintColor = [UIColor systemOrangeColor];
	navBar.barTintColor = [UIColor colorWithRed: 0.11 green: 0.11 blue: 0.11 alpha: 1.00];

	[self cofigureTableview];
    self.content = getCalculatorHistory();

	[navBar setItems:@[navItem]];
	[self.view addSubview:navBar];

}

-(void)cofigureTableview {
    self.table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	CGRect frame = self.table.frame;
	frame.origin.y = 54.0;
	self.table.frame = frame;

    self.table.delegate = self;
    self.table.dataSource = self;
	self.table.backgroundColor = [UIColor colorWithRed: 0.20 green: 0.20 blue: 0.20 alpha: 1.00];
    self.table.tableFooterView = [UIView new];

	[self.view addSubview:self.table];
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _content.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
	UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 60)];
	dateLabel.numberOfLines = 2;

	NSString *timestamp = [getDates() objectAtIndex:indexPath.row];
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
	
	NSString *day = [[NSString alloc] init];
	if([[NSCalendar currentCalendar] isDateInToday:date]) {
		day = @"Today";
	} else if([[NSCalendar currentCalendar] isDateInYesterday:date]) {
		day = @"Yesterday";
	} else {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MM/dd/yy"];
		day = [dateFormatter stringFromDate:date];
	}

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
	[dateFormatter setDateFormat:@"h:mm a"];
	NSString *dateString = [dateFormatter stringFromDate:date];

	dateLabel.backgroundColor = [UIColor clearColor];
	dateLabel.text = [NSString stringWithFormat:@"%@\n%@", dateString, day];
	dateLabel.font= [UIFont fontWithName:@"Helvetica Neue" size:15];
	[cell addSubview:dateLabel];

	UILabel *mathLabel = [[UILabel alloc] initWithFrame:CGRectMake(110,0,250,60)];
	NSString *text = [_content objectAtIndex:indexPath.row];
	NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica Neue" size:20]}];
	[attrString addAttribute:NSForegroundColorAttributeName value:[UIColor systemOrangeColor] range:NSMakeRange(0, indexOf(text, @"=") + 1)];
	
	mathLabel.textAlignment = NSTextAlignmentRight;
	mathLabel.attributedText = attrString;
	cell.backgroundColor = [UIColor colorWithRed: 0.20 green: 0.20 blue: 0.20 alpha: 1.00];
	[cell addSubview:mathLabel];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"See More" message:[NSString stringWithString:[getCalculatorHistory() objectAtIndex:indexPath.row]] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)doneButtonPressed {
	[self dismissViewControllerAnimated:YES completion:nil];
}
-(void)clearButtonPressed {
	clearHistory();
	self.content = @[];
	[self.table reloadData];
}
@end

%hook DisplayView
-(void)layoutSubviews {
	displayView = self;
	%orig;

	UINavigationBar *navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 50)];
	UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
	[appearance configureWithTransparentBackground];
	navbar.standardAppearance = appearance;

	UINavigationItem *navItem = [[UINavigationItem alloc] init];
	UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium scale:UIImageSymbolScaleMedium];
	UIImage *historyImage = [UIImage systemImageNamed:@"clock.arrow.circlepath" withConfiguration:config];
	UIBarButtonItem *historyButton = [[UIBarButtonItem alloc] initWithImage:historyImage style:UIBarButtonItemStylePlain target:self action:@selector(history)];
	historyButton.tintColor = [UIColor systemOrangeColor];
	navItem.leftBarButtonItem = historyButton;

	[navbar setItems:@[navItem]];
	[self addSubview:navbar];
}

%new
-(void)history {
	CalculatorHistoryViewController *vc = [[CalculatorHistoryViewController alloc] init];
	[[self _rootView].rootViewController presentViewController:vc animated:YES completion:nil];
}
%end


%hook CalculatorKeypadButton
NSMutableString *result;
-(void)touchesEnded:(id)arg1 withEvent:(id)arg2 {	
	if(result == nil) {
		result = [NSMutableString stringWithCapacity:64];
	}
	NSInteger buttonID = [self accessibilityCalculatorButtonID];
	switch(buttonID) {
		case 5:
			[result appendString:[displayView accessibilityValueLabel].text];
			[result appendString:@" ÷ "];
			%orig;
			break;
		case 6:
			[result appendString:[displayView accessibilityValueLabel].text];
			[result appendString:@" x "];
			%orig;
			break;
		case 7:
			[result appendString:[displayView accessibilityValueLabel].text];
			[result appendString:@" - "];
			%orig;
			break;
		case 8:
			[result appendString:[displayView accessibilityValueLabel].text];
			[result appendString:@" + "];
			%orig;
			break;
		case 9:
			[result appendString:[displayView accessibilityValueLabel].text];
			[result appendString:@" = "];
			%orig;
			[result appendString:[displayView accessibilityValueLabel].text];
			addToHistory(result);
			[result setString:@""];
			return;
		case 51:
			[result setString:@""];
			%orig;
			break;	
	}
}
%end

%ctor {
	%init(DisplayView = objc_getClass("Calculator.DisplayView"), CalculatorKeypadButton = objc_getClass("Calculator.CalculatorKeypadButton"));
}