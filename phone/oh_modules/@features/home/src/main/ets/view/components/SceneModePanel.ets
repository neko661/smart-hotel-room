/**
 * 场景模式面板组件 - 使用 v2 装饰器
 */
import { HomeViewModel, SceneModeItem } from '../../viewmodel/HomeViewModel';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct SceneModePanel {
  @Local viewModel: HomeViewModel = new HomeViewModel();

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.home_layer_scenemode'))
        .width('90%')
        .height(180);

      Column({ space: 15 }) {
        Text('场景模式')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .alignSelf(ItemAlign.Start)
          .margin({ left: 20 });

        Row({ space: 8 }) {
          ForEach(this.viewModel.sceneModes, (mode: SceneModeItem) => {
            Column() {
              this.ModeImage(mode.icon)
              Text(mode.name)
                .fontSize(11)
                .fontColor('#FFFFFF');
            }
            .width(65)
            .height(65)
            .backgroundColor('#D4AF37')
            .borderRadius(8)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.viewModel.setSceneMode(mode.id);
              promptAction.showToast({ message: mode.name + '模式已激活' });
            });
          }, (mode: SceneModeItem) => mode.id);
        }
        .width('90%')
        .justifyContent(FlexAlign.Center);
      }
    }
  }

  @Builder
  ModeImage(iconName: string) {
    if (iconName === 'home_icon_bright') {
      Image($r('app.media.home_icon_bright'))
        .width(35)
        .height(35);
    } else if (iconName === 'home_icon_soft') {
      Image($r('app.media.home_icon_soft'))
        .width(35)
        .height(35);
    } else if (iconName === 'home_icon_read') {
      Image($r('app.media.home_icon_read'))
        .width(35)
        .height(35);
    } else if (iconName === 'home_icon_warm') {
      Image($r('app.media.home_icon_warm'))
        .width(35)
        .height(35);
    } else if (iconName === 'light_icon_sleep_mode') {
      Image($r('app.media.light_icon_sleep_mode'))
        .width(35)
        .height(35);
    }
  }
}
