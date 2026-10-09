/**
 * 客房服务控制页面 - 使用 v2 装饰器
 */
import { ServiceViewModel } from '../viewmodel/ServiceViewModel';
import { ServiceStateManager } from '@commons/datastore/src/main/ets/datastore_service/ServiceStateManager';
import { SessionManager } from '@commons/datastore/src/main/ets/datastore_app/SessionManager';
import { ToggleSwitch } from '@commons/uicomponents/src/main/ets/basic_btn_input/ToggleSwitch';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct ServiceControlPage {
  @Local viewModel: ServiceViewModel = new ServiceViewModel();
  @Local doNotDisturb: boolean = false;
  @Local cleanRoom: boolean = false;
  @Event onLogout: () => void = () => {};

  aboutToAppear(): void {
    ServiceStateManager.init();
    this.doNotDisturb = ServiceStateManager.getDoNotDisturb();
    this.cleanRoom = ServiceStateManager.getCleanRoom();
  }

  toggleDoNotDisturb(): void {
    this.doNotDisturb = !this.doNotDisturb;
    ServiceStateManager.setDoNotDisturb(this.doNotDisturb);
    promptAction.showToast({ message: this.doNotDisturb ? '请勿打扰已开启' : '请勿打扰已关闭' });
  }

  toggleCleanRoom(): void {
    this.cleanRoom = !this.cleanRoom;
    ServiceStateManager.setCleanRoom(this.cleanRoom);
    promptAction.showToast({ message: this.cleanRoom ? '清理房间已请求' : '清理请求已取消' });
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image($r('app.media.service_bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover);

      Column({ space: 0 }) {
        // 标题
        Text('服务控制')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ top: 35 })
          .alignSelf(ItemAlign.Center);

        Scroll() {
          Column({ space: 15 }) {
            Row({ space: 15 }) {
              DoNotDisturbToggle()
              CleanRoomToggle()
            }
            .width('90%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 30 });

            Column() {
              this.buildSosButton();
            }
            .margin({ top: 10 });

            Column() {
              this.buildLogoutButton();
            }
            .margin({ top: 20, bottom: 20 });
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center);
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off);
      }
      .width('100%')
      .height('100%');
    }
    .width('100%')
    .height('100%');
  }

  @Builder
  buildSosButton() {
    Row({ space: 10 }) {
      Image($r('app.media.service_icon_do_not_disturb'))
        .width(40)
        .height(40);

      Text('SOS')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#000000');
    }
    .width('90%')
    .height(80)
    .backgroundColor('#FF4444')
    .borderRadius(15)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.showSosDialog();
    });
  }

  showSosDialog(): void {
    promptAction.showDialog({
      title: '紧急呼叫',
      message: '确定要发送SOS紧急呼叫吗？\n这将立即通知前台工作人员。',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '确定呼叫', color: '#FF4444' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        ServiceStateManager.sosCall();
      }
    });
  }

  @Builder
  buildLogoutButton() {
    Text('退出登录')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .width('90%')
      .height(70)
      .backgroundColor('#8B0000')
      .borderRadius(35)
      .textAlign(TextAlign.Center)
      .lineHeight(70)
      .onClick(() => {
        this.showLogoutDialog();
      });
  }

  showLogoutDialog(): void {
    promptAction.showDialog({
      title: '退出登录',
      message: '确定要退出登录吗？',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '确定', color: '#D4AF37' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        SessionManager.clearSession();
        promptAction.showToast({ message: '已退出登录' });
        if (this.onLogout) {
          this.onLogout();
        }
      }
    });
  }
}

@ComponentV2
struct DoNotDisturbToggle {
  @Local isOn: boolean = false;

  aboutToAppear(): void {
    this.isOn = ServiceStateManager.getDoNotDisturb();
  }

  build() {
    Column({ space: 10 }) {
      Image($r('app.media.service_icon_do_not_disturb'))
        .width(50)
        .height(50)
        .opacity(this.isOn ? 1 : 0.7);

      Text('请勿打扰')
        .fontSize(14)
        .fontColor(this.isOn ? '#D4AF37' : '#FFFFFF')
        .fontWeight(this.isOn ? FontWeight.Bold : FontWeight.Normal);

      ToggleSwitch({
        isOn: this.isOn,
        onToggle: () => {
          ServiceStateManager.toggleDoNotDisturb();
          this.isOn = ServiceStateManager.getDoNotDisturb();
        }
      })
    }
    .width(150)
    .height(150)
    .backgroundColor(this.isOn ? 'rgba(212, 175, 55, 0.6)' : 'rgba(212, 175, 55, 0.3)')
    .borderRadius(15)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      ServiceStateManager.toggleDoNotDisturb();
      this.isOn = ServiceStateManager.getDoNotDisturb();
    });
  }
}

@ComponentV2
struct CleanRoomToggle {
  @Local isOn: boolean = false;

  aboutToAppear(): void {
    this.isOn = ServiceStateManager.getCleanRoom();
  }

  build() {
    Column({ space: 10 }) {
      Image($r('app.media.service_icon_clean_room'))
        .width(50)
        .height(50)
        .opacity(this.isOn ? 1 : 0.7);

      Text('清理房间')
        .fontSize(14)
        .fontColor(this.isOn ? '#D4AF37' : '#FFFFFF')
        .fontWeight(this.isOn ? FontWeight.Bold : FontWeight.Normal);

      ToggleSwitch({
        isOn: this.isOn,
        onToggle: () => {
          ServiceStateManager.toggleCleanRoom();
          this.isOn = ServiceStateManager.getCleanRoom();
        }
      })
    }
    .width(150)
    .height(150)
    .backgroundColor(this.isOn ? 'rgba(212, 175, 55, 0.6)' : 'rgba(212, 175, 55, 0.3)')
    .borderRadius(15)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      ServiceStateManager.toggleCleanRoom();
      this.isOn = ServiceStateManager.getCleanRoom();
    });
  }
}
