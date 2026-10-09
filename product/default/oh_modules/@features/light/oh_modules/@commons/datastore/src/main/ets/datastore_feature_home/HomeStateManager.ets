/**
 * 首页状态管理器
 * 使用 AppStorageManager 实现跨组件共享状态
 */
import { promptAction } from '@kit.ArkUI';
import { LightStateManager } from '../datastore_feature_device/LightStateManager';
import { AppStorageManager } from '../datastore_app/AppStorageManager';

// 定义空调模式枚举
export enum AirMode {
  COOL = 'cool',
  HEAT = 'heat',
  AUTO = 'auto',
  FAN = 'fan',
  DRY = 'dry'
}

// 定义风速枚举
export enum FanSpeed {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  AUTO = 'auto'
}

const HOME_TEMP_KEY = 'homeTemp';
const HOME_SET_TEMP_KEY = 'homeSetTemp';
const HOME_AIR_ON_KEY = 'homeAirOn';
const HOME_AIR_MODE_KEY = 'homeAirMode';
const HOME_FAN_SPEED_KEY = 'homeFanSpeed';

// 使用类替代索引签名接口
export class AirModeNameMap {
  cool: string = '制冷';
  heat: string = '制热';
  auto: string = '自动';
  fan: string = '送风';
  dry: string = '除湿';

  get(key: string): string {
    switch (key) {
      case AirMode.COOL:
        return this.cool;
      case AirMode.HEAT:
        return this.heat;
      case AirMode.AUTO:
        return this.auto;
      case AirMode.FAN:
        return this.fan;
      case AirMode.DRY:
        return this.dry;
      default:
        return '自动';
    }
  }
}

export class FanSpeedNameMap {
  low: string = '低速';
  medium: string = '中速';
  high: string = '高速';
  auto: string = '自动';

  get(key: string): string {
    switch (key) {
      case FanSpeed.LOW:
        return this.low;
      case FanSpeed.MEDIUM:
        return this.medium;
      case FanSpeed.HIGH:
        return this.high;
      case FanSpeed.AUTO:
        return this.auto;
      default:
        return '自动';
    }
  }
}

export class HomeStateManager {
  static init(): void {
    if (!AppStorageManager.has(HOME_TEMP_KEY)) {
      AppStorageManager.setOrCreate(HOME_TEMP_KEY, 20);
    }
    if (!AppStorageManager.has(HOME_SET_TEMP_KEY)) {
      AppStorageManager.setOrCreate(HOME_SET_TEMP_KEY, 22);
    }
    if (!AppStorageManager.has(HOME_AIR_ON_KEY)) {
      AppStorageManager.setOrCreate(HOME_AIR_ON_KEY, true);
    }
    if (!AppStorageManager.has(HOME_AIR_MODE_KEY)) {
      AppStorageManager.setOrCreate(HOME_AIR_MODE_KEY, AirMode.AUTO);
    }
    if (!AppStorageManager.has(HOME_FAN_SPEED_KEY)) {
      AppStorageManager.setOrCreate(HOME_FAN_SPEED_KEY, FanSpeed.AUTO);
    }
  }

  static getCurrentTemp(): number {
    HomeStateManager.init();
    const result: number | undefined = AppStorageManager.get<number>(HOME_TEMP_KEY);
    return result || 20;
  }

  static setCurrentTemp(temp: number): void {
    AppStorageManager.setOrCreate(HOME_TEMP_KEY, temp);
  }

  static getSetTemp(): number {
    HomeStateManager.init();
    const result: number | undefined = AppStorageManager.get<number>(HOME_SET_TEMP_KEY);
    return result || 22;
  }

  static setSetTemp(temp: number): void {
    AppStorageManager.setOrCreate(HOME_SET_TEMP_KEY, temp);
  }

  static isAirOn(): boolean {
    HomeStateManager.init();
    const result: boolean | undefined = AppStorageManager.get<boolean>(HOME_AIR_ON_KEY);
    return result || true;
  }

  static setAirOn(isOn: boolean): void {
    AppStorageManager.setOrCreate(HOME_AIR_ON_KEY, isOn);
  }

  static toggleAirConditioner(): void {
    const currentState = HomeStateManager.isAirOn();
    HomeStateManager.setAirOn(!currentState);
    promptAction.showToast({ message: !currentState ? '空调已开启' : '空调已关闭' });
  }

  static increaseTemp(): number {
    const newTemp = HomeStateManager.getSetTemp() + 1;
    if (newTemp <= 30) {
      HomeStateManager.setSetTemp(newTemp);
    }
    return HomeStateManager.getSetTemp();
  }

  static decreaseTemp(): number {
    const newTemp = HomeStateManager.getSetTemp() - 1;
    if (newTemp >= 16) {
      HomeStateManager.setSetTemp(newTemp);
    }
    return HomeStateManager.getSetTemp();
  }

  static getAirMode(): AirMode {
    HomeStateManager.init();
    const mode: string | undefined = AppStorageManager.get<string>(HOME_AIR_MODE_KEY);
    if (mode === AirMode.COOL) {
      return AirMode.COOL;
    } else if (mode === AirMode.HEAT) {
      return AirMode.HEAT;
    } else if (mode === AirMode.AUTO) {
      return AirMode.AUTO;
    } else if (mode === AirMode.FAN) {
      return AirMode.FAN;
    } else if (mode === AirMode.DRY) {
      return AirMode.DRY;
    }
    return AirMode.AUTO;
  }

  static setAirMode(mode: AirMode): void {
    AppStorageManager.setOrCreate(HOME_AIR_MODE_KEY, mode);
  }

  static getFanSpeed(): FanSpeed {
    HomeStateManager.init();
    const speed: string | undefined = AppStorageManager.get<string>(HOME_FAN_SPEED_KEY);
    if (speed === FanSpeed.LOW) {
      return FanSpeed.LOW;
    } else if (speed === FanSpeed.MEDIUM) {
      return FanSpeed.MEDIUM;
    } else if (speed === FanSpeed.HIGH) {
      return FanSpeed.HIGH;
    } else if (speed === FanSpeed.AUTO) {
      return FanSpeed.AUTO;
    }
    return FanSpeed.AUTO;
  }

  static setFanSpeed(speed: FanSpeed): void {
    AppStorageManager.setOrCreate(HOME_FAN_SPEED_KEY, speed);
  }

  static cycleAirMode(): void {
    const modes: AirMode[] = [AirMode.AUTO, AirMode.COOL, AirMode.HEAT, AirMode.DRY, AirMode.FAN];
    const currentMode = HomeStateManager.getAirMode();
    const currentIndex = modes.indexOf(currentMode);
    const nextIndex = (currentIndex + 1) % modes.length;
    HomeStateManager.setAirMode(modes[nextIndex]);
  }

  static cycleFanSpeed(): void {
    const speeds: FanSpeed[] = [FanSpeed.LOW, FanSpeed.MEDIUM, FanSpeed.HIGH, FanSpeed.AUTO];
    const currentSpeed = HomeStateManager.getFanSpeed();
    const currentIndex = speeds.indexOf(currentSpeed);
    const nextIndex = (currentIndex + 1) % speeds.length;
    HomeStateManager.setFanSpeed(speeds[nextIndex]);
  }

  static activateNightMode(): void {
    HomeStateManager.setAirOn(false);
    HomeStateManager.setCurrentTemp(20);
    HomeStateManager.setSetTemp(20);
    HomeStateManager.setAirMode(AirMode.AUTO);
    HomeStateManager.setFanSpeed(FanSpeed.LOW);
    LightStateManager.setSceneMode('sleep');
    promptAction.showToast({ message: '晚安模式已激活' });
  }

  static getAirModeName(): string {
    const modeNames = new AirModeNameMap();
    const currentMode = HomeStateManager.getAirMode();
    return modeNames.get(currentMode);
  }

  static getFanSpeedName(): string {
    const speedNames = new FanSpeedNameMap();
    const currentSpeed = HomeStateManager.getFanSpeed();
    return speedNames.get(currentSpeed);
  }
}