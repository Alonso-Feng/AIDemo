//
//  VVMStickerDeleteZoneView.m
//  AIDemo
//

#import "VVMStickerDeleteZoneView"
#import <Masonry/Masonry.h>

@interface VVMStickerDeleteZoneView ()

@property (nonatomic, strong, readwrite) UIImageView *trashIconView;
@property (nonatomic, strong, readwrite) UILabel *deleteLabel;
@property (nonatomic, strong, readwrite) UIStackView *contentStackView;

@end

@implementation VVMStickerDeleteZoneView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:0.95];
        self.hidden = YES;
        
        [self addSubview:self.contentStackView];
        
        [self.contentStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(10);
        }];
    }
    return self;
}

#pragma mark - Lazy Load

- (UIImageView *)trashIconView {
    if (!_trashIconView) {
        _trashIconView = [[UIImageView alloc] init];
        _trashIconView.contentMode = UIViewContentModeScaleAspectFit;
        _trashIconView.image = [UIImage systemImageNamed:@"trash"];
        _trashIconView.tintColor = [UIColor redColor];
        [_trashIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(40);
        }];
    }
    return _trashIconView;
}

- (UILabel *)deleteLabel {
    if (!_deleteLabel) {
        _deleteLabel = [[UILabel alloc] init];
        _deleteLabel.text = @"拖到这里删除";
        _deleteLabel.textColor = [UIColor redColor];
        _deleteLabel.font = [UIFont systemFontOfSize:14];
        _deleteLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _deleteLabel;
}

- (UIStackView *)contentStackView {
    if (!_contentStackView) {
        _contentStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.trashIconView, self.deleteLabel]];
        _contentStackView.axis = UILayoutConstraintAxisHorizontal;
        _contentStackView.alignment = UIStackViewAlignmentCenter;
        _contentStackView.spacing = 4;
    }
    return _contentStackView;
}

#pragma mark - Public Methods

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    CGFloat scale = highlighted ? 1.3 : 1.0;
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.contentStackView.transform = CGAffineTransformMakeScale(scale, scale);
            self.contentStackView.alpha = highlighted ? 1.0 : 0.7;
        }];
    } else {
        self.contentStackView.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

@end
