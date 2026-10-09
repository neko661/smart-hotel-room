/**
 * 按钮组件 - 使用 v2 装饰器
 */
@ComponentV2
export struct AppButton {
  @Param text: string | Resource = '';
  @Param type: 'primary' | 'secondary' | 'text' | 'outline' = 'primary';
  @Param disabled: boolean = false;
  @Param loading: boolean = false;
  @Param buttonSize: 'small' | 'medium' | 'large' = 'medium';
  @Event onTap: () => void = () => {};

  build() {
    Row() {
      if (this.loading) {
        LoadingProgress()
          .width(18)
          .height(18)
          .color(this.getButtonColor())
      } else {
        Text(this.text)
          .fontSize(this.getFontSize())
          .fontColor(this.getTextColor())
          .fontWeight(this.type === 'primary' ? FontWeight.Medium : FontWeight.Normal)
      }
    }
    .width(this.getWidth())
    .height(this.getHeight())
    .backgroundColor(this.getBackgroundColor())
    .border(this.type === 'outline' ? { width: 1, color: this.getButtonColor() } : undefined)
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .opacity(this.disabled ? 0.5 : 1)
    .enabled(!this.disabled && !this.loading)
    .onClick(() => {
      if (!this.disabled && !this.loading) {
        this.onTap();
      }
    })
  }

  private getButtonColor(): ResourceColor {
    switch (this.type) {
      case 'primary':
        return '#D4AF37';
      case 'secondary':
        return '#8B7355';
      case 'text':
      case 'outline':
        return '#333333';
    }
  }

  private getBackgroundColor(): ResourceColor {
    if (this.type === 'text') {
      return Color.Transparent;
    }
    if (this.type === 'outline') {
      return Color.Transparent;
    }
    return this.getButtonColor();
  }

  private getTextColor(): ResourceColor {
    if (this.type === 'primary' || this.type === 'secondary') {
      return Color.White;
    }
    return this.getButtonColor();
  }

  private getWidth(): Length {
    switch (this.buttonSize) {
      case 'small':
        return 80;
      case 'medium':
        return 120;
      case 'large':
        return '100%';
    }
  }

  private getHeight(): Length {
    switch (this.buttonSize) {
      case 'small':
        return 32;
      case 'medium':
        return 40;
      case 'large':
        return 48;
    }
  }

  private getFontSize(): number {
    switch (this.buttonSize) {
      case 'small':
        return 12;
      case 'medium':
        return 14;
      case 'large':
        return 16;
    }
  }
}
