/**
 * 灯光视图模型
 */
import { LightStateManager } from '@commons/datastore/src/main/ets/datastore_feature_device/LightStateManager';
import { promptAction } from '@kit.ArkUI';

export interface LightTypeItem {
  id: number;
  name: string;
  icon: string;
}

export class LightViewModel {
  lightTypes: LightTypeItem[] = [
    { id: 0, name: '洗漱间', icon: 'light_icon_washroom' },
    { id: 1, name: '衣柜灯', icon: 'light_icon_wardrobe' },
    { id: 2, name: '落地灯', icon: 'light_icon_bright_mode' },
    { id: 3, name: '吧灯', icon: 'light_icon_soft' },
    { id: 4, name: '书桌灯', icon: 'light_icon_bar_lamp' },
    { id: 5, name: '右阅读灯', icon: 'light_icon_right_left_desk_read' },
    { id: 6, name: '左阅读灯', icon: 'light_icon_right_left_desk_read' },
    { id: 7, name: '排风扇', icon: 'light_icon_exhaust_fan' },
    { id: 8, name: '廊灯', icon: 'light_icon_corrid_lights' }
  ];

  get lightSwitches(): boolean[] {
    return LightStateManager.getSwitches();
  }

  get isAllOn(): boolean {
    return LightStateManager.isAllOn();
  }

  constructor() {
    LightStateManager.init();
  }

  toggleMasterSwitch(): void {
    const newState = !LightStateManager.isAllOn();
    LightStateManager.setAllLights(newState);
    promptAction.showToast({
      message: newState ? '所有灯光已开启' : '所有灯光已关闭'
    });
  }

  toggleLight(index: number, name: string): void {
    LightStateManager.toggleLight(index);
    promptAction.showToast({
      message: LightStateManager.getSwitches()[index] ? `${name}已开启` : `${name}已关闭`
    });
  }

  setBrightMode(): void {
    LightStateManager.setSceneMode('bright');
  }

  setSoftMode(): void {
    LightStateManager.setSceneMode('soft');
  }

  setReadMode(): void {
    LightStateManager.setSceneMode('read');
  }

  setWarmMode(): void {
    LightStateManager.setSceneMode('warm');
  }

  setSleepMode(): void {
    LightStateManager.setSceneMode('sleep');
  }
}
