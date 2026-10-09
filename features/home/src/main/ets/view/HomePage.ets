/**
 * 首页 - 智慧客房主页面 - 匹配参考设计
 */
import { HomeStateManager } from '@commons/datastore/src/main/ets/datastore_feature_home/HomeStateManager';
import { LightStateManager } from '@commons/datastore/src/main/ets/datastore_feature_device/LightStateManager';
import { SessionManager } from '@commons/datastore/src/main/ets/datastore_app/SessionManager';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct HomePage {
  @Local currentTemp: number = 20;
  @Local setTemp: number = 22;
  @Local isAirOn: boolean = false;
  @Local roomNo: string = '0001';
  @Local guestName: string = '客人';

  aboutToAppear(): void {
    HomeStateManager.init();
    this.loadUserInfo();
    this.syncStateFromManager();
  }

  loadUserInfo(): void {
    const session = SessionManager.getSession();
    if (session) {
      this.roomNo = session.roomNo || '0001';
      this.guestName = session.userName || '客人';
    }
  }

  syncStateFromManager(): void {
    this.currentTemp = HomeStateManager.getCurrentTemp();
    this.setTemp = HomeStateManager.getSetTemp();
    this.isAirOn = HomeStateManager.isAirOn();
  }

  build() {
    Column({ space: 0 }) {
      // 头部
      this.buildHeader();

      Scroll() {
        Column({ space: 12 }) {
          // 空调面板
          this.buildAirPanel();

          // 场景模式
          this.buildSceneModePanel();

          // 快捷服务
          this.buildQuickServicePanel();

          // 晚安模式
          this.buildNightModePanel();
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
    .backgroundImage($r('app.media.home_background'))
    .backgroundImageSize(ImageSize.Cover);
  }

  // ==================== 头部 ====================
  @Builder
  buildHeader() {
    Row({ space: 0 }) {
      Column({ space: 2 }) {
        Text('智慧客房')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF');
        Text('欢迎回家，房号 ' + this.roomNo)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .opacity(0.8);
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

      Text(this.guestName)
        .fontSize(15)
        .fontColor('#FFFFFF')
        .opacity(0.9)
        .margin({ right: 5 });
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 20, right: 15 })
    .margin({ top: 35 });
  }

  // ==================== 空调面板 ====================
  @Builder
  buildAirPanel() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.home_layer_airconditioner'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .borderRadius(12);

      Column({ space: 14 }) {
        // 第一行：空调状态 + 电源按钮
        Row({ space: 0 }) {
          Row({ space: 10 }) {
            Image($r('app.media.home_icon_airconditioner'))
              .width(42)
              .height(42);
            Column({ space: 2 }) {
              Text('空调')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF');
              Text(this.isAirOn ? '运行中' : '已关闭')
                .fontSize(12)
                .fontColor('#FFFFFF')
                .opacity(0.75);
            }
            .alignItems(HorizontalAlign.Start);
          }
          .layoutWeight(1);

          Image($r('app.media.home_icon_close'))
            .width(48)
            .height(48)
            .shadow({
              radius: this.isAirOn ? 20 : 6,
              color: this.isAirOn ? 'rgba(212, 175, 55, 0.7)' : 'rgba(0,0,0,0.3)',
              offsetX: 0,
              offsetY: 4
            })
            .animation({ duration: 300, curve: Curve.EaseInOut })
            .onClick(() => {
              this.isAirOn = !this.isAirOn;
              HomeStateManager.setAirOn(this.isAirOn);
              promptAction.showToast({ message: this.isAirOn ? '空调已开启' : '空调已关闭' });
            });
        }
        .width('100%');

        // 第二行：温度控制
        Row({ space: 0 }) {
          // 左：当前温度
          Column({ space: 6 }) {
            Text('当前温度')
              .fontSize(11)
              .fontColor('#FFFFFF')
              .opacity(0.75);
            Image($r('app.media.home_btn_sub'))
              .width(46)
              .height(46)
              .onClick(() => {
                this.setTemp = HomeStateManager.decreaseTemp();
                promptAction.showToast({ message: '设定温度：' + this.setTemp + '°C' });
              });
          }
          .width('30%')
          .alignItems(HorizontalAlign.Center);

          // 中：设定温度大字
          Column({ space: 6 }) {
            Text('设定温度')
              .fontSize(11)
              .fontColor('#FFFFFF')
              .opacity(0.75);
            Text(`${this.setTemp}℃`)
              .fontSize(44)
              .fontWeight(FontWeight.Bold)
              .fontColor('#D4AF37');
          }
          .width('40%')
          .alignItems(HorizontalAlign.Center);

          // 右：加号
          Column({ space: 6 }) {
            Text('')
              .fontSize(11);
            Image($r('app.media.home_btn_add'))
              .width(46)
              .height(46)
              .onClick(() => {
                this.setTemp = HomeStateManager.increaseTemp();
                promptAction.showToast({ message: '设定温度：' + this.setTemp + '°C' });
              });
          }
          .width('30%')
          .alignItems(HorizontalAlign.Center);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      }
      .width('100%')
      .padding(18);
    }
    .width('100%')
    .height(180)
    .margin({ top: 10 });
  }

  // ==================== 场景模式 ====================
  @Builder
  buildSceneModePanel() {
    Column({ space: 10 }) {
      Text('场景模式')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .alignSelf(ItemAlign.Start);

      Row({ space: 10 }) {
        this.buildSceneBtn('明亮模式', 'home_icon_bright', 'bright');
        this.buildSceneBtn('柔和模式', 'home_icon_warm', 'soft');
      }
      .width('100%');

      Row({ space: 10 }) {
        this.buildSceneBtn('阅读模式', 'home_icon_read', 'read');
        this.buildSceneBtn('温馨模式', 'home_icon_warm', 'warm');
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
      Image($r('app.media.home_layer_scenemode'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .borderRadius(12);

      Row({ space: 10 }) {
        Image($r(`app.media.${icon}`))
          .width(32)
          .height(32);
        Text(name)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium);
      }
      .padding({ left: 18 })
    }
    .width('48%')
    .height(52)
    .onClick(() => {
      LightStateManager.setSceneMode(mode);
      promptAction.showToast({ message: name + '已激活' });
    });
  }

  // ==================== 快捷服务 ====================
  @Builder
  buildQuickServicePanel() {
    Column({ space: 10 }) {
      Text('快捷服务')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .alignSelf(ItemAlign.Start);

      Row({ space: 10 }) {
        this.buildServiceBtn('请勿打扰', 'home_icon_undisturb');
        this.buildServiceBtn('清理房间', 'service_icon_clean_room');
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
  buildServiceBtn(name: string, icon: string) {
    Stack({ alignContent: Alignment.Start }) {
      Image($r('app.media.home_layer_scenemode'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .borderRadius(12);

      Row({ space: 10 }) {
        Image($r(`app.media.${icon}`))
          .width(32)
          .height(32);
        Text(name)
          .fontSize(15)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium);
      }
      .padding({ left: 18 })
    }
    .width('48%')
    .height(52)
    .onClick(() => {
      promptAction.showToast({ message: name + '已请求' });
    });
  }

  // ==================== 晚安模式 ====================
  @Builder
  buildNightModePanel() {
    Stack({ alignContent: Alignment.Start }) {
      Image($r('app.media.home_layer_night'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .borderRadius(12);

      Row({ space: 15 }) {
        Row({ space: 12 }) {
          Image($r('app.media.home_icon_night_left'))
            .width(36)
            .height(36);
          Column({ space: 2 }) {
            Text('晚安模式')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
            Text('一键关闭所有灯光')
              .fontSize(11)
              .fontColor('#FFFFFF')
              .opacity(0.7);
          }
          .alignItems(HorizontalAlign.Start);
        }
        .layoutWeight(1);

        Image($r('app.media.home_icon_night_right'))
          .width(28)
          .height(28);
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 16, bottom: 16 });
    }
    .width('100%')
    .height(62)
    .margin({ top: 5 })
    .onClick(() => {
      HomeStateManager.activateNightMode();
      this.syncStateFromManager();
      promptAction.showToast({ message: '晚安模式已激活' });
    });
  }
}
