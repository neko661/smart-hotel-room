/**
 * 登录数据模型
 */
import { SessionManager, UserInfo } from '@commons/datastore/src/main/ets/datastore_app/SessionManager';
import { UserManager, OperationResult } from '@commons/datastore/src/main/ets/datastore_user/UserManager';

export class AuthData {
  roomNo: string = '';
  password: string = '';
  rememberMe: boolean = false;
  isLoggedIn: boolean = false;

  constructor() {
    this.loadSavedData();
  }

  private loadSavedData(): void {
    this.rememberMe = SessionManager.isRememberMe();
    const session: UserInfo | null = SessionManager.getSession();
    if (session && this.rememberMe) {
      this.roomNo = session.roomNo || '';
    }
  }

  validate(): boolean {
    if (!this.roomNo || this.roomNo.length === 0) {
      return false;
    }
    if (!this.password || this.password.length === 0) {
      return false;
    }
    if (this.password.length < 4) {
      return false;
    }
    return true;
  }

  async verifyCredentials(): Promise<OperationResult> {
    // 验证客房号格式
    if (!/^\d{4}$/.test(this.roomNo)) {
      const result: OperationResult = { success: false, message: '客房号必须是4位数字' };
      return result;
    }
    // 验证密码长度
    if (this.password.length < 4) {
      const result: OperationResult = { success: false, message: '密码长度至少4位' };
      return result;
    }

    // 真正验证用户凭据
    const isValid: boolean = await UserManager.verifyCredentials(this.roomNo, this.password);

    if (!isValid) {
      const userExists: boolean = await UserManager.userExists(this.roomNo);
      if (!userExists) {
        const result: OperationResult = { success: false, message: '客房号不存在' };
        return result;
      }

      const remainingAttempts: number = await UserManager.getRemainingAttempts(this.roomNo);
      if (remainingAttempts === 0) {
        const lockoutTime: number = await UserManager.getLockoutTimeRemaining(this.roomNo);
        const result: OperationResult = { success: false, message: `账户已锁定，请${lockoutTime}分钟后重试` };
        return result;
      }

      const result: OperationResult = { success: false, message: `密码错误，剩余尝试次数：${remainingAttempts}` };
      return result;
    }

    const result: OperationResult = { success: true, message: '验证成功' };
    return result;
  }

  saveLoginInfo(): void {
    SessionManager.saveSession(
      {
        roomNo: this.roomNo
      },
      this.rememberMe
    );
  }

  logout(): void {
    SessionManager.clearSession();
    this.isLoggedIn = false;
    this.roomNo = '';
    this.password = '';
  }
}