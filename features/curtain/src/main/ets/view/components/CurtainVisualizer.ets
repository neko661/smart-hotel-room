/**
 * 窗帘可视化组件
 * 根据开合百分比动态显示窗帘状态
 */

@ComponentV2
export struct CurtainVisualizer {
  @Param positionValue: number = 0;
  @Param isScreen: boolean = false;
  @Param visualizerWidth: number = 300;
  @Param visualizerHeight: number = 200;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景窗户
      this.buildWindowBackground();

      // 左侧窗帘
      this.buildLeftCurtain();

      // 右侧窗帘
      this.buildRightCurtain();

      // 顶部横杆
      this.buildTopBar();
    }
    .width(this.visualizerWidth)
    .height(this.visualizerHeight)
  }

  @Builder
  buildWindowBackground() {
    // 窗外背景图
    Image($r('app.media.curtain_window_screening_part_bg'))
      .width('90%')
      .height('85%')
      .objectFit(ImageFit.Cover)
      .position({ x: this.visualizerWidth * 0.05, y: 25 })
      .borderRadius(4)
  }

  @Builder
  buildLeftCurtain() {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.isScreen ?
        (this.positionValue > 50 ?
          $r('app.media.curtain_icon_window_screening_left_part') :
          $r('app.media.curtain_icon_window_screening_left_part_closed')) :
        (this.positionValue > 50 ?
          $r('app.media.curtain_icon_left_part') :
          $r('app.media.curtain_icon_left_closed'))
      )
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .borderRadius({ topRight: 5, bottomRight: 5 })
    }
    .width(this.getLeftCurtainWidth())
    .height(this.visualizerHeight * 0.75)
    .position({ x: 0, y: 25 })
  }

  @Builder
  buildRightCurtain() {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.isScreen ?
        (this.positionValue > 50 ?
          $r('app.media.curtain_icon_window_screening_right_part') :
          $r('app.media.curtain_icon_window_screening_right_part_closed')) :
        (this.positionValue > 50 ?
          $r('app.media.curtain_icon_right_part') :
          $r('app.media.curtain_icon_right_closed'))
      )
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .borderRadius({ topLeft: 5, bottomLeft: 5 })
    }
    .width(this.getRightCurtainWidth())
    .height(this.visualizerHeight * 0.75)
    .position({ x: this.visualizerWidth - this.getRightCurtainWidth(), y: 25 })
  }

  @Builder
  buildTopBar() {
    Image($r('app.media.curtain_icon_top_bar'))
      .width('100%')
      .height(30)
      .objectFit(ImageFit.Fill)
      .position({ x: 0, y: 0 })
  }

  getLeftCurtainWidth(): number {
    const maxLeftWidth: number = this.visualizerWidth * 0.55;
    const minLeftWidth: number = this.visualizerWidth * 0.02;
    const posRatio: number = this.positionValue / 100;
    return maxLeftWidth - posRatio * (maxLeftWidth - minLeftWidth);
  }

  getRightCurtainWidth(): number {
    return this.getLeftCurtainWidth();
  }
}
