/**
 * 应用标题栏组件 - 使用 v2 装饰器
 */
@ComponentV2
export struct AppTitleBar {
  @Param title: string = '';
  @Param showBack: boolean = false;
  @Param bgColor: string = '#FFFFFF';
  @Param textColor: string = '#333333';
  onBackClick: () => void = () => {};
  onMenuClick: () => void = () => {};

  build() {
    Row() {
      if (this.showBack) {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24)
          .height(24)
          .fillColor(this.textColor)
          .margin({ left: 16, right: 8 })
          .onClick(() => {
            this.onBackClick();
          })
      }

      Text(this.title)
        .fontSize(18)
        .fontColor(this.textColor)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Row()
        .width(40)
        .onClick(() => {
          this.onMenuClick();
        })
    }
    .width('100%')
    .height(56)
    .backgroundColor(this.bgColor)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}
