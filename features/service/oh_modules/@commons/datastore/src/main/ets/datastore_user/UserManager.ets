/**
 * UserManager - 用户管理器
 * 用于管理用户账户、密码验证和密码重置
 */
import { PreferencesUtil } from '../datastore_base/PreferencesUtil';

export interface UserAccount {
  roomNo: string;
  password: string;
  guestName?: string;
  createdAt: string;
}

export interface ResetPasswordQuestion {
  question: string;
  answer: string;
}

export interface OperationResult {
  success: boolean;
  message: string;
}

export interface LockoutData {
  attempts: number;
  lockedUntil: number;
}

export class UserManager {
  private static readonly USERS_KEY = 'hotel_users';
  private static readonly RESET_QUESTIONS_KEY = 'reset_questions';
  private static readonly LOCKOUT_KEY = 'account_lockout';

  // 预设的密保问题
  static readonly SECURITY_QUESTIONS = [
    '您最喜爱的颜色是什么？',
    '您的出生城市是？',
    '您母亲的姓氏是？',
    '您第一只宠物的名字是？',
    '您最喜欢的电影是？'
  ];

  // 初始化默认用户
  static async initializeDefaultUsers(): Promise<void> {
    const existingUsers = await UserManager.getAllUsers();
    if (existingUsers.length > 0) {
      return;
    }

    const defaultUsers: UserAccount[] = [
      { roomNo: '1001', password: '1234', guestName: '张三', createdAt: new Date().toISOString() },
      { roomNo: '1002', password: '1234', guestName: '李四', createdAt: new Date().toISOString() },
      { roomNo: '1003', password: '1234', guestName: '王五', createdAt: new Date().toISOString() },
      { roomNo: '1004', password: '1234', guestName: '赵六', createdAt: new Date().toISOString() },
      { roomNo: '1005', password: '1234', guestName: '钱七', createdAt: new Date().toISOString() }
    ];

    await UserManager.saveAllUsers(defaultUsers);
    console.info('Default users initialized');
  }

  // 获取所有用户
  static async getAllUsers(): Promise<UserAccount[]> {
    try {
      const usersData = await PreferencesUtil.get(UserManager.USERS_KEY, '[]');
      return JSON.parse(usersData as string) as UserAccount[];
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to get users: ' + errMsg);
      return [];
    }
  }

  // 保存所有用户
  private static async saveAllUsers(users: UserAccount[]): Promise<boolean> {
    try {
      await PreferencesUtil.put(UserManager.USERS_KEY, JSON.stringify(users));
      return true;
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to save users: ' + errMsg);
      return false;
    }
  }

  // 查找用户
  static async findUser(roomNo: string): Promise<UserAccount | null> {
    const users = await UserManager.getAllUsers();
    return users.find(user => user.roomNo === roomNo) || null;
  }

  // 验证用户凭据
  static async verifyCredentials(roomNo: string, password: string): Promise<boolean> {
    // 检查账户是否被锁定
    if (await UserManager.isAccountLocked(roomNo)) {
      console.warn(`Account ${roomNo} is locked`);
      return false;
    }

    const user = await UserManager.findUser(roomNo);
    if (!user) {
      console.warn(`User ${roomNo} not found`);
      return false;
    }

    const isValid = user.password === password;
    if (!isValid) {
      await UserManager.recordFailedAttempt(roomNo);
    } else {
      await UserManager.clearFailedAttempts(roomNo);
    }

    return isValid;
  }

  // 检查用户是否存在
  static async userExists(roomNo: string): Promise<boolean> {
    const user = await UserManager.findUser(roomNo);
    return user !== null;
  }

  // 注册新用户
  static async registerUser(roomNo: string, password: string, guestName?: string): Promise<OperationResult> {
    // 验证格式
    if (!/^\d{4}$/.test(roomNo)) {
      const result: OperationResult = { success: false, message: '客房号必须是4位数字' };
      return result;
    }
    if (password.length < 4) {
      const result: OperationResult = { success: false, message: '密码长度至少4位' };
      return result;
    }

    // 检查用户是否已存在
    if (await UserManager.userExists(roomNo)) {
      const result: OperationResult = { success: false, message: '该客房号已被注册' };
      return result;
    }

    const newUser: UserAccount = {
      roomNo: roomNo,
      password: password,
      guestName: guestName,
      createdAt: new Date().toISOString()
    };

    const users = await UserManager.getAllUsers();
    users.push(newUser);
    const success = await UserManager.saveAllUsers(users);

    if (success) {
      console.info(`User registered: ${roomNo}`);
      const result: OperationResult = { success: true, message: '注册成功' };
      return result;
    }
    const result: OperationResult = { success: false, message: '注册失败，请重试' };
    return result;
  }

  // 修改密码
  static async changePassword(roomNo: string, oldPassword: string, newPassword: string): Promise<OperationResult> {
    const user = await UserManager.findUser(roomNo);
    if (!user) {
      const result: OperationResult = { success: false, message: '用户不存在' };
      return result;
    }

    if (user.password !== oldPassword) {
      const result: OperationResult = { success: false, message: '原密码错误' };
      return result;
    }

    if (newPassword.length < 4) {
      const result: OperationResult = { success: false, message: '新密码长度至少4位' };
      return result;
    }

    const users = await UserManager.getAllUsers();
    const index = users.findIndex(u => u.roomNo === roomNo);
    if (index !== -1) {
      users[index].password = newPassword;
      const success = await UserManager.saveAllUsers(users);
      if (success) {
        console.info(`Password changed for user: ${roomNo}`);
        const result: OperationResult = { success: true, message: '密码修改成功' };
        return result;
      }
    }
    const result: OperationResult = { success: false, message: '密码修改失败，请重试' };
    return result;
  }

  // 重置密码（通过密保问题）
  static async resetPassword(roomNo: string, newPassword: string, securityAnswer: string): Promise<OperationResult> {
    const user = await UserManager.findUser(roomNo);
    if (!user) {
      const result: OperationResult = { success: false, message: '用户不存在' };
      return result;
    }

    // 验证密保答案
    const storedQuestions = await UserManager.getSecurityQuestions(roomNo);
    if (!storedQuestions || storedQuestions.answer !== securityAnswer) {
      await UserManager.recordFailedAttempt(roomNo);
      const result: OperationResult = { success: false, message: '密保答案错误' };
      return result;
    }

    if (newPassword.length < 4) {
      const result: OperationResult = { success: false, message: '新密码长度至少4位' };
      return result;
    }

    const users = await UserManager.getAllUsers();
    const index = users.findIndex(u => u.roomNo === roomNo);
    if (index !== -1) {
      users[index].password = newPassword;
      const success = await UserManager.saveAllUsers(users);
      if (success) {
        await UserManager.clearFailedAttempts(roomNo);
        console.info(`Password reset for user: ${roomNo}`);
        const result: OperationResult = { success: true, message: '密码重置成功' };
        return result;
      }
    }
    const result: OperationResult = { success: false, message: '密码重置失败，请重试' };
    return result;
  }

  // 设置密保问题
  static async setSecurityQuestion(roomNo: string, questionIndex: number, answer: string): Promise<boolean> {
    if (questionIndex < 0 || questionIndex >= UserManager.SECURITY_QUESTIONS.length) {
      return false;
    }

    try {
      const questionData: ResetPasswordQuestion = {
        question: UserManager.SECURITY_QUESTIONS[questionIndex],
        answer: answer.toLowerCase().trim()
      };

      const key = `${UserManager.RESET_QUESTIONS_KEY}_${roomNo}`;
      await PreferencesUtil.put(key, JSON.stringify(questionData));
      return true;
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to set security question: ' + errMsg);
      return false;
    }
  }

  // 获取密保问题
  static async getSecurityQuestions(roomNo: string): Promise<ResetPasswordQuestion | null> {
    try {
      const key = `${UserManager.RESET_QUESTIONS_KEY}_${roomNo}`;
      const data = await PreferencesUtil.get(key, '');
      if (data) {
        return JSON.parse(data as string) as ResetPasswordQuestion;
      }
      return null;
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to get security questions: ' + errMsg);
      return null;
    }
  }

  // 获取账户锁定状态
  private static async isAccountLocked(roomNo: string): Promise<boolean> {
    try {
      const key = `${UserManager.LOCKOUT_KEY}_${roomNo}`;
      const lockoutData = await PreferencesUtil.get(key, '');
      if (lockoutData) {
        const data: LockoutData = JSON.parse(lockoutData as string);
        const now = Date.now();
        if (data.lockedUntil > now) {
          return true;
        } else {
          await PreferencesUtil.delete(key);
        }
      }
      return false;
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to check lockout status: ' + errMsg);
      return false;
    }
  }

  // 记录失败尝试
  private static async recordFailedAttempt(roomNo: string): Promise<void> {
    try {
      const key = `${UserManager.LOCKOUT_KEY}_${roomNo}`;
      const data = await PreferencesUtil.get(key, '');
      let attempts = 0;
      let lockedUntil = 0;

      if (data) {
        const parsed: LockoutData = JSON.parse(data as string);
        attempts = parsed.attempts || 0;
      }

      attempts++;

      // 5次失败后锁定30分钟
      if (attempts >= 5) {
        lockedUntil = Date.now() + 30 * 60 * 1000;
        console.warn(`Account ${roomNo} locked for 30 minutes`);
      }

      const lockoutData: LockoutData = { attempts: attempts, lockedUntil: lockedUntil };
      await PreferencesUtil.put(key, JSON.stringify(lockoutData));
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to record failed attempt: ' + errMsg);
    }
  }

  // 清除失败尝试记录
  private static async clearFailedAttempts(roomNo: string): Promise<void> {
    try {
      const key = `${UserManager.LOCKOUT_KEY}_${roomNo}`;
      await PreferencesUtil.delete(key);
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to clear failed attempts: ' + errMsg);
    }
  }

  // 获取剩余尝试次数
  static async getRemainingAttempts(roomNo: string): Promise<number> {
    try {
      const key = `${UserManager.LOCKOUT_KEY}_${roomNo}`;
      const data = await PreferencesUtil.get(key, '');
      if (data) {
        const parsed: LockoutData = JSON.parse(data as string);
        const now = Date.now();
        if (parsed.lockedUntil > now) {
          return 0;
        }
        return Math.max(0, 5 - (parsed.attempts || 0));
      }
      return 5;
    } catch (error) {
      return 5;
    }
  }

  // 获取锁定剩余时间（分钟）
  static async getLockoutTimeRemaining(roomNo: string): Promise<number> {
    try {
      const key = `${UserManager.LOCKOUT_KEY}_${roomNo}`;
      const data = await PreferencesUtil.get(key, '');
      if (data) {
        const parsed: LockoutData = JSON.parse(data as string);
        const now = Date.now();
        if (parsed.lockedUntil > now) {
          return Math.ceil((parsed.lockedUntil - now) / 60000);
        }
      }
      return 0;
    } catch (error) {
      return 0;
    }
  }
}
