/**
 * 全局灯光状态管理器
 * 使用 AppStorageManager 实现跨组件共享状态
 */
import { promptAction } from '@kit.ArkUI';
import { AppStorageManager } from '../datastore_app/AppStorageManager';

const LIGHT_SWITCHES_KEY = 'lightSwitches';

export class LightStateManager {
  // 初始化灯光状态
  static init(): void {
    if (!AppStorageManager.has(LIGHT_SWITCHES_KEY)) {
      AppStorageManager.setOrCreate(LIGHT_SWITCHES_KEY, [false, false, false, false, false, false, false, false, false]);
    }
  }

  // 获取灯光开关状态
  static getSwitches(): boolean[] {
    LightStateManager.init();
    const result: boolean[] | undefined = AppStorageManager.get<boolean[]>(LIGHT_SWITCHES_KEY);
    return result || [];
  }

  // 设置灯光开关状态
  static setSwitches(switches: boolean[]): void {
    const newSwitches: boolean[] = [];
    for (let i = 0; i < switches.length; i++) {
      newSwitches.push(switches[i]);
    }
    AppStorageManager.setOrCreate(LIGHT_SWITCHES_KEY, newSwitches);
  }

  // 切换单个灯光
  static toggleLight(index: number): void {
    const switches = LightStateManager.getSwitches();
    if (index >= 0 && index < switches.length) {
      switches[index] = !switches[index];
      LightStateManager.setSwitches(switches);
    }
  }

  // 设置所有灯光
  static setAllLights(on: boolean): void {
    const switches: boolean[] = Array(9).fill(on);
    LightStateManager.setSwitches(switches);
  }

  // 检查是否全部开启
  static isAllOn(): boolean {
    return LightStateManager.getSwitches().every((s: boolean) => s);
  }

  // 检查是否全部关闭
  static isAllOff(): boolean {
    return LightStateManager.getSwitches().every((s: boolean) => !s);
  }

  // 获取开启数量
  static getOnLightCount(): number {
    return LightStateManager.getSwitches().filter((s: boolean) => s).length;
  }

  // 设置场景模式
  static setSceneMode(mode: string): void {
    switch (mode) {
      case 'bright':
        LightStateManager.setSwitches([true, true, true, true, true, true, true, false, true]);
        promptAction.showToast({ message: '明亮模式已激活' });
        break;
      case 'soft':
        LightStateManager.setSwitches([true, true, true, true, false, false, false, false, true]);
        promptAction.showToast({ message: '柔和模式已激活' });
        break;
      case 'read':
        LightStateManager.setSwitches([true, true, false, true, true, true, true, false, false]);
        promptAction.showToast({ message: '阅读模式已激活' });
        break;
      case 'warm':
        LightStateManager.setSwitches([true, true, true, true, false, false, false, false, true]);
        promptAction.showToast({ message: '温馨模式已激活' });
        break;
      case 'sleep':
        LightStateManager.setSwitches([false, false, false, false, false, false, false, false, false]);
        promptAction.showToast({ message: '睡眠模式已激活' });
        break;
    }
  }
}