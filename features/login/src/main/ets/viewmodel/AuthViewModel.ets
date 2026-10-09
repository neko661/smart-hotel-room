/**
 * 登录视图模型
 */
import { AuthData } from '../model/AuthData';
import { promptAction } from '@kit.ArkUI';
import { SessionManager } from '@commons/datastore/src/main/ets/datastore_app/SessionManager';
import { PreferencesUtil } from '@commons/datastore/src/main/ets/datastore_base/PreferencesUtil';
import { UserManager, OperationResult, ResetPasswordQuestion } from '@commons/datastore/src/main/ets/datastore_user/UserManager';

export class AuthViewModel {
  authData: AuthData = new AuthData();
  isRoomNoFocused: boolean = false;
  isPasswordFocused: boolean = false;

  async login(): Promise<boolean> {
    if (!this.authData.validate()) {
      const missingFields: string[] = [];
      if (!this.authData.roomNo) missingFields.push('客房号');
      if (!this.authData.password) missingFields.push('密码');
      promptAction.showToast({ message: '请输入' + missingFields.join('和') });
      return false;
    }

    try {
      const result: OperationResult = await this.authData.verifyCredentials();
      if (!result.success) {
        promptAction.showToast({ message: result.message });
        return false;
      }

      this.authData.saveLoginInfo();
      this.authData.isLoggedIn = true;

      console.info('Login successful, roomNo:', this.authData.roomNo);
      promptAction.showToast({ message: '登录成功' });
      return true;
    } catch {
      console.error('Login failed');
      promptAction.showToast({ message: '登录失败，请重试' });
      return false;
    }
  }

  async resetPassword(roomNo: string, newPassword: string, securityAnswer: string): Promise<OperationResult> {
    return await UserManager.resetPassword(roomNo, newPassword, securityAnswer);
  }

  async hasSecurityQuestion(roomNo: string): Promise<boolean> {
    const question: ResetPasswordQuestion | null = await UserManager.getSecurityQuestions(roomNo);
    return question !== null;
  }

  async getSecurityQuestion(roomNo: string): Promise<string | null> {
    const questionData: ResetPasswordQuestion | null = await UserManager.getSecurityQuestions(roomNo);
    return questionData?.question || null;
  }

  async checkRoomExists(roomNo: string): Promise<boolean> {
    return await UserManager.userExists(roomNo);
  }

  async logout(): Promise<void> {
    try {
      this.authData.logout();
      console.info('Logout successful');
      promptAction.showToast({ message: '已退出登录' });
    } catch {
      console.error('Logout failed');
    }
  }

  updateRoomNo(value: string): void {
    this.authData.roomNo = value;
  }

  updatePassword(value: string): void {
    this.authData.password = value;
  }

  toggleRememberMe(): void {
    this.authData.rememberMe = !this.authData.rememberMe;
    PreferencesUtil.put('rememberMe', this.authData.rememberMe);
  }

  getRememberMeStatus(): boolean {
    return this.authData.rememberMe;
  }
}