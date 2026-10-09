/**
 * 首页视图模型 - 使用 v2 装饰器
 */
import { HomeData } from '../model/HomeData';
import { AirMode, FanSpeed } from '@commons/datastore/src/main/ets/datastore_feature_home/HomeStateManager';
import { SessionManager, UserInfo } from '@commons/datastore/src/main/ets/datastore_app/SessionManager';
import { LightStateManager } from '@commons/datastore/src/main/ets/datastore_feature_device/LightStateManager';
import { promptAction } from '@kit.ArkUI';

export interface SceneModeItem {
  id: string;
  name: string;
  icon: string;
}

// 定义灯配置接口
interface LightConfig {
  values: boolean[];
}

@ObservedV2
export class HomeViewModel {
  @Trace homeData: HomeData = new HomeData();
  @Trace pageTitle: string = '智慧客房';
  @Trace userName: string = '';
  @Trace roomNo: string = '';

  sceneModes: SceneModeItem[] = [
    { id: 'bright', name: '明亮', icon: 'home_icon_bright' },
    { id: 'soft', name: '柔和', icon: 'home_icon_soft' },
    { id: 'reading', name: '阅读', icon: 'home_icon_read' },
    { id: 'warm', name: '温馨', icon: 'home_icon_warm' },
    { id: 'sleep', name: '睡眠', icon: 'light_icon_sleep_mode' }
  ];

  // 灯配置映射
  lightConfigBright: LightConfig = { values: [true, true, true, true, true, true, true, true] };
  lightConfigSoft: LightConfig = { values: [true, true, true, false, false, false, false, false] };
  lightConfigReading: LightConfig = { values: [true, true, false, true, true, false, false, false] };
  lightConfigWarm: LightConfig = { values: [true, true, false, false, false, true, true, false] };
  lightConfigSleep: LightConfig = { values: [false, false, false, false, false, false, false, false] };

  constructor() {
    this.loadUserData();
  }

  loadUserData(): void {
    const session = SessionManager.getSession();
    if (session) {
      this.roomNo = session.roomNo || '';
      this.userName = session.userName || '';
    }
    console.info('HomeViewModel loaded, roomNo: ' + this.roomNo + ', userName: ' + this.userName);
  }

  toggleAirConditioner(): void {
    this.homeData.toggleAirConditioner();
  }

  increaseTemp(): void {
    this.homeData.adjustTemp(1);
  }

  decreaseTemp(): void {
    this.homeData.adjustTemp(-1);
  }

  setSceneMode(mode: string): void {
    this.homeData.setSceneMode(mode);
    LightStateManager.setSceneMode(mode);
  }

  activateNightMode(): void {
    this.setSceneMode('sleep');
  }

  get airStatusText(): string {
    return this.homeData.isAirOn ? '运行中' : '已关闭';
  }

  get currentSceneName(): string {
    const mode = this.sceneModes.find(m => m.id === this.homeData.currentSceneMode);
    return mode?.name || '未知';
  }

  // 空调模式控制
  setAirMode(mode: AirMode): void {
    this.homeData.setAirMode(mode);
    promptAction.showToast({ message: `已切换到${this.homeData.getAirModeName()}模式` });
  }

  get airModeName(): string {
    return this.homeData.getAirModeName();
  }

  cycleAirMode(): void {
    const modes: AirMode[] = [AirMode.AUTO, AirMode.COOL, AirMode.HEAT, AirMode.DRY, AirMode.FAN];
    const currentIndex = modes.indexOf(this.homeData.airMode);
    const nextIndex = (currentIndex + 1) % modes.length;
    this.setAirMode(modes[nextIndex]);
  }

  // 风速控制
  setFanSpeed(speed: FanSpeed): void {
    this.homeData.setFanSpeed(speed);
    promptAction.showToast({ message: `风速已设为${this.homeData.getFanSpeedName()}` });
  }

  get fanSpeedName(): string {
    return this.homeData.getFanSpeedName();
  }

  get fanSpeedLevel(): number {
    return this.homeData.getFanSpeedLevel();
  }

  cycleFanSpeed(): void {
    this.homeData.cycleFanSpeed();
    promptAction.showToast({ message: `风速已设为${this.homeData.getFanSpeedName()}` });
  }

  // 获取完整空调状态
  get airConditionerState() {
    return this.homeData.getAirConditionerState();
  }
}
