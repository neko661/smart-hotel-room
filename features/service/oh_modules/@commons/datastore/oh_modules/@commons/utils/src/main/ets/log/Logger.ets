import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 日志管理器
 */
export class Logger {
  private static TAG: string = 'MyApp';
  private static domain: number = 0x0000;
  private static minLevel: LogLevel = LogLevel.DEBUG;
  private static isProduction: boolean = false;

  // 设置TAG
  static setTag(tag: string): void {
    Logger.TAG = tag;
  }

  // 设置日志域
  static setDomain(domain: number): void {
    Logger.domain = domain;
  }

  // 设置最小日志级别
  static setMinLevel(level: LogLevel): void {
    Logger.minLevel = level;
  }

  // 设置生产环境（关闭DEBUG日志）
  static setProduction(isProduction: boolean): void {
    Logger.isProduction = isProduction;
    if (isProduction) {
      Logger.minLevel = LogLevel.INFO;
    }
  }

  // 格式化日志消息
  private static formatMessage(message: string, ...args: Object[]): string {
    if (args.length === 0) {
      return message;
    }
    try {
      return message + ' ' + JSON.stringify(args);
    } catch (e) {
      return message + ' ' + String(args);
    }
  }

  // 检查是否应该输出日志
  private static shouldLog(level: LogLevel): boolean {
    return level >= Logger.minLevel;
  }

  // Debug日志
  static debug(message: string, ...args: Object[]): void {
    if (Logger.shouldLog(LogLevel.DEBUG)) {
      hilog.debug(Logger.domain, Logger.TAG, Logger.formatMessage(message, ...args));
    }
  }

  // Info日志
  static info(message: string, ...args: Object[]): void {
    if (Logger.shouldLog(LogLevel.INFO)) {
      hilog.info(Logger.domain, Logger.TAG, Logger.formatMessage(message, ...args));
    }
  }

  // Warn日志
  static warn(message: string, ...args: Object[]): void {
    if (Logger.shouldLog(LogLevel.WARN)) {
      hilog.warn(Logger.domain, Logger.TAG, Logger.formatMessage(message, ...args));
    }
  }

  // Error日志
  static error(message: string, ...args: Object[]): void {
    if (Logger.shouldLog(LogLevel.ERROR)) {
      hilog.error(Logger.domain, Logger.TAG, Logger.formatMessage(message, ...args));
    }
  }

  // Fatal日志
  static fatal(message: string, ...args: Object[]): void {
    if (Logger.shouldLog(LogLevel.FATAL)) {
      hilog.fatal(Logger.domain, Logger.TAG, Logger.formatMessage(message, ...args));
    }
  }

  // 分隔线
  static separator(char: string = '-', repeat: number = 50): void {
    const line = char.repeat(repeat);
    Logger.info(line);
  }

  // 对象日志
  static object(obj: Object, label: string = 'Object'): void {
    try {
      Logger.info(`${label}: ${JSON.stringify(obj)}`);
    } catch (e) {
      Logger.error(`${label}: [Failed to stringify]`);
    }
  }

  // 性能日志开始
  static startTrace(label: string): number {
    const startTime = Date.now();
    Logger.debug(`[TRACE] START: ${label}`);
    return startTime;
  }

  // 性能日志结束
  static endTrace(label: string, startTime: number): void {
    const duration = Date.now() - startTime;
    Logger.info(`[TRACE] END: ${label} (${duration}ms)`);
  }
}

// 日志级别枚举
export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
  FATAL = 4
}
