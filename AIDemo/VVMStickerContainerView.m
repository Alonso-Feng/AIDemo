//
//  VVMStickerContainerView.m
//  AIDemo
//

#import "VVMStickerContainerView.h"
#import <Masonry/Masonry.h>

@interface VVMStickerContainerView ()

@property (nonatomic, strong, readwrite) VVMStickerDeleteZoneView *deleteZoneView;
@property (nonatomic, strong, readwrite) UIView *bottomMaskView;
@property (nonatomic, strong, readwrite) UIView *stickerView;
@property (nonatomic, assign) CGFloat deleteZoneThreshold;
@property (nonatomic, assign) CGFloat bottomMaskHeight;

@end

@implementation VVMStickerContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.deleteZoneThreshold = 100.0;
        self.bottomMaskHeight = 120.0;
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.bottomMaskView];
        [self addSubview:self.deleteZoneView];
        
        [self.deleteZoneView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.mas_equalTo(80);
        }];
        
        [self.bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(self.bottomMaskHeight);
        }];
    }
    return self;
}

#pragma mark - Lazy Load

- (UIView *)bottomMaskView {
    if (!_bottomMaskView) {
        _bottomMaskView = [[UIView alloc] init];
        _bottomMaskView.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:0.95];
    }
    return _bottomMaskView;
}

- (VVMStickerDeleteZoneView *)deleteZoneView {
    if (!_deleteZoneView) {
        _deleteZoneView = [[VVMStickerDeleteZoneView alloc] init];
    }
    return _deleteZoneView;
}

- (UIView *)stickerView {
    if (!_stickerView) {
        _stickerView = [[UIView alloc] init];
        _stickerView.backgroundColor = [UIColor blueColor];
    }
    return _stickerView;
}

#pragma mark - Public Methods

- (void)setupStickerWithFrame:(CGRect)frame {
    if (self.stickerView.superview) {
        [self.stickerView removeFromSuperview];
    }
    
    self.stickerView.frame = frame;
    [self insertSubview:self.stickerView belowSubview:self.deleteZoneView];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.stickerView addGestureRecognizer:panGesture];
}

- (void)removeSticker {
    [self.stickerView removeFromSuperview];
    self.stickerView = nil;
}

#pragma mark - Pan Gesture Handler

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    CGPoint originalCenter = self.stickerView.center;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self stickerDragBegan];
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGFloat newX = originalCenter.x + translation.x;
            CGFloat newY = originalCenter.y + translation.y;
            
            CGPoint targetPosition = [self shouldMoveToPosition:CGPointMake(newX, newY)];
            self.stickerView.center = targetPosition;
            
            [self stickerDidDragToPosition:targetPosition];
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self stickerDragEnded];
            break;
            
        default:
            break;
    }
}

#pragma mark - Drag Logic

- (void)stickerDragBegan {
    [self showDraggableArea];
    [self.deleteZoneView show];
    [self bringSubviewToFront:self.deleteZoneView];
}

- (CGPoint)shouldMoveToPosition:(CGPoint)position {
    CGFloat minY = CGRectGetMaxY(self.deleteZoneView.frame) + CGRectGetHeight(self.stickerView.frame) / 2;
    CGFloat maxY = CGRectGetMinY(self.bottomMaskView.frame) - CGRectGetHeight(self.stickerView.frame) / 2;
    
    position.y = MAX(minY, MIN(position.y, maxY));
    
    CGFloat halfWidth = CGRectGetWidth(self.stickerView.frame) / 2;
    position.x = MAX(halfWidth, MIN(position.x, self.bounds.size.width - halfWidth));
    
    return position;
}

- (void)stickerDidDragToPosition:(CGPoint)position {
    BOOL isInDeleteZone = position.y < self.deleteZoneThreshold;
    [self.deleteZoneView setHighlighted:isInDeleteZone animated:YES];
}

- (void)stickerDragEnded {
    CGPoint position = self.stickerView.center;
    
    if (position.y < self.deleteZoneThreshold) {
        [self deleteSticker];
    }
    
    [self hideDraggableArea];
    [self.deleteZoneView hide];
    [self.deleteZoneView setHighlighted:NO animated:NO];
}

- (void)deleteSticker {
    [UIView animateWithDuration:0.3 animations:^{
        self.stickerView.alpha = 0;
        self.stickerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        UIView *sticker = self.stickerView;
        [sticker removeFromSuperview];
        self.stickerView = nil;
        
        if ([self.delegate respondsToSelector:@selector(stickerContainerView:didDeleteSticker:)]) {
            [self.delegate stickerContainerView:self didDeleteSticker:sticker];
        }
    }];
}

#pragma mark - Draggable Area Display

- (void)showDraggableArea {
    self.stickerView.layer.borderWidth = 2.0;
    self.stickerView.layer.borderColor = [UIColor systemBlueColor].CGColor;
    self.stickerView.layer.shadowColor = [UIColor systemBlueColor].CGColor;
    self.stickerView.layer.shadowOffset = CGSizeMake(0, 0);
    self.stickerView.layer.shadowRadius = 10;
    self.stickerView.layer.shadowOpacity = 0.5;
}

- (void)hideDraggableArea {
    self.stickerView.layer.borderWidth = 0;
    self.stickerView.layer.shadowOpacity = 0;
}

@end
