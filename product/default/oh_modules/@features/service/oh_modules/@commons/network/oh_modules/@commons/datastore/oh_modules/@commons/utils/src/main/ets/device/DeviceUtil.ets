/**
 * 设备工具类
 */
import { display } from '@kit.ArkUI';
import { deviceInfo, network } from '@kit.BasicServicesKit';
import { batteryInfo } from '@kit.BasicServicesKit';

export type DeviceType = 'phone' | 'tablet' | 'watch' | 'car' | 'tv' | 'unknown';
export type ScreenOrientation = 'portrait' | 'landscape';

export interface DeviceInfo {
  type: DeviceType;
  model: string;
  product: string;
  osVersion: string;
  sdkApiVersion: number;
  screenWidth: number;
  screenHeight: number;
  pixelRatio: number;
  orientation: ScreenOrientation;
}

export interface NetworkInfo {
  isConnected: boolean;
  type: string;
}

export interface BatteryInfo {
  level: number;
  isCharging: boolean;
}

export class DeviceUtil {
  private static deviceInfo: DeviceInfo | null = null;
  private static screenWidth: number = 0;
  private static screenHeight: number = 0;

  static getDeviceInfo(): DeviceInfo {
    if (!DeviceUtil.deviceInfo) {
      DeviceUtil.deviceInfo = DeviceUtil.detectDevice();
    }
    return DeviceUtil.deviceInfo;
  }

  private static detectDevice(): DeviceInfo {
    const defaultDisplay = display.getDefaultDisplaySync();
    DeviceUtil.screenWidth = defaultDisplay.width;
    DeviceUtil.screenHeight = defaultDisplay.height;
    const pixelRatio: number = defaultDisplay.densityPixels;

    const orientation: ScreenOrientation = DeviceUtil.screenWidth > DeviceUtil.screenHeight
      ? 'landscape'
      : 'portrait';

    // 使用landscape方向的尺寸来判断设备类型
    const width = orientation === 'landscape' ? DeviceUtil.screenWidth : DeviceUtil.screenHeight;
    const height = orientation === 'landscape' ? DeviceUtil.screenHeight : DeviceUtil.screenWidth;

    let type: DeviceType = 'unknown';
    if (width < 360) {
      type = 'watch';
    } else if (width >= 720) {
      type = 'tablet';
    } else {
      type = 'phone';
    }

    return {
      type,
      model: deviceInfo.model,
      product: deviceInfo.product,
      osVersion: deviceInfo.osFullName,
      sdkApiVersion: deviceInfo.sdkApiVersion,
      screenWidth: width,
      screenHeight: height,
      pixelRatio,
      orientation
    };
  }

  static isPhone(): boolean {
    return DeviceUtil.getDeviceInfo().type === 'phone';
  }

  static isTablet(): boolean {
    return DeviceUtil.getDeviceInfo().type === 'tablet';
  }

  static isWatch(): boolean {
    return DeviceUtil.getDeviceInfo().type === 'watch';
  }

  static isCar(): boolean {
    return DeviceUtil.getDeviceInfo().type === 'car';
  }

  static isTv(): boolean {
    return DeviceUtil.getDeviceInfo().type === 'tv';
  }

  static getScreenWidth(): number {
    return DeviceUtil.getDeviceInfo().screenWidth;
  }

  static getScreenHeight(): number {
    return DeviceUtil.getDeviceInfo().screenHeight;
  }

  static getPixelRatio(): number {
    return DeviceUtil.getDeviceInfo().pixelRatio;
  }

  static getOrientation(): ScreenOrientation {
    return DeviceUtil.getDeviceInfo().orientation;
  }

  static isPortrait(): boolean {
    return DeviceUtil.getDeviceInfo().orientation === 'portrait';
  }

  static isLandscape(): boolean {
    return DeviceUtil.getDeviceInfo().orientation === 'landscape';
  }

  static dp2px(dp: number): number {
    return Math.round(dp * DeviceUtil.getPixelRatio());
  }

  static px2dp(px: number): number {
    return Math.round(px / DeviceUtil.getPixelRatio());
  }

  static vp2px(vp: number): number {
    const density = DeviceUtil.getPixelRatio() / 160;
    return Math.round(vp * density);
  }

  static px2vp(px: number): number {
    const density = DeviceUtil.getPixelRatio() / 160;
    return Math.round(px / density);
  }

  // 获取设备型号
  static getModel(): string {
    return DeviceUtil.getDeviceInfo().model;
  }

  // 获取产品名称
  static getProduct(): string {
    return DeviceUtil.getDeviceInfo().product;
  }

  // 获取系统版本
  static getOSVersion(): string {
    return DeviceUtil.getDeviceInfo().osVersion;
  }

  // 获取SDK版本
  static getSdkApiVersion(): number {
    return DeviceUtil.getDeviceInfo().sdkApiVersion;
  }

  // 获取唯一标识符
  static getDeviceId(): string {
    return deviceInfo.udid;
  }

  // 获取品牌
  static getBrand(): string {
    return deviceInfo.brand;
  }

  // 获取制造商
  static getManufacturer(): string {
    return deviceInfo.manufacturer;
  }

  // 判断是否为模拟器
  static isEmulator(): boolean {
    return deviceInfo.distributionType === 'emulator';
  }

  // 判断是否为调试模式
  static isDebug(): boolean {
    return deviceInfo.buildType === 'debug';
  }

  // 获取网络信息
  static async getNetworkInfo(): Promise<NetworkInfo> {
    try {
      const netCon = network.createNetworkConnection();
      const connInfo = await netCon.getConnectionProperties();
      return {
        isConnected: true,
        type: connInfo.type || 'unknown'
      };
    } catch (e) {
      return {
        isConnected: false,
        type: 'none'
      };
    }
  }

  // 判断是否有网络连接
  static async isNetworkAvailable(): Promise<boolean> {
    const netInfo = await DeviceUtil.getNetworkInfo();
    return netInfo.isConnected;
  }

  // 判断是否为WiFi
  static async isWiFi(): Promise<boolean> {
    const netInfo = await DeviceUtil.getNetworkInfo();
    return netInfo.isConnected && netInfo.type === 'wifi';
  }

  // 判断是否为移动网络
  static async isMobileNetwork(): Promise<boolean> {
    const netInfo = await DeviceUtil.getNetworkInfo();
    return netInfo.isConnected && netInfo.type === 'cellular';
  }

  // 获取电池信息
  static getBatteryInfo(): BatteryInfo {
    try {
      return {
        level: batteryInfo.batteryLevel,
        isCharging: batteryInfo.chargingStatus === 1
      };
    } catch (e) {
      return {
        level: 0,
        isCharging: false
      };
    }
  }

  // 获取电池电量
  static getBatteryLevel(): number {
    try {
      return batteryInfo.batteryLevel;
    } catch (e) {
      return 0;
    }
  }

  // 判断是否正在充电
  static isCharging(): boolean {
    try {
      return batteryInfo.chargingStatus === 1;
    } catch (e) {
      return false;
    }
  }

  // 判断是否低电量（低于20%）
  static isLowBattery(): boolean {
    return DeviceUtil.getBatteryLevel() < 20;
  }

  // 获取屏幕安全区域（处理刘海屏等）
  static getSafeArea(): { top: number; bottom: number; left: number; right: number } {
    try {
      const defaultDisplay = display.getDefaultDisplaySync();
      const rotation = defaultDisplay.rotation;
      // 这里可以根据实际需要实现安全区域计算
      return { top: 0, bottom: 0, left: 0, right: 0 };
    } catch (e) {
      return { top: 0, bottom: 0, left: 0, right: 0 };
    }
  }

  // 重置缓存（屏幕旋转时需要）
  static resetCache(): void {
    DeviceUtil.deviceInfo = null;
  }

  // 获取设备类型描述
  static getDeviceTypeLabel(): string {
    const typeLabels: Record<DeviceType, string> = {
      phone: '手机',
      tablet: '平板',
      watch: '手表',
      car: '车载',
      tv: '电视',
      unknown: '未知'
    };
    return typeLabels[DeviceUtil.getDeviceInfo().type] || '未知';
  }

  // 判断是否支持某功能（根据SDK版本）
  static isApiSupported(minApiVersion: number): boolean {
    return DeviceUtil.getSdkApiVersion() >= minApiVersion;
  }
}
