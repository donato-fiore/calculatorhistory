#import "CalculatorHistoryRecordCell.h"

@implementation CalculatorHistoryRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_resultLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_resultLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_resultLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
            [_resultLabel.leadingAnchor constraintEqualToAnchor:self.textLabel.trailingAnchor constant:10],
        ]];
    }
    return self;
}

@end
