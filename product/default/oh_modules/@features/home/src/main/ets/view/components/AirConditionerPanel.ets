/**
 * 空调控制面板组件 - 使用 v2 装饰器
 */
import { HomeViewModel } from '../../viewmodel/HomeViewModel';
import { AirMode, FanSpeed } from '@commons/datastore/src/main/ets/datastore_feature_home/HomeStateManager';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct AirConditionerPanel {
  @Local viewModel: HomeViewModel = new HomeViewModel();

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.home_layer_airconditioner'))
        .width('90%')
        .height(220);

      Column({ space: 12 }) {
        // 第一行：空调开关
        Row({ space: 0 }) {
          Row({ space: 10 }) {
            Image($r('app.media.home_icon_airconditioner'))
              .width(50)
              .height(50);
            Column({ space: 3 }) {
              Text('空调')
                .fontSize(16)
                .fontColor('#FFFFFF');
              Text(this.viewModel.airStatusText)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .opacity(0.7);
            }
          }
          .width('70%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Start);

          Image($r('app.media.home_icon_close'))
            .width(50)
            .height(50)
            .onClick(() => {
              this.viewModel.toggleAirConditioner();
              promptAction.showToast({
                message: this.viewModel.homeData.isAirOn ? '空调已开启' : '空调已关闭'
              });
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 20, right: 30 });

        // 第二行：模式选择
        Row({ space: 8 }) {
          this.ModeButton('自动', AirMode.AUTO)
          this.ModeButton('制冷', AirMode.COOL)
          this.ModeButton('制热', AirMode.HEAT)
          this.ModeButton('除湿', AirMode.DRY)
          this.ModeButton('送风', AirMode.FAN)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ left: 10, right: 10 });

        // 第三行：温度控制
        Row({ space: 0 }) {
          Column({ space: 5 }) {
            Text('温度')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.7);
            Stack({ alignContent: Alignment.Center }) {
              Row()
                .width(35)
                .height(35)
                .backgroundColor('#D4AF37')
                .borderRadius(17);
              Image($r('app.media.home_btn_sub'))
                .width(20)
                .height(20);
            }
            .width(35)
            .height(35)
            .onClick(() => {
              this.viewModel.decreaseTemp();
            });
          }
          .width('25%')
          .alignItems(HorizontalAlign.Center);

          Column({ space: 5 }) {
            Text('设定温度')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .opacity(0.9);
            Text(`${this.viewModel.homeData.setTemp}℃`)
              .fontSize(56)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF');
          }
          .width('50%')
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center);

          Column({ space: 5 }) {
            Text('温度')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .opacity(0.7);
            Stack({ alignContent: Alignment.Center }) {
              Row()
                .width(35)
                .height(35)
                .backgroundColor('#D4AF37')
                .borderRadius(17);
              Image($r('app.media.home_btn_add'))
                .width(20)
                .height(20);
            }
            .width(35)
            .height(35)
            .onClick(() => {
              this.viewModel.increaseTemp();
            });
          }
          .width('25%')
          .alignItems(HorizontalAlign.Center);
        }

        // 第四行：风速控制
        Row({ space: 8 }) {
          Text('风速:')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .opacity(0.8);

          this.FanButton('低速', FanSpeed.LOW)
          this.FanButton('中速', FanSpeed.MEDIUM)
          this.FanButton('高速', FanSpeed.HIGH)
          this.FanButton('自动', FanSpeed.AUTO)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ left: 10, right: 10 });
      }
    }
  }

  @Builder
  ModeButton(label: string, mode: AirMode) {
    Text(label)
      .fontSize(12)
      .fontColor(this.viewModel.homeData.airMode === mode ? '#000000' : '#FFFFFF')
      .backgroundColor(this.viewModel.homeData.airMode === mode ? '#D4AF37' : 'transparent')
      .borderRadius(4)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .onClick(() => {
        this.viewModel.setAirMode(mode);
      });
  }

  @Builder
  FanButton(label: string, speed: FanSpeed) {
    Text(label)
      .fontSize(12)
      .fontColor(this.viewModel.homeData.fanSpeed === speed ? '#000000' : '#FFFFFF')
      .backgroundColor(this.viewModel.homeData.fanSpeed === speed ? '#D4AF37' : 'transparent')
      .borderRadius(4)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .onClick(() => {
        this.viewModel.setFanSpeed(speed);
      });
  }
}
