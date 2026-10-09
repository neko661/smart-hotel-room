/**
 * 开关组件 - 使用 v2 装饰器
 */
@ComponentV2
export struct ToggleSwitch {
  @Param isOn: boolean = false;
  @Event onToggle?: () => void = () => {};

  build() {
    Stack({ alignContent: Alignment.Start }) {
      // 背景条 - 带颜色渐变动画
      Row()
        .width(45)
        .height(25)
        .borderRadius(12.5)
        .backgroundColor(this.isOn ? '#D4AF37' : '#666666')
        .animation({
          duration: 250,
          curve: Curve.EaseInOut
        });

      // 滑块 - 带位移动画 + 阴影变化
      Row()
        .width(21)
        .height(21)
        .borderRadius(10.5)
        .backgroundColor('#FFFFFF')
        .margin({ left: this.isOn ? 22 : 2 })
        .shadow({
          radius: this.isOn ? 4 : 2,
          color: 'rgba(0, 0, 0, 0.25)',
          offsetX: 0,
          offsetY: this.isOn ? 2 : 1
        })
        .scale({ x: this.isOn ? 1.05 : 1, y: this.isOn ? 1.05 : 1 })
        .animation({
          duration: 250,
          curve: Curve.EaseInOut
        });
    }
    .width(45)
    .height(25)
    .onClick(() => {
      if (this.onToggle) {
        this.onToggle();
      }
    });
  }
}
