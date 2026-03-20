//
//  VVMStickerContainerView.h
//  AIDemo
//

#import <UIKit/UIKit.h>
#import "VVMStickerDeleteZoneView.h"

@protocol VVMStickerContainerViewDelegate <NSObject>

@optional
- (void)stickerContainerView:(VVMStickerContainerView *)containerView didDeleteSticker:(UIView *)sticker;

@end

@interface VVMStickerContainerView : UIView

@property (nonatomic, weak, nullable) id<VVMStickerContainerViewDelegate> delegate;

- (void)setupStickerWithFrame:(CGRect)frame;
- (void)removeSticker;

@end
