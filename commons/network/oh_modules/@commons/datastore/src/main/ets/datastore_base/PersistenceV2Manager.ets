/**
 * PersistenceV2管理器 - 持久化存储
 */
import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

export class PersistenceV2Manager {
  private static preferences: preferences.Preferences | null = null;
  private static readonly STORE_NAME = 'app_preferences';

  // 初始化持久化存储
  static async init(context: Context): Promise<void> {
    try {
      PersistenceV2Manager.preferences = await preferences.getPreferences(context, PersistenceV2Manager.STORE_NAME);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`PersistenceV2.init error: code=${err.code}, message=${err.message}`);
    }
  }

  // 检查是否已初始化
  static isInitialized(): boolean {
    return PersistenceV2Manager.preferences !== null;
  }

  // 设置持久化存储
  static set<T>(key: string, value: T): void {
    if (PersistenceV2Manager.preferences) {
      try {
        PersistenceV2Manager.preferences.put(key, JSON.stringify(value))
          .then(() => {
            PersistenceV2Manager.preferences?.flush();
          })
          .catch((error: BusinessError) => {
            console.error(`PersistenceV2.put error: code=${error.code}, message=${error.message}`);
          });
      } catch (error) {
        const errMsg = error instanceof Error ? error.message : String(error);
        console.error('PersistenceV2.set error: ' + errMsg);
      }
    }
  }

  // 获取持久化存储（同步）
  static get<T>(key: string): T | undefined {
    let result: T | undefined = undefined;
    if (PersistenceV2Manager.preferences) {
      try {
        const value = PersistenceV2Manager.preferences.getSync(key, '');
        const strValue = value as string;
        if (strValue && strValue.length > 0) {
          result = JSON.parse(strValue) as T;
        }
      } catch (error) {
        const errMsg = error instanceof Error ? error.message : String(error);
        console.error('PersistenceV2.get error: ' + errMsg);
      }
    }
    return result;
  }

  // 移除持久化存储
  static remove(key: string): void {
    if (PersistenceV2Manager.preferences) {
      try {
        PersistenceV2Manager.preferences.delete(key)
          .then(() => {
            PersistenceV2Manager.preferences?.flush();
          })
          .catch((error: BusinessError) => {
            console.error(`PersistenceV2.delete error: code=${error.code}, message=${error.message}`);
          });
      } catch (error) {
        const errMsg = error instanceof Error ? error.message : String(error);
        console.error('PersistenceV2.remove error: ' + errMsg);
      }
    }
  }
}
