#import "CalculatorHistoryViewController.h"
#import "CalculatorHistoryRecordManager.h"
#import "CalculatorHistoryRecord.h"
#import "Extensions/UIFont+Rounded.h"
#import "CalculatorHistoryRecordCell.h"

#import "Utils.h"

#import <AudioToolbox/AudioToolbox.h>

@implementation CalculatorHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor systemBackgroundColor];

    self.navigationItem.title = @"History";
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor systemOrangeColor];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(_dismiss)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearHistory)];

    [self _setupSubviews];

    [_tableView registerClass:[CalculatorHistoryRecordCell class] forCellReuseIdentifier:@"HistoryCell"];
}

- (void)_setupSubviews {
    _tableView = [[UITableView alloc] init];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:_tableView];

    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];

    _data = [[CalculatorHistoryRecordManager sharedManager] historyRecords];
    if (_data.count == 0) {
        [self _addNoHistoryLabel];
    }
}

- (void)_dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearHistory {
    if (_data.count == 0) return;
    AudioServicesPlaySystemSound(1519);

    [[CalculatorHistoryRecordManager sharedManager] clearHistory];
    _data = @[];
    [_tableView reloadData];
    [self _addNoHistoryLabel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CalculatorHistoryRecordCell *cell = (CalculatorHistoryRecordCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (!isLabelTruncated(cell.resultLabel)) return;

    AudioServicesPlaySystemSound(1519);

    CalculatorHistoryRecord *record = [[CalculatorHistoryRecordManager sharedManager] historyRecords][indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:record.expression preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CalculatorHistoryRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];

    if (_data.count == 0) return cell;

    CalculatorHistoryRecord *record = _data[indexPath.row];

    NSArray *dateComponents = [relativeDateFormat(record.date) componentsSeparatedByString:@"||"];
    cell.textLabel.text = [dateComponents firstObject];
    cell.detailTextLabel.text = [dateComponents lastObject];

    [cell.resultLabel setAttributedText:formatExpression(record.expression)];
    [cell.resultLabel setTextAlignment:NSTextAlignmentRight];

    return cell;
}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
        [[CalculatorHistoryRecordManager sharedManager] removeRecordAtIndex:indexPath.row];
        _data = [[CalculatorHistoryRecordManager sharedManager] historyRecords];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        if (_data.count == 0) [self _addNoHistoryLabel];
        completionHandler(YES);
    }];

    UIContextualAction *copyAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Copy\nResult" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
        AudioServicesPlaySystemSound(1519);
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        CalculatorHistoryRecord *record = _data[indexPath.row];
        pasteboard.string = [record.expression substringFromIndex:indexOf(record.expression, @"=") + 2];
        [_tableView setEditing:NO animated:YES];
    }];

    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, copyAction]];
}

- (BOOL)_canShowWhileLocked {
    return YES;
}

- (void)_addNoHistoryLabel {
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView addSubview:view];
    [NSLayoutConstraint activateConstraints:@[
        [view.centerXAnchor constraintEqualToAnchor:_tableView.centerXAnchor],
        [view.centerYAnchor constraintEqualToAnchor:_tableView.centerYAnchor constant:-(self.navigationController.navigationBar.frame.size.height + 25)],
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
