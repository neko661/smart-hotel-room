/**
 * AppStorage管理器 - 轻量级数据存储
 * AppStorage 是全局对象，不需要导入
 */
export class AppStorageManager {
  static set<T>(key: string, value: T): void {
    AppStorage.setOrCreate(key, value);
  }

  static get<T>(key: string): T | undefined {
    return AppStorage.get<T>(key);
  }

  static remove(key: string): void {
    if (AppStorage.has(key)) {
      AppStorage.delete(key);
    }
  }

  static has(key: string): boolean {
    return AppStorage.has(key);
  }

  static setOrCreate<T>(key: string, value: T): void {
    AppStorage.setOrCreate(key, value);
  }
}