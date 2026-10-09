/**
 * 加载中组件 - 使用 v2 装饰器
 */
@ComponentV2
export struct AppLoading {
  @Param visible: boolean = false;
  @Param text: string = '加载中...';
  @Param maskColor: string = 'rgba(0, 0, 0, 0.4)';

  build() {
    if (this.visible) {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(this.maskColor)

        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#D4AF37')

          Text(this.text)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 12 })
        }
        .padding(24)
        .borderRadius(12)
        .backgroundColor('#FFFFFF')
      }
      .width('100%')
      .height('100%')
      .zIndex(1000)
    }
  }
}
