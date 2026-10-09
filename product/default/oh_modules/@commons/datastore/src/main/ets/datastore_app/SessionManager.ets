/**
 * SessionManager - 会话管理器
 * 用于管理登录态和用户会话
 * AppStorage 是全局对象，不需要导入
 */
import { AppStorageManager } from './AppStorageManager';
import { PersistenceV2Manager } from '../datastore_base/PersistenceV2Manager';

export interface UserInfo {
  roomNo: string;
  userName?: string;
  token?: string;
}

export class SessionManager {
  private static readonly SESSION_KEY = 'user_session';
  private static readonly TOKEN_KEY = 'auth_token';

  // 保存登录信息
  static saveSession(userInfo: UserInfo, rememberMe: boolean = false): void {
    AppStorageManager.set('roomNo', userInfo.roomNo);
    if (userInfo.userName) {
      AppStorageManager.set('userName', userInfo.userName);
    }
    AppStorageManager.set('rememberMe', rememberMe);

    if (rememberMe) {
      PersistenceV2Manager.set(SessionManager.SESSION_KEY, userInfo);
      if (userInfo.token) {
        PersistenceV2Manager.set(SessionManager.TOKEN_KEY, userInfo.token);
      }
    }
  }

  // 获取登录信息
  static getSession(): UserInfo | null {
    const roomNo = AppStorageManager.get<string>('roomNo');
    if (roomNo) {
      return { roomNo: roomNo };
    }

    // 检查 PersistenceV2Manager 是否已初始化
    const isInitialized = PersistenceV2Manager.isInitialized();
    if (!isInitialized) {
      // 如果未初始化，只返回 AppStorage 中的信息
      return null;
    }

    const session = PersistenceV2Manager.get<UserInfo>(SessionManager.SESSION_KEY);
    return session ?? null;
  }

  // 获取Token
  static getToken(): string | undefined {
    const isInitialized = PersistenceV2Manager.isInitialized();
    if (!isInitialized) {
      return undefined;
    }
    return PersistenceV2Manager.get<string>(SessionManager.TOKEN_KEY);
  }

  // 清除会话
  static clearSession(): void {
    AppStorageManager.remove('roomNo');
    AppStorageManager.remove('userName');
    AppStorageManager.set('rememberMe', false);
    
    if (PersistenceV2Manager.isInitialized()) {
      PersistenceV2Manager.remove(SessionManager.SESSION_KEY);
      PersistenceV2Manager.remove(SessionManager.TOKEN_KEY);
    }
  }

  // 检查是否已登录
  static isLoggedIn(): boolean {
    const session = SessionManager.getSession();
    return session !== null;
  }

  // 检查是否记住登录
  static isRememberMe(): boolean {
    return AppStorageManager.get<boolean>('rememberMe') === true;
  }
}