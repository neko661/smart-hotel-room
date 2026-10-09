/**
 * 响应式工具类
 */
import { DeviceUtil, DeviceType } from '../device/DeviceUtil';
import { Logger } from '../log/Logger';

export interface ResponsiveSize {
  phone?: number;
  tablet?: number;
  watch?: number;
  car?: number;
  tv?: number;
}

export interface ResponsiveConfig {
  gridCols: ResponsiveSize;
  spacing: ResponsiveSize;
  fontSize: ResponsiveSize;
  iconSize: ResponsiveSize;
  maxWidth: ResponsiveSize;
  padding: ResponsiveSize;
}

export type Breakpoint = 'xs' | 'sm' | 'md' | 'lg' | 'xl';

export interface BreakpointRange {
  min: number;
  max: number;
}

export class ResponsiveUtil {
  // 默认响应式配置
  private static defaultConfig: ResponsiveConfig = {
    gridCols: {
      phone: 2,
      tablet: 4,
      watch: 1,
      car: 3,
      tv: 6
    },
    spacing: {
      phone: 12,
      tablet: 20,
      watch: 8,
      car: 16,
      tv: 24
    },
    fontSize: {
      phone: 16,
      tablet: 20,
      watch: 12,
      car: 18,
      tv: 28
    },
    iconSize: {
      phone: 24,
      tablet: 32,
      watch: 16,
      car: 28,
      tv: 40
    },
    maxWidth: {
      phone: DeviceUtil.getScreenWidth(),
      tablet: 1024,
      watch: DeviceUtil.getScreenWidth(),
      car: 1920,
      tv: 3840
    },
    padding: {
      phone: 16,
      tablet: 24,
      watch: 12,
      car: 20,
      tv: 32
    }
  };

  // 断点配置
  private static breakpoints: Record<Breakpoint, BreakpointRange> = {
    xs: { min: 0, max: 359 },
    sm: { min: 360, max: 479 },
    md: { min: 480, max: 719 },
    lg: { min: 720, max: 1023 },
    xl: { min: 1024, max: Infinity }
  };

  // 自定义配置
  private static customConfig: Partial<ResponsiveConfig> | null = null;

  static getDeviceType(): DeviceType {
    return DeviceUtil.getDeviceInfo().type;
  }

  // 设置自定义配置
  static setConfig(config: Partial<ResponsiveConfig>): void {
    ResponsiveUtil.customConfig = config;
  }

  // 获取配置
  private static getConfig(): ResponsiveConfig {
    if (ResponsiveUtil.customConfig) {
      return { ...ResponsiveUtil.defaultConfig, ...ResponsiveUtil.customConfig };
    }
    return ResponsiveUtil.defaultConfig;
  }

  static getValue(size: ResponsiveSize | number): number {
    if (typeof size === 'number') {
      return size;
    }

    const deviceType: DeviceType = ResponsiveUtil.getDeviceType();
    let value: number | undefined;

    switch (deviceType) {
      case 'phone':
        value = size.phone;
        break;
      case 'tablet':
        value = size.tablet;
        break;
      case 'watch':
        value = size.watch;
        break;
      case 'car':
        value = size.car;
        break;
      case 'tv':
        value = size.tv;
        break;
      default:
        break;
    }

    if (value !== undefined) {
      return value;
    }

    return size.phone || 16;
  }

  static getGridCols(config?: ResponsiveSize): number {
    const mergedConfig = ResponsiveUtil.getConfig();
    return ResponsiveUtil.getValue(config || mergedConfig.gridCols);
  }

  static getSpacing(config?: ResponsiveSize): number {
    const mergedConfig = ResponsiveUtil.getConfig();
    return ResponsiveUtil.getValue(config || mergedConfig.spacing);
  }

  static getFontSize(config?: ResponsiveSize): number {
    const mergedConfig = ResponsiveUtil.getConfig();
    return ResponsiveUtil.getValue(config || mergedConfig.fontSize);
  }

  static getIconSize(config?: ResponsiveSize): number {
    const mergedConfig = ResponsiveUtil.getConfig();
    return ResponsiveUtil.getValue(config || mergedConfig.iconSize);
  }

  static getMaxWidth(config?: ResponsiveSize): number {
    const mergedConfig = ResponsiveUtil.getConfig();
    return ResponsiveUtil.getValue(config || mergedConfig.maxWidth);
  }

  static getPadding(config?: ResponsiveSize): number {
    const mergedConfig = ResponsiveUtil.getConfig();
    return ResponsiveUtil.getValue(config || mergedConfig.padding);
  }

  static getResponsiveStyle<T>(styles: Record<string, T>): T {
    const deviceType: DeviceType = ResponsiveUtil.getDeviceType();
    const result: T | undefined = styles[deviceType];
    if (result !== undefined) {
      return result;
    }
    return styles['phone'];
  }

  // 获取当前断点
  static getBreakpoint(): Breakpoint {
    const width = DeviceUtil.getScreenWidth();

    for (const [key, range] of Object.entries(ResponsiveUtil.breakpoints)) {
      if (width >= range.min && width <= range.max) {
        return key as Breakpoint;
      }
    }

    return 'md';
  }

  // 根据断点获取值
  static getValueByBreakpoint<T>(values: Partial<Record<Breakpoint, T>>, defaultValue: T): T {
    const breakpoint = ResponsiveUtil.getBreakpoint();
    return values[breakpoint] ?? defaultValue;
  }

  // 设置自定义断点
  static setBreakpoints(breakpoints: Partial<Record<Breakpoint, BreakpointRange>>): void {
    ResponsiveUtil.breakpoints = { ...ResponsiveUtil.breakpoints, ...breakpoints };
  }

  // 判断是否为小屏幕
  static isSmallScreen(): boolean {
    const breakpoint = ResponsiveUtil.getBreakpoint();
    return breakpoint === 'xs' || breakpoint === 'sm';
  }

  // 判断是否为中等屏幕
  static isMediumScreen(): boolean {
    return ResponsiveUtil.getBreakpoint() === 'md';
  }

  // 判断是否为大屏幕
  static isLargeScreen(): boolean {
    const breakpoint = ResponsiveUtil.getBreakpoint();
    return breakpoint === 'lg' || breakpoint === 'xl';
  }

  // 获取响应式间距
  static getResponsiveSpacing(multiplier: number = 1): number {
    return Math.round(ResponsiveUtil.getSpacing() * multiplier);
  }

  // 获取响应式圆角
  static getBorderRadius(): number {
    if (ResponsiveUtil.isSmallScreen()) {
      return 8;
    } else if (ResponsiveUtil.isMediumScreen()) {
      return 12;
    } else {
      return 16;
    }
  }

  // 获取响应式卡片宽度
  static getCardWidth(columns: number = 2): number {
    const spacing = ResponsiveUtil.getSpacing();
    const screenWidth = DeviceUtil.getScreenWidth();
    const totalSpacing = spacing * (columns + 1);
    return Math.floor((screenWidth - totalSpacing) / columns);
  }

  // 获取列数（基于屏幕宽度）
  static getColumnCount(minWidth: number = 150): number {
    const screenWidth = DeviceUtil.getScreenWidth();
    const spacing = ResponsiveUtil.getSpacing();
    const availableWidth = screenWidth - spacing * 2;
    return Math.max(1, Math.floor((availableWidth + spacing) / (minWidth + spacing)));
  }

  // 获取图片宽度（适配屏幕）
  static getImageWidth(aspectRatio: number = 16 / 9): number {
    const screenWidth = DeviceUtil.getScreenWidth();
    const padding = ResponsiveUtil.getPadding() * 2;
    const availableWidth = screenWidth - padding;
    return Math.floor(availableWidth);
  }

  // 获取图片高度
  static getImageHeight(width: number, aspectRatio: number = 16 / 9): number {
    return Math.floor(width / aspectRatio);
  }

  // 获取列表项高度
  static getListItemHeight(): number {
    return ResponsiveUtil.isSmallScreen() ? 56 : 72;
  }

  // 获取导航栏高度
  static getNavBarHeight(): number {
    return ResponsiveUtil.isSmallScreen() ? 56 : 64;
  }

  // 获取底部栏高度
  static getTabBarHeight(): number {
    return ResponsiveUtil.isSmallScreen() ? 48 : 56;
  }

  // 监听屏幕方向变化
  static onOrientationChange(callback: (orientation: 'portrait' | 'landscape') => void): void {
    // 具体实现需要根据项目需求
    Logger.info('Orientation change callback registered');
  }

  // 打印当前响应式信息（调试用）
  static logResponsiveInfo(): void {
    Logger.info(`Device Type: ${ResponsiveUtil.getDeviceType()}`);
    Logger.info(`Breakpoint: ${ResponsiveUtil.getBreakpoint()}`);
    Logger.info(`Screen Width: ${DeviceUtil.getScreenWidth()}`);
    Logger.info(`Grid Columns: ${ResponsiveUtil.getGridCols()}`);
    Logger.info(`Spacing: ${ResponsiveUtil.getSpacing()}`);
    Logger.info(`Font Size: ${ResponsiveUtil.getFontSize()}`);
  }
}
