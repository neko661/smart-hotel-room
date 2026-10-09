/**
 * PreferencesUtil - 首选项工具类
 * 用于本地记住密码等轻量级数据存储
 */
import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';

export class PreferencesUtil {
  private static preferencesInstance: preferences.Preferences | null = null;
  private static readonly STORE_NAME = 'hotel_room_prefs';

  // 初始化 Preferences
  static async init(context: Context): Promise<void> {
    try {
      PreferencesUtil.preferencesInstance = await preferences.getPreferences(context, PreferencesUtil.STORE_NAME);
      console.info('PreferencesUtil initialized');
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to initialize PreferencesUtil: ' + errMsg);
    }
  }

  // 保存数据
  static async put(key: string, value: preferences.ValueType): Promise<boolean> {
    try {
      if (!PreferencesUtil.preferencesInstance) {
        console.error('PreferencesUtil not initialized');
        return false;
      }
      await PreferencesUtil.preferencesInstance.put(key, value);
      await PreferencesUtil.preferencesInstance.flush();
      return true;
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to save preference: ' + errMsg);
      return false;
    }
  }

  // 获取数据
  static async get(key: string, defaultValue: preferences.ValueType = ''): Promise<preferences.ValueType> {
    try {
      if (!PreferencesUtil.preferencesInstance) {
        console.error('PreferencesUtil not initialized');
        return defaultValue;
      }
      return await PreferencesUtil.preferencesInstance.get(key, defaultValue);
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to get preference: ' + errMsg);
      return defaultValue;
    }
  }

  // 删除数据
  static async delete(key: string): Promise<boolean> {
    try {
      if (!PreferencesUtil.preferencesInstance) {
        return false;
      }
      await PreferencesUtil.preferencesInstance.delete(key);
      await PreferencesUtil.preferencesInstance.flush();
      return true;
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to delete preference: ' + errMsg);
      return false;
    }
  }

  // 清空所有数据
  static async clear(): Promise<boolean> {
    try {
      if (!PreferencesUtil.preferencesInstance) {
        return false;
      }
      await PreferencesUtil.preferencesInstance.clear();
      await PreferencesUtil.preferencesInstance.flush();
      return true;
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : String(error);
      console.error('Failed to clear preferences: ' + errMsg);
      return false;
    }
  }
}
