/**
 * 灯光控制页面 - 匹配参考设计
 */
import { promptAction } from '@kit.ArkUI';
import { LightStateManager } from '@commons/datastore/src/main/ets/datastore_feature_device/LightStateManager';

@ComponentV2
export struct LightControlPage {
  @Local isAllOn: boolean = false;
  @Local lightSwitches: boolean[] = [false, false, false, false, false, false, false, false, false];
  @Local _isPressed: boolean = false;
  private syncTimer: number = -1;

  aboutToAppear(): void {
    LightStateManager.init();
    this.syncStateFromManager();
    this.syncTimer = setInterval(() => {
      this.syncStateFromManager();
    }, 200);
  }

  aboutToDisappear(): void {
    if (this.syncTimer !== -1) {
      clearInterval(this.syncTimer);
      this.syncTimer = -1;
    }
  }

  syncStateFromManager(): void {
    this.lightSwitches = LightStateManager.getSwitches();
    this.isAllOn = this.lightSwitches.some((s: boolean): boolean => s === true);
  }

  build() {
    Column({ space: 0 }) {
      // 标题
      Text('灯光控制')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ top: 35 })
        .alignSelf(ItemAlign.Center);

      Scroll() {
        Column({ space: 15 }) {
          // 总开关面板
          this.buildMasterPanel();

          // 场景模式面板
          this.buildSceneModePanel();

          // 独立控制面板
          this.buildIndependentControlPanel();
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 80 });
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.light_bg'))
    .backgroundImageSize(ImageSize.Cover);
  }

  // ==================== 总开关 ====================
  @Builder
  buildMasterPanel() {
    Column({ space: 12 }) {
      Stack({ alignContent: Alignment.Center }) {
        // 开关按钮 - 清晰可见
        Image($r('app.media.light_btn_main_switch'))
          .width(82)
          .height(82)
          .scale({ x: this._isPressed ? 0.90 : 1, y: this._isPressed ? 0.90 : 1 })
          .translate({ y: this._isPressed ? 4 : 0 })
          .shadow({
            radius: this.isAllOn ? 25 : 8,
            color: this.isAllOn ? 'rgba(255, 200, 50, 0.7)' : 'rgba(0, 0, 0, 0.25)',
            offsetX: 0,
            offsetY: this.isAllOn ? 5 : 3
          })
          .animation({ duration: 120, curve: Curve.EaseOut })
          .onClick(() => {
            this._isPressed = true;
            setTimeout(() => {
              this._isPressed = false;
              for (let i: number = 0; i < this.lightSwitches.length; i++) {
                LightStateManager.toggleLight(i);
              }
              this.syncStateFromManager();
            }, 150);
          });
      }
      .width('100%')
      .height(150);

      Text(this.isAllOn ? '总开关 - 开启' : '总开关 - 关闭')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .opacity(0.9);
    }
    .width('100%')
    .padding({ top: 18, bottom: 18 })
    .backgroundColor(this.isAllOn ? 'rgba(255, 210, 60, 0.14)' : 'rgba(212, 175, 55, 0.10)')
    .borderRadius(12)
    .borderWidth(1)
    .borderColor(this.isAllOn ? 'rgba(255, 215, 80, 0.4)' : 'rgba(212, 175, 55, 0.25)')
    .margin({ top: 10 })
    .animation({ duration: 400, curve: Curve.EaseOut });
  }

  // ==================== 场景模式 ====================
  @Builder
  buildSceneModePanel() {
    Column({ space: 12 }) {
      Text('场景模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .alignSelf(ItemAlign.Start);

      Row({ space: 12 }) {
        this.buildSceneBtn('明亮模式', 'light_icon_bright_mode', 'bright');
        this.buildSceneBtn('柔和模式', 'light_icon_soft', 'soft');
      }
      .width('100%');

      Row({ space: 12 }) {
        this.buildSceneBtn('阅读模式', 'light_icon_read_mode', 'read');
        this.buildSceneBtn('温馨模式', 'light_icon_warm_mode', 'warm');
      }
      .width('100%');

      Row({ space: 12 }) {
        this.buildSceneBtn('睡眠模式', 'light_icon_sleep_mode', 'sleep');
      }
      .width('100%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor('rgba(212, 175, 55, 0.25)')
    .borderRadius(12)
    .margin({ top: 5 });
  }

  @Builder
  buildSceneBtn(name: string, icon: string, mode: string) {
    Stack({ alignContent: Alignment.Start }) {
      Image($r('app.media.light_btn_mode_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .borderRadius(12);

      Row({ space: 10 }) {
        Image($r(`app.media.${icon}`))
          .width(26)
          .height(26);
        Text(name)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium);
      }
      .padding({ left: 18 });
    }
    .width('48%')
    .height(52)
    .onClick(() => {
      LightStateManager.setSceneMode(mode);
      this.syncStateFromManager();
      promptAction.showToast({ message: name + '已激活' });
    });
  }

  @Builder
  buildSceneBtnFull(name: string, icon: string, mode: string) {
    Stack({ alignContent: Alignment.Start }) {
      Image($r('app.media.light_btn_mode_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .borderRadius(12);

      Row({ space: 10 }) {
        Image($r(`app.media.${icon}`))
          .width(26)
          .height(26);
        Text(name)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium);
      }
      .padding({ left: 18 });
    }
    .width('100%')
    .height(52)
    .onClick(() => {
      LightStateManager.setSceneMode(mode);
      this.syncStateFromManager();
      promptAction.showToast({ message: name + '已激活' });
    });
  }

  // ==================== 独立控制 ====================
  @Builder
  buildIndependentControlPanel() {
    Column({ space: 12 }) {
      Text('独立控制')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .alignSelf(ItemAlign.Start);

      Row({ space: 12 }) {
        this.buildLightItem('light_icon_washroom', '洗漱间', 0);
        this.buildLightItem('light_icon_wardrobe', '衣柜灯', 1);
      }
      .width('100%');

      Row({ space: 12 }) {
        this.buildLightItem('light_icon_bar_lamp', '落地灯', 2);
        this.buildLightItem('light_icon_bar_lamp', '吧灯', 3);
      }
      .width('100%');

      Row({ space: 12 }) {
        this.buildLightItem('light_icon_right_left_desk_read', '书桌灯', 4);
        this.buildLightItem('light_icon_right_left_desk_read', '右阅读', 5);
      }
      .width('100%');

      Row({ space: 12 }) {
        this.buildLightItem('light_icon_right_left_desk_read', '左阅读', 6);
        this.buildLightItem('light_icon_exhaust_fan', '排风扇', 7);
      }
      .width('100%');

      Row({ space: 12 }) {
        this.buildLightItem('light_icon_corrid_lights', '廊灯', 8);
      }
      .width('100%');
    }
    .width('100%')
    .padding(18)
    .backgroundColor('rgba(212, 175, 55, 0.25)')
    .borderRadius(12)
    .margin({ top: 5 });
  }

  @Builder
  buildLightItem(icon: string, name: string, index: number) {
    Row({ space: 10 }) {
      Row({ space: 8 }) {
        Image($r(`app.media.${icon}`))
          .width(26)
          .height(26);
        Text(name)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .opacity(0.9);
      }
      .layoutWeight(1);

      // Toggle 开关
      Stack({ alignContent: this.lightSwitches[index] ? Alignment.End : Alignment.Start }) {
        Row()
          .width(44)
          .height(24)
          .borderRadius(12)
          .backgroundColor(this.lightSwitches[index] ? '#D4AF37' : 'rgba(180, 160, 120, 0.6)')
          .animation({ duration: 250, curve: Curve.EaseInOut });

        Column()
          .width(20)
          .height(20)
          .borderRadius(10)
          .backgroundColor('#FFFFFF')
          .margin({ left: this.lightSwitches[index] ? 2 : 2, right: this.lightSwitches[index] ? 2 : 2 })
          .shadow({
            radius: 4,
            color: 'rgba(0, 0, 0, 0.15)',
            offsetX: 0,
            offsetY: 1
          })
          .animation({ duration: 250, curve: Curve.EaseInOut });
      }
      .width(44)
      .height(24)
      .onClick(() => {
        LightStateManager.toggleLight(index);
        this.syncStateFromManager();
      });
    }
    .width('48%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('rgba(212, 175, 55, 0.15)')
    .borderRadius(10);
  }
}
