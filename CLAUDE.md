# CLAUDE.md

本文档为 Claude Code (claude.ai/code) 在本代码库中工作提供指导。

## 项目概述

**AIDemo** - 演示贴纸拖拽功能的 iOS 应用。

- **开发语言**：Objective-C
- **UI 框架**：UIKit
- **布局库**：Masonry (链式 Auto Layout DSL)
- **最低支持**：iOS 13.0

## 构建与运行

```bash
# 在 Xcode 中打开
open AIDemo.xcodeproj

# 命令行构建
xcodebuild -project AIDemo.xcodeproj -scheme AIDemo -configuration Debug build

# 清理构建
xcodebuild -project AIDemo.xcodeproj -scheme AIDemo clean build
```

## 架构结构

```
AIDemo/
├── AppDelegate.(h|m)              # 应用生命周期
├── SceneDelegate.(h|m)            # Scene/窗口管理
├── ViewController.(h|m)           # 主视图控制器
├── VVMStickerContainerView.(h|m)  # 贴纸容器（处理拖拽）
└── VVMStickerDeleteZoneView.(h|m) # 删除区域 UI 组件
```

## 核心组件

### VVMStickerContainerView（贴纸容器视图）

**功能**：
- 管理贴纸视图和拖拽手势
- 定义可拖拽区域（删除区和底部遮罩之间）
- 通过代理回调删除事件

**代理方法**：
```objc
@protocol VVMStickerContainerViewDelegate <NSObject>
- (void)stickerContainerView:(VVMStickerContainerView *)containerView
              didDeleteSticker:(UIView *)sticker;
@end
```

**公开方法**：
- `- (void)setupStickerWithFrame:(CGRect)frame` - 设置贴纸
- `- (void)removeSticker` - 移除贴纸

### VVMStickerDeleteZoneView（删除区域视图）

**功能**：
- 顶部删除区域，显示垃圾桶图标和提示文字
- 贴纸进入删除阈值时高亮动画

**公开方法**：
- `- (void)show` / `- (void)hide` - 显示/隐藏
- `- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated` - 高亮状态

**删除阈值**：距顶部 100pt

## 依赖项

### Masonry
所有 Auto Layout 约束使用 Masonry：

```objc
[view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.equalTo(self);
    make.height.mas_equalTo(80);
}];
```

## 代码模式

### 懒加载
所有自定义视图采用懒加载模式：

```objc
- (UIView *)bottomMaskView {
    if (!_bottomMaskView) {
        _bottomMaskView = [[UIView alloc] init];
        _bottomMaskView.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:0.95];
    }
    return _bottomMaskView;
}
```

### 拖拽手势处理
使用 `UIGestureRecognizerState` 状态机处理拖拽：

```objc
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:     // 开始拖拽
        case UIGestureRecognizerStateChanged:   // 拖拽中
        case UIGestureRecognizerStateEnded:     // 结束拖拽
    }
}
```

## 开发注意事项

1. **拖拽边界限制**：
   - Y 轴：删除区底部 到 底部遮罩顶部
   - X 轴：不超出容器左右边界

2. **删除动画**：
   - 缩放：1.0 → 0.1
   - 透明度：1.0 → 0
   - 时长：0.3 秒

3. **高亮反馈**：
   - 删除区高亮时缩放 1.3 倍
   - 透明度从 0.7 → 1.0
