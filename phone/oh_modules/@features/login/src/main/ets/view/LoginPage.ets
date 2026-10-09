/**
 * 登录页面 - 使用 v2 装饰器
 */
import { AuthViewModel } from '../viewmodel/AuthViewModel';
import { promptAction } from '@kit.ArkUI';
import { PreferencesUtil } from '@commons/datastore/src/main/ets/datastore_base/PreferencesUtil';
import { UserManager, OperationResult } from '@commons/datastore/src/main/ets/datastore_user/UserManager';

export interface LoginParams {
  navigateToHome?: () => void;
}

@ComponentV2
export struct LoginPage {
  @Local viewModel: AuthViewModel = new AuthViewModel();
  @Local rememberMe: boolean = false;
  @Local isPasswordVisible: boolean = false;
  @Local isLoginLoading: boolean = false;
  @Local isRoomNoFocused: boolean = false;
  @Local isPasswordFocused: boolean = false;
  @Local showResetDialog: boolean = false;
  @Local resetRoomNo: string = '';
  @Local securityQuestion: string = '';
  @Local securityAnswer: string = '';
  @Local newPassword: string = '';
  @Local confirmNewPassword: string = '';
  @Local isResetting: boolean = false;
  @Event navigateToHome: () => void = () => {};

  aboutToAppear(): void {
    this.loadRememberMeStatus();
    this.initializeUsers();
  }

  async loadRememberMeStatus(): Promise<void> {
    try {
      const remembered = await PreferencesUtil.get('rememberMe', false) as boolean;
      this.rememberMe = remembered;
      this.viewModel.authData.rememberMe = this.rememberMe;
    } catch {
      this.rememberMe = false;
    }
  }

  async initializeUsers(): Promise<void> {
    await UserManager.initializeDefaultUsers();
  }

  async handleLogin(): Promise<void> {
    if (this.isLoginLoading) {
      return;
    }

    if (!this.viewModel.authData.roomNo) {
      promptAction.showToast({ message: '请输入客房号' });
      return;
    }

    if (!this.viewModel.authData.password) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }

    if (this.viewModel.authData.password.length < 4) {
      promptAction.showToast({ message: '密码长度至少4位' });
      return;
    }

    if (!/^\d{4}$/.test(this.viewModel.authData.roomNo)) {
      promptAction.showToast({ message: '客房号必须是4位数字' });
      return;
    }

    this.isLoginLoading = true;

    try {
      const success = await this.viewModel.login();
      if (success && this.navigateToHome) {
        this.navigateToHome();
      }
    } catch {
      promptAction.showToast({ message: '登录失败，请重试' });
    } finally {
      this.isLoginLoading = false;
    }
  }

  toggleRememberMe(): void {
    this.rememberMe = !this.rememberMe;
    this.viewModel.authData.rememberMe = this.rememberMe;
    PreferencesUtil.put('rememberMe', this.rememberMe);
  }

  async openResetDialog(): Promise<void> {
    this.resetRoomNo = this.viewModel.authData.roomNo;
    this.securityQuestion = '';
    this.securityAnswer = '';
    this.newPassword = '';
    this.confirmNewPassword = '';

    if (!this.resetRoomNo || !/^\d{4}$/.test(this.resetRoomNo)) {
      promptAction.showToast({ message: '请先输入正确的客房号' });
      return;
    }

    const roomExists = await this.viewModel.checkRoomExists(this.resetRoomNo);
    if (!roomExists) {
      promptAction.showToast({ message: '该客房号不存在' });
      return;
    }

    const hasQuestion = await this.viewModel.hasSecurityQuestion(this.resetRoomNo);
    if (hasQuestion) {
      const question: string | null = await this.viewModel.getSecurityQuestion(this.resetRoomNo);
      this.securityQuestion = question || '';
    } else {
      this.securityQuestion = '该账户未设置密保问题，请联系前台重置密码';
    }

    this.showResetDialog = true;
  }

  async handleResetPassword(): Promise<void> {
    if (this.isResetting) {
      return;
    }

    if (!this.securityAnswer) {
      promptAction.showToast({ message: '请输入密保答案' });
      return;
    }

    if (!this.newPassword || this.newPassword.length < 4) {
      promptAction.showToast({ message: '新密码长度至少4位' });
      return;
    }

    if (this.newPassword !== this.confirmNewPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' });
      return;
    }

    this.isResetting = true;

    try {
      const result: OperationResult = await this.viewModel.resetPassword(this.resetRoomNo, this.newPassword, this.securityAnswer);
      if (result.success) {
        promptAction.showToast({ message: result.message });
        this.showResetDialog = false;
      } else {
        promptAction.showToast({ message: result.message });
      }
    } catch {
      promptAction.showToast({ message: '密码重置失败，请重试' });
    } finally {
      this.isResetting = false;
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.bg_hotel_full'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover);

      Column({ space: 20 }) {
        Column({ space: 10 }) {
          Text('智慧客房')
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor('#D4AF37')
            .margin({ top: 60 });

          Text('广科·未来酒店')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ bottom: 10 });

          Text('华为ICT学院专属智慧客房体验')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .opacity(0.8);
        }

        Column({ space: 15 }) {
          // 房号输入
          Stack({ alignContent: Alignment.Center }) {
            Image(this.isRoomNoFocused ? $r('app.media.icon_input_checked') : $r('app.media.icon_input_unchecked'))
              .width(40)
              .height(40)
              .margin({ left: 15 });

            TextInput({ placeholder: '请输入客房号', text: this.viewModel.authData.roomNo })
              .width(300)
              .height(48)
              .backgroundColor('#FFFFFF')
              .borderRadius(24)
              .padding({ left: 55 })
              .placeholderColor('#999999')
              .fontSize(16)
              .type(InputType.Number)
              .maxLength(4)
              .onFocus(() => { this.isRoomNoFocused = true; })
              .onBlur(() => { this.isRoomNoFocused = false; })
              .onChange((value: string) => { this.viewModel.updateRoomNo(value); });

            Image($r('app.media.icon_input_room'))
              .width(24)
              .height(24)
              .margin({ right: 15 })
              .alignSelf(ItemAlign.End);
          }
          .width(300)
          .height(48)
          .backgroundColor('#FFFFFF')
          .borderRadius(24);

          // 密码输入
          Stack({ alignContent: Alignment.Center }) {
            Image(this.isPasswordFocused ? $r('app.media.icon_input_checked') : $r('app.media.icon_input_unchecked'))
              .width(40)
              .height(40)
              .margin({ left: 15 });

            TextInput({ placeholder: '请输入密码', text: this.viewModel.authData.password })
              .width(300)
              .height(48)
              .backgroundColor('#FFFFFF')
              .borderRadius(24)
              .padding({ left: 55 })
              .placeholderColor('#999999')
              .fontSize(16)
              .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
              .maxLength(20)
              .onFocus(() => { this.isPasswordFocused = true; })
              .onBlur(() => { this.isPasswordFocused = false; })
              .onChange((value: string) => { this.viewModel.updatePassword(value); });

            Image($r('app.media.icon_input_checked'))
              .width(24)
              .height(24)
              .margin({ right: 15 })
              .alignSelf(ItemAlign.End)
              .opacity(0.6)
              .onClick(() => {
                this.isPasswordVisible = !this.isPasswordVisible;
              });
          }
          .width(300)
          .height(48)
          .backgroundColor('#FFFFFF')
          .borderRadius(24);

          // 记住我 和 忘记密码
          Row({ space: 10 }) {
            Row({ space: 10 }) {
              Image(this.rememberMe ? $r('app.media.icon_input_checked') : $r('app.media.icon_input_unchecked'))
                .width(24)
                .height(24)
                .onClick(() => {
                  this.toggleRememberMe();
                });

              Text('记住我')
                .fontSize(14)
                .fontColor('#FFFFFF');
            }

            Blank()
              .layoutWeight(1)

            Text('忘记密码？')
              .fontSize(14)
              .fontColor('#D4AF37')
              .onClick(() => {
                this.openResetDialog();
              });
          }
          .width(300)
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: 10 });

          // 登录按钮
          Button(this.isLoginLoading ? '登录中...' : '立即入住')
            .width(300)
            .height(48)
            .backgroundColor(this.isLoginLoading ? '#999999' : '#D4AF37')
            .borderRadius(24)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 20 })
            .enabled(!this.isLoginLoading)
            .onClick(() => {
              this.handleLogin();
            });
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center);

        // 底部欢迎语
        Column({ space: 5 }) {
          Text('欢迎回家，尽享未来科技之旅')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .opacity(0.6);
        }
        .margin({ top: 60 });
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center);
    }
    .width('100%')
    .height('100%')
    .bindContentCover(this.showResetDialog, this.buildResetDialog(), {
      modalTransition: ModalTransition.DEFAULT
    });
  }

  @Builder
  buildResetDialog() {
    Column() {
      Column() {
        Text('重置密码')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 20 });

        Column({ space: 15 }) {
          Text(`客房号：${this.resetRoomNo}`)
            .fontSize(16)
            .fontColor('#666666')
            .width('100%');

          if (this.securityQuestion) {
            Column({ space: 8 }) {
              Text(this.securityQuestion)
                .fontSize(14)
                .fontColor('#666666')
                .width('100%');

              TextInput({ placeholder: '请输入密保答案', text: this.securityAnswer })
                .width('100%')
                .height(44)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .padding({ left: 12 })
                .onChange((value: string) => {
                  this.securityAnswer = value;
                });
            }
            .width('100%');
          }

          Column({ space: 8 }) {
            Text('新密码')
              .fontSize(14)
              .fontColor('#666666')
              .width('100%');

            TextInput({ placeholder: '请输入新密码（至少4位）', text: this.newPassword })
              .width('100%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding({ left: 12 })
              .type(InputType.Password)
              .onChange((value: string) => {
                this.newPassword = value;
              });
          }
          .width('100%');

          Column({ space: 8 }) {
            Text('确认新密码')
              .fontSize(14)
              .fontColor('#666666')
              .width('100%');

            TextInput({ placeholder: '请再次输入新密码', text: this.confirmNewPassword })
              .width('100%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding({ left: 12 })
              .type(InputType.Password)
              .onChange((value: string) => {
                this.confirmNewPassword = value;
              });
          }
          .width('100%');
        }
        .width('100%')
        .margin({ bottom: 20 });

        Row({ space: 10 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .fontSize(16)
            .fontColor('#666666')
            .onClick(() => {
              this.showResetDialog = false;
            });

          Button(this.isResetting ? '重置中...' : '确认重置')
            .layoutWeight(1)
            .height(44)
            .backgroundColor('#D4AF37')
            .borderRadius(8)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .enabled(!this.isResetting)
            .onClick(() => {
              this.handleResetPassword();
            });
        }
        .width('100%');
      }
      .width(320)
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 10, color: '#1F000000', offsetY: 0 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .justifyContent(FlexAlign.Center);
  }
}
