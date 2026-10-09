/**
 * 窗帘控制页面
 */
import { CurtainViewModel } from '@features/curtain/src/main/ets/viewmodel/CurtainViewModel';
import { CurtainVisualizer } from '@features/curtain/src/main/ets/view/components/CurtainVisualizer';
import { CurtainStateManager, CurtainState } from '@commons/datastore/src/main/ets/datastore_feature_device/CurtainStateManager';

const CURTAIN_POSITION_KEY = 'curtainPosition';
const CURTAIN_STATE_KEY = 'curtainState';
const SCREEN_POSITION_KEY = 'screenPosition';
const SCREEN_STATE_KEY = 'screenState';

@ComponentV2
export struct CurtainControlPage {
  @Local viewModel: CurtainViewModel = new CurtainViewModel();
  @Local curtainPosition: number = 0;
  @Local curtainState: CurtainState = new CurtainState();
  @Local screenPosition: number = 0;
  @Local screenState: CurtainState = new CurtainState();
  private syncTimer: number = 0;

  aboutToAppear(): void {
    CurtainStateManager.init();
    this.syncStateFromManager();
    this.startSyncTimer();
  }

  aboutToDisappear(): void {
    this.stopSyncTimer();
  }

  private syncStateFromManager(): void {
    this.curtainPosition = CurtainStateManager.getCurtainPosition();
    this.curtainState = CurtainStateManager.getCurtainState();
    this.screenPosition = CurtainStateManager.getScreenPosition();
    this.screenState = CurtainStateManager.getScreenState();
  }

  private startSyncTimer(): void {
    this.syncTimer = setInterval(() => {
      this.syncStateFromManager();
    }, 100);
  }

  private stopSyncTimer(): void {
    if (this.syncTimer !== 0) {
      clearInterval(this.syncTimer);
      this.syncTimer = 0;
    }
  }

  build() {
    Column({ space: 0 }) {
      // 标题
      Text('窗帘控制')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .margin({ top: 35 })
        .alignSelf(ItemAlign.Center);

      Scroll() {
        Column({ space: 15 }) {
          this.buildControlButtons();
          Column() {
            this.buildCurtainControlPanel();
          }
          .margin({ top: 10 });
          Column() {
            this.buildScreenControlPanel();
          }
          .margin({ top: 10, bottom: 80 });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center);
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);
    }
    .width('100%')
    .height('100%')
    .backgroundImage($r('app.media.curtain_bg'))
    .backgroundImageSize(ImageSize.Cover);
  }

  @Builder
  buildControlButtons() {
    Row({ space: 15 }) {
      Button() {
        Row({ space: 8 }) {
          Image($r('app.media.curtain_icon_open_all'))
            .width(22)
            .height(22);
          Text('全开')
            .fontSize(16)
            .fontColor('#FFFFFF');
        }
        .justifyContent(FlexAlign.Center);
      }
        .width(120)
        .height(50)
        .backgroundColor((this.curtainState.opening || this.screenState.opening) ? '#999999' : '#D4AF37')
        .borderRadius(25)
        .onClick(() => {
          this.viewModel.openAll();
          this.syncStateFromManager();
        });

      Button() {
        Row({ space: 8 }) {
          Image($r('app.media.curtain_icon_close_all'))
            .width(22)
            .height(22);
          Text('全关')
            .fontSize(16)
            .fontColor('#FFFFFF');
        }
        .justifyContent(FlexAlign.Center);
      }
        .width(120)
        .height(50)
        .backgroundColor((this.curtainState.closing || this.screenState.closing) ? '#999999' : '#D4AF37')
        .borderRadius(25)
        .onClick(() => {
          this.viewModel.closeAll();
          this.syncStateFromManager();
        });
    }
    .margin({ top: 30 });
  }

  @Builder
  buildCurtainControlPanel() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.curtain_layer_curtain'))
        .width('90%')
        .height(350);

      Column({ space: 12 }) {
        Column({ space: 10 }) {
          Text('布帘')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .alignSelf(ItemAlign.Start)
            .margin({ left: 20, top: 10 });

          CurtainVisualizer({
            positionValue: this.curtainPosition,
            isScreen: false,
            visualizerWidth: 280,
            visualizerHeight: 180
          })
        }
        .width('100%');

        Column({ space: 10 }) {
          Row() {
            Text(`${Math.round(this.curtainPosition)}%`)
              .fontSize(14)
              .fontColor('#FFFFFF');

            Text(this.curtainState.opening ? '打开中...' :
                  this.curtainState.closing ? '关闭中...' :
                  this.curtainState.paused ? '已暂停' : '停止')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.7);
          }
          .width('90%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ left: '5%' });

          Progress({
            value: this.curtainPosition,
            total: 100,
            type: ProgressType.Linear
          })
            .width('90%')
            .height(8)
            .color('#D4AF37')
            .backgroundColor('rgba(255,255,255,0.2)')
            .margin({ left: '5%' });

          Row({ space: 10 }) {
            Button() {
              Row({ space: 6 }) {
                Image($r('app.media.curtain_icon_open'))
                  .width(18)
                  .height(18);
                Text('打开')
                  .fontSize(14)
                  .fontColor('#FFFFFF');
              }
              .justifyContent(FlexAlign.Center);
            }
              .width(75)
              .height(38)
              .backgroundColor(this.curtainState.opening ? '#999999' : '#D4AF37')
              .borderRadius(20)
              .onClick(() => {
                this.viewModel.openCurtain();
                this.syncStateFromManager();
              });

            Button() {
              Row({ space: 6 }) {
                Image($r('app.media.curtain_icon_pause'))
                  .width(18)
                  .height(18);
                Text('暂停')
                  .fontSize(14)
                  .fontColor('#FFFFFF');
              }
              .justifyContent(FlexAlign.Center);
            }
              .width(75)
              .height(38)
              .backgroundColor(this.curtainState.paused ? '#666666' : '#D4AF37')
              .borderRadius(20)
              .onClick(() => {
                this.viewModel.pauseCurtain();
                this.syncStateFromManager();
              });

            Button() {
              Row({ space: 6 }) {
                Image($r('app.media.curtain_icon_close'))
                  .width(18)
                  .height(18);
                Text('关闭')
                  .fontSize(14)
                  .fontColor('#FFFFFF');
              }
              .justifyContent(FlexAlign.Center);
            }
              .width(75)
              .height(38)
              .backgroundColor(this.curtainState.closing ? '#999999' : '#D4AF37')
              .borderRadius(20)
              .onClick(() => {
                this.viewModel.closeCurtain();
                this.syncStateFromManager();
              });
          }
        }
        .width('90%')
        .margin({ left: '5%' });
      }
    }
    .width('90%')
  }

  @Builder
  buildScreenControlPanel() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.curtain_layer_screen'))
        .width('90%')
        .height(350);

      Column({ space: 12 }) {
        Column({ space: 10 }) {
          Text('窗纱')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .alignSelf(ItemAlign.Start)
            .margin({ left: 20, top: 10 });

          CurtainVisualizer({
            positionValue: this.screenPosition,
            isScreen: true,
            visualizerWidth: 280,
            visualizerHeight: 180
          })
        }
        .width('100%');

        Column({ space: 10 }) {
          Row() {
            Text(`${Math.round(this.screenPosition)}%`)
              .fontSize(14)
              .fontColor('#FFFFFF');

            Text(this.screenState.opening ? '打开中...' :
                  this.screenState.closing ? '关闭中...' :
                  this.screenState.paused ? '已暂停' : '停止')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.7);
          }
          .width('90%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ left: '5%' });

          Progress({
            value: this.screenPosition,
            total: 100,
            type: ProgressType.Linear
          })
            .width('90%')
            .height(8)
            .color('#D4AF37')
            .backgroundColor('rgba(255,255,255,0.2)')
            .margin({ left: '5%' });

          Row({ space: 10 }) {
            Button() {
              Row({ space: 6 }) {
                Image($r('app.media.curtain_icon_open'))
                  .width(18)
                  .height(18);
                Text('打开')
                  .fontSize(14)
                  .fontColor('#FFFFFF');
              }
              .justifyContent(FlexAlign.Center);
            }
              .width(75)
              .height(38)
              .backgroundColor(this.screenState.opening ? '#999999' : '#D4AF37')
              .borderRadius(20)
              .onClick(() => {
                this.viewModel.openScreen();
                this.syncStateFromManager();
              });

            Button() {
              Row({ space: 6 }) {
                Image($r('app.media.curtain_icon_pause'))
                  .width(18)
                  .height(18);
                Text('暂停')
                  .fontSize(14)
                  .fontColor('#FFFFFF');
              }
              .justifyContent(FlexAlign.Center);
            }
              .width(75)
              .height(38)
              .backgroundColor(this.screenState.paused ? '#666666' : '#D4AF37')
              .borderRadius(20)
              .onClick(() => {
                this.viewModel.pauseScreen();
                this.syncStateFromManager();
              });

            Button() {
              Row({ space: 6 }) {
                Image($r('app.media.curtain_icon_close'))
                  .width(18)
                  .height(18);
                Text('关闭')
                  .fontSize(14)
                  .fontColor('#FFFFFF');
              }
              .justifyContent(FlexAlign.Center);
            }
              .width(75)
              .height(38)
              .backgroundColor(this.screenState.closing ? '#999999' : '#D4AF37')
              .borderRadius(20)
              .onClick(() => {
                this.viewModel.closeScreen();
                this.syncStateFromManager();
              });
          }
        }
        .width('90%')
        .margin({ left: '5%' });
      }
    }
    .width('90%')
  }
}
