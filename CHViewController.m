#import "CHViewController.h"
#import "Utils.h"
#import "Headers.h"
#import "CHHistoryManager.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation CalculatorHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];

    self.navigationItem.title = @"History";
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor systemOrangeColor];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearHistory)];


    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];

    self.data = [[CHHistoryManager sharedManager] history];
    if (self.data.count == 0) {
        [self addNoHistoryLabel];
    }
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearHistory {
    if (self.data.count == 0) return;
    AudioServicesPlaySystemSound(1519);

    [[CHHistoryManager sharedManager] clear];
    self.data = @[];
    [self.tableView reloadData];
    [self addNoHistoryLabel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!isLabelTruncated(cell.resultLabel)) return;

    AudioServicesPlaySystemSound(1519);

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[[[CHHistoryManager sharedManager] history] objectAtIndex:indexPath.row] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        
        cell.resultLabel = [[UILabel alloc] init];
        cell.resultLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:cell.resultLabel];
        
        [NSLayoutConstraint activateConstraints:@[
            [cell.resultLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [cell.resultLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-20],
            [cell.resultLabel.leadingAnchor constraintEqualToAnchor:cell.textLabel.trailingAnchor constant:10],
        ]];
    }

    if (self.data.count == 0) return cell;

    cell.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    NSArray *dateComponents = [relativeDateFormat([NSDate dateWithTimeIntervalSince1970:[[[CHHistoryManager sharedManager] dates][indexPath.row] doubleValue]]) componentsSeparatedByString:@"||"];
    cell.textLabel.text = [dateComponents firstObject];
    cell.detailTextLabel.text = [dateComponents lastObject];
    
    NSString *equation = self.data[indexPath.row];
    
    [cell.resultLabel setAttributedText:formatExpression(equation)];
    [cell.resultLabel setTextAlignment:NSTextAlignmentRight];

    return cell;
}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
        [[CHHistoryManager sharedManager] remove:indexPath.row];
        self.data = [[CHHistoryManager sharedManager] history];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        if (self.data.count == 0) [self addNoHistoryLabel];
        completionHandler(YES);
    }];

    UIContextualAction *copyAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Copy\nResult" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
        AudioServicesPlaySystemSound(1519);
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSString *equation = self.data[indexPath.row];
        pasteboard.string = [equation substringFromIndex:indexOf(equation, @"=") + 2];
        [self.tableView setEditing:NO animated:YES];
    }];

    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, copyAction]];
}

- (BOOL)_canShowWhileLocked {
    return YES;
}

- (void)addNoHistoryLabel {
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView addSubview:view];
    [NSLayoutConstraint activateConstraints:@[
        [view.centerXAnchor constraintEqualToAnchor:self.tableView.centerXAnchor],
        [view.centerYAnchor constraintEqualToAnchor:self.tableView.centerYAnchor constant:-(self.navigationController.navigationBar.frame.size.height + 25)],
        [view.widthAnchor constraintEqualToConstant:200],
        [view.heightAnchor constraintEqualToConstant:200]
    ]];

    UIImageView *clockView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"clock"]];
    clockView.tintColor = [UIColor systemGray2Color];
    clockView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:clockView];
    [NSLayoutConstraint activateConstraints:@[
        [clockView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [clockView.centerYAnchor constraintEqualToAnchor:view.centerYAnchor],
        [clockView.widthAnchor constraintEqualToConstant:50],
        [clockView.heightAnchor constraintEqualToConstant:50]
    ]];

    UILabel *label = [[UILabel alloc] init];
    label.text = @"No History";
    label.font = [UIFont roundedFontOfSize:24 weight:UIFontWeightRegular];
    [view addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor systemGray2Color];
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [label.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [label.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [label.heightAnchor constraintEqualToConstant:28],
        [label.topAnchor constraintEqualToAnchor:clockView.bottomAnchor constant:10]
    ]];
}

@end
