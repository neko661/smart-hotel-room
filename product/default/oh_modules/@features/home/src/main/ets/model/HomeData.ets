/**
 * 首页数据模型 - 使用 v2 装饰器
 */
import { promptAction } from '@kit.ArkUI';
import { AirMode, FanSpeed } from '@commons/datastore/src/main/ets/datastore_feature_home/HomeStateManager';

export { AirMode, FanSpeed };

export interface AirConditionerState {
  isOn: boolean;
  currentTemp: number;
  setTemp: number;
  mode: AirMode;
  fanSpeed: FanSpeed;
}

// 空调模式名称映射类
export class AirModeNameMap {
  private cool: string = '制冷';
  private heat: string = '制热';
  private auto: string = '自动';
  private fan: string = '送风';
  private dry: string = '除湿';

  getName(mode: AirMode): string {
    if (mode === AirMode.COOL) {
      return this.cool;
    } else if (mode === AirMode.HEAT) {
      return this.heat;
    } else if (mode === AirMode.AUTO) {
      return this.auto;
    } else if (mode === AirMode.FAN) {
      return this.fan;
    } else if (mode === AirMode.DRY) {
      return this.dry;
    }
    return this.auto;
  }
}

// 风速名称映射类
export class FanSpeedNameMap {
  private low: string = '低速';
  private medium: string = '中速';
  private high: string = '高速';
  private auto: string = '自动';

  getName(speed: FanSpeed): string {
    if (speed === FanSpeed.LOW) {
      return this.low;
    } else if (speed === FanSpeed.MEDIUM) {
      return this.medium;
    } else if (speed === FanSpeed.HIGH) {
      return this.high;
    } else if (speed === FanSpeed.AUTO) {
      return this.auto;
    }
    return this.auto;
  }
}

// 风速等级映射类
export class FanSpeedLevelMap {
  private lowLevel: number = 1;
  private mediumLevel: number = 2;
  private highLevel: number = 3;
  private autoLevel: number = 0;

  getLevel(speed: FanSpeed): number {
    if (speed === FanSpeed.LOW) {
      return this.lowLevel;
    } else if (speed === FanSpeed.MEDIUM) {
      return this.mediumLevel;
    } else if (speed === FanSpeed.HIGH) {
      return this.highLevel;
    } else if (speed === FanSpeed.AUTO) {
      return this.autoLevel;
    }
    return this.autoLevel;
  }
}

@ObservedV2
export class HomeData {
  @Trace isAirOn: boolean = true;
  @Trace currentTemp: number = 20;
  @Trace setTemp: number = 22;
  @Trace currentSceneMode: string = 'bright';
  @Trace lightSwitches: boolean[] = [false, false, false, false, false, false, false, false, false];

  // 空调模式和风速
  @Trace airMode: AirMode = AirMode.AUTO;
  @Trace fanSpeed: FanSpeed = FanSpeed.AUTO;

  // 名称映射实例
  private airModeNameMap: AirModeNameMap = new AirModeNameMap();
  private fanSpeedNameMap: FanSpeedNameMap = new FanSpeedNameMap();
  private fanSpeedLevelMap: FanSpeedLevelMap = new FanSpeedLevelMap();

  // 温度范围
  private static readonly MIN_TEMP = 16;
  private static readonly MAX_TEMP = 30;

  constructor() {
  }

  toggleAirConditioner(): void {
    this.isAirOn = !this.isAirOn;
  }

  adjustTemp(delta: number): void {
    const newTemp = this.setTemp + delta;
    if (newTemp >= HomeData.MIN_TEMP && newTemp <= HomeData.MAX_TEMP) {
      this.setTemp = newTemp;
    }
  }

  setSceneMode(mode: string): void {
    this.currentSceneMode = mode;
  }

  toggleLight(index: number): void {
    if (index >= 0 && index < this.lightSwitches.length) {
      this.lightSwitches[index] = !this.lightSwitches[index];
    }
  }

  turnAllLights(on: boolean): void {
    this.lightSwitches = this.lightSwitches.map(() => on);
  }

  // 设置空调模式
  setAirMode(mode: AirMode): void {
    this.airMode = mode;
  }

  // 获取空调模式名称
  getAirModeName(): string {
    return this.airModeNameMap.getName(this.airMode);
  }

  // 设置风速
  setFanSpeed(speed: FanSpeed): void {
    this.fanSpeed = speed;
  }

  // 获取风速名称
  getFanSpeedName(): string {
    return this.fanSpeedNameMap.getName(this.fanSpeed);
  }

  // 获取风速等级（用于UI显示）
  getFanSpeedLevel(): number {
    return this.fanSpeedLevelMap.getLevel(this.fanSpeed);
  }

  // 切换风速（循环切换）
  cycleFanSpeed(): void {
    const speeds: FanSpeed[] = [FanSpeed.LOW, FanSpeed.MEDIUM, FanSpeed.HIGH, FanSpeed.AUTO];
    const currentIndex = speeds.indexOf(this.fanSpeed);
    const nextIndex = (currentIndex + 1) % speeds.length;
    this.fanSpeed = speeds[nextIndex];
  }

  // 获取空调完整状态
  getAirConditionerState(): AirConditionerState {
    return {
      isOn: this.isAirOn,
      currentTemp: this.currentTemp,
      setTemp: this.setTemp,
      mode: this.airMode,
      fanSpeed: this.fanSpeed
    };
  }
}