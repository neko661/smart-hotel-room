/**
 * 晚安模式面板组件 - 使用 v2 装饰器
 */
import { HomeViewModel } from '../../viewmodel/HomeViewModel';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct NightModePanel {
  @Local viewModel: HomeViewModel = new HomeViewModel();

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.home_layer_night'))
        .width('90%')
        .height(70);

      Row({ space: 10 }) {
        Image($r('app.media.home_icon_night_left'))
          .width(20)
          .height(20);

        Text('晚安模式')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF');

        Image($r('app.media.home_icon_night_right'))
          .width(20)
          .height(20);
      }
      .onClick(() => {
        this.viewModel.activateNightMode();
        promptAction.showToast({ message: '晚安模式已激活' });
      });
    }
  }
}
