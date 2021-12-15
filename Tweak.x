#include <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface DisplayView : UIView
-(CGRect)frame;
-(UILabel*)accessibilityValueLabel;
-(UIWindow*)_rootView;
@end

@interface CalculatorHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UINavigationBar *_navBar;
	UITableView *_table;
	NSArray *_content;
}
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

void rmFromHistory(int index) {
	NSMutableArray *history = [getCalculatorHistory() mutableCopy];
	NSMutableArray *dates = [getDates() mutableCopy];
	[history removeObjectAtIndex:index];
	[dates removeObjectAtIndex:index];
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
	UILayoutGuide *margins = self.view.layoutMarginsGuide;
	self.view.backgroundColor = [UIColor colorWithRed: 0.20 green: 0.20 blue: 0.20 alpha: 1.00];
	_navBar = [[UINavigationBar alloc] init];
	UINavigationItem *navItem = [[UINavigationItem alloc] init];
	navItem.title = @"History";

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
	UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearButtonPressed)];
	navItem.leftBarButtonItem = doneButton;
	navItem.rightBarButtonItem = clearButton;

	_navBar.tintColor = [UIColor systemOrangeColor];
	_navBar.barTintColor = [UIColor colorWithRed: 0.11 green: 0.11 blue: 0.11 alpha: 1.00];

	[self cofigureTableview];
	_content = getCalculatorHistory();
	_navBar.translatesAutoresizingMaskIntoConstraints = NO;

	[_navBar setItems:@[navItem]];
	[self.view addSubview:_navBar];

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_navBar]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBar)]];
	[_navBar.topAnchor constraintEqualToAnchor:margins.topAnchor].active = YES;
	[_navBar.heightAnchor constraintEqualToConstant:44].active = YES;
}

-(void)cofigureTableview {
	UILayoutGuide *margins = self.view.layoutMarginsGuide;

	_table = [[UITableView alloc] init];
	_table.delegate = self;
	_table.dataSource = self;
	_table.backgroundColor = [UIColor colorWithRed: 0.20 green: 0.20 blue: 0.20 alpha: 1.00];
	_table.tableFooterView = [UIView new];
	_table.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_table];

	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_table]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_table)]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_table attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
	[_table.heightAnchor constraintEqualToAnchor:margins.heightAnchor constant:-56].active = YES;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_content count];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
		rmFromHistory(indexPath.row);
		_content = getCalculatorHistory();
		[_table reloadData];
	}];
	
	UIContextualAction *copyAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Copy\nResult" handler:^(UIContextualAction *_Nonnull action, __kindof UIView *_Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		NSString *string = [getCalculatorHistory() objectAtIndex:indexPath.row];
		pasteboard.string = [string substringFromIndex:(indexOf(string, @"= ") + 2)];
		[_table setEditing:NO animated:YES];
		AudioServicesPlaySystemSound(1519);
	}];
	
	UISwipeActionsConfiguration *swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, copyAction]];
    
	return swipeActions;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
static NSString *cellIdentifier = @"cellIdentifier";
	UITableViewCell *cell = [_table dequeueReusableCellWithIdentifier:cellIdentifier];
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

	if([_content count] > 0) {
		[cell setBackgroundColor:[UIColor colorWithRed: 0.20 green: 0.20 blue: 0.20 alpha: 1.00]];

		UILabel *dateLabel = [[UILabel alloc] init];
		[dateLabel setNumberOfLines:2];
		[dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

		NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[getDates() objectAtIndex:indexPath.row] doubleValue]];		
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

		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[dateLabel setText:[NSString stringWithFormat:@"%@\n%@", dateString, day]];
		[dateLabel setFont:[UIFont monospacedDigitSystemFontOfSize:15 weight:UIFontWeightRegular]];

		UILabel *mathLabel = [[UILabel alloc] init];
		NSString *text = [_content objectAtIndex:indexPath.row];
		NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont monospacedDigitSystemFontOfSize:20 weight:UIFontWeightRegular]}];
		[attrString addAttribute:NSForegroundColorAttributeName value:[UIColor systemOrangeColor] range:NSMakeRange(0, indexOf(text, @"=") + 1)];
		[mathLabel setTextAlignment:NSTextAlignmentRight];
		[mathLabel setAttributedText:attrString];
		[mathLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

		[cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[cell.contentView addSubview:mathLabel];
		[cell.contentView addSubview:dateLabel];

		[cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[mathLabel(==200)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mathLabel)]];
		[cell addConstraint:[NSLayoutConstraint constraintWithItem:dateLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
		[cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[dateLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(dateLabel)]];
		[cell addConstraint:[NSLayoutConstraint constraintWithItem:mathLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
		[cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[mathLabel]-30-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mathLabel)]];
	}
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Details" message:[NSString stringWithString:[getCalculatorHistory() objectAtIndex:indexPath.row]] preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
	[alert addAction:defaultAction];
	[self presentViewController:alert animated:YES completion:nil];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)doneButtonPressed {
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)clearButtonPressed {
	if([_content count] != 0) {
		AudioServicesPlaySystemSound(1519);
	}
	clearHistory();
	_content = @[];
	[_table reloadData];
}
@end

%hook DisplayView
-(void)didMoveToSuperview {
	displayView = self;
	%orig;
		UINavigationBar *navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
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
NSMutableString *one;
NSMutableString *two;
NSString *result;
-(void)touchesEnded:(id)arg1 withEvent:(id)arg2 {
    if(one == nil) {
        one = [NSMutableString stringWithCapacity:16];
        two = [NSMutableString stringWithCapacity:32];
    }
    NSInteger buttonID = [self accessibilityCalculatorButtonID];
    switch(buttonID) {
        case 5:
            [one setString:[displayView accessibilityValueLabel].text];
            [two setString:@" ÷ "];
            %orig;
            break;
        case 6: 
            [one setString:[displayView accessibilityValueLabel].text];
            [two setString:@" × "];
            %orig;
            break;
        case 7: 
            [one setString:[displayView accessibilityValueLabel].text];
            [two setString:@" - "];
            %orig;
            break;
        case 8:
            [one setString:[displayView accessibilityValueLabel].text];
            [two setString:@" + "];
            %orig;
            break;
        case 9: 
            if(one == nil) {
                return;
            }
            if([two length] == 3) {
                [two appendString:[displayView accessibilityValueLabel].text];
                %orig;
                result = [NSString stringWithFormat:@"%@ %@ = %@", one, two, [displayView accessibilityValueLabel].text];
                addToHistory(result);
                [one setString:[displayView accessibilityValueLabel].text];
            } else {
                %orig;
                result = [NSString stringWithFormat:@"%@ %@ = %@", one, two, [displayView accessibilityValueLabel].text];
                addToHistory(result);
            }
            [one setString:[displayView accessibilityValueLabel].text];
            return;
        case 51:
            one = nil;
            two = nil;
            result = nil;
            break;
        default: 
            %orig;
            break;
    }
}
%end

%ctor {
	%init(DisplayView = objc_getClass("Calculator.DisplayView"), CalculatorKeypadButton = objc_getClass("Calculator.CalculatorKeypadButton"));
}