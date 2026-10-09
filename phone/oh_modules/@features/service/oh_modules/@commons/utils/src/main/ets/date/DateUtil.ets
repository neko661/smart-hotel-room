/**
 * 日期工具类
 */
export class DateUtil {
  // 格式常量
  static readonly FORMAT_DATETIME = 'yyyy-MM-dd HH:mm:ss';
  static readonly FORMAT_DATE = 'yyyy-MM-dd';
  static readonly FORMAT_TIME = 'HH:mm:ss';
  static readonly FORMAT_MONTH = 'yyyy-MM';
  static readonly FORMAT_YEAR = 'yyyy';

  // 一天的毫秒数
  static readonly DAY_MS = 24 * 60 * 60 * 1000;
  static readonly HOUR_MS = 60 * 60 * 1000;
  static readonly MINUTE_MS = 60 * 1000;

  // 格式化日期
  static format(date: Date, format: string = DateUtil.FORMAT_DATETIME): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    const milliseconds = String(date.getMilliseconds()).padStart(3, '0');

    return format
      .replace('yyyy', String(year))
      .replace('yy', String(year).slice(-2))
      .replace('MM', month)
      .replace('dd', day)
      .replace('HH', hours)
      .replace('mm', minutes)
      .replace('ss', seconds)
      .replace('SSS', milliseconds);
  }

  // 解析日期字符串
  static parse(dateStr: string, format: string = DateUtil.FORMAT_DATETIME): Date | null {
    try {
      const regexMap: Record<string, string> = {
        'yyyy': '(\\d{4})',
        'MM': '(\\d{2})',
        'dd': '(\\d{2})',
        'HH': '(\\d{2})',
        'mm': '(\\d{2})',
        'ss': '(\\d{2})'
      };

      let regex = format;
      let fieldOrder: string[] = [];

      Object.keys(regexMap).forEach(key => {
        if (format.includes(key)) {
          regex = regex.replace(new RegExp(key, 'g'), regexMap[key]);
          fieldOrder.push(key);
        }
      });

      const match = dateStr.match(new RegExp(regex));
      if (!match) return null;

      const values: Record<string, number> = {};
      fieldOrder.forEach((key, index) => {
        values[key] = parseInt(match[index + 1]);
      });

      return new Date(
        values.yyyy || new Date().getFullYear(),
        (values.MM || 1) - 1,
        values.dd || 1,
        values.HH || 0,
        values.mm || 0,
        values.ss || 0
      );
    } catch (e) {
      return null;
    }
  }

  // 获取时间戳
  static timestamp(date?: Date): number {
    return (date || new Date()).getTime();
  }

  // 时间戳转日期
  static fromTimestamp(timestamp: number): Date {
    return new Date(timestamp);
  }

  // 相对时间（如：刚刚、5分钟前）
  static relativeTime(date: Date): string {
    const now = new Date();
    const diff = Math.floor((now.getTime() - date.getTime()) / 1000);

    if (diff < 60) {
      return '刚刚';
    } else if (diff < 3600) {
      return `${Math.floor(diff / 60)}分钟前`;
    } else if (diff < 86400) {
      return `${Math.floor(diff / 3600)}小时前`;
    } else if (diff < 2592000) {
      return `${Math.floor(diff / 86400)}天前`;
    } else if (diff < 31536000) {
      return `${Math.floor(diff / 2592000)}个月前`;
    } else {
      return `${Math.floor(diff / 31536000)}年前`;
    }
  }

  // 日期加减
  static add(date: Date, amount: number, unit: 'day' | 'hour' | 'minute' | 'second' | 'month' | 'year'): Date {
    const result = new Date(date.getTime());
    switch (unit) {
      case 'day':
        result.setDate(result.getDate() + amount);
        break;
      case 'hour':
        result.setHours(result.getHours() + amount);
        break;
      case 'minute':
        result.setMinutes(result.getMinutes() + amount);
        break;
      case 'second':
        result.setSeconds(result.getSeconds() + amount);
        break;
      case 'month':
        result.setMonth(result.getMonth() + amount);
        break;
      case 'year':
        result.setFullYear(result.getFullYear() + amount);
        break;
    }
    return result;
  }

  // 日期差值（天数）
  static diffDays(date1: Date, date2: Date): number {
    return Math.floor((date1.getTime() - date2.getTime()) / DateUtil.DAY_MS);
  }

  // 日期差值（小时）
  static diffHours(date1: Date, date2: Date): number {
    return Math.floor((date1.getTime() - date2.getTime()) / DateUtil.HOUR_MS);
  }

  // 判断是否为同一天
  static isSameDay(date1: Date, date2: Date): boolean {
    return date1.getFullYear() === date2.getFullYear() &&
      date1.getMonth() === date2.getMonth() &&
      date1.getDate() === date2.getDate();
  }

  // 判断是否为今天
  static isToday(date: Date): boolean {
    return DateUtil.isSameDay(date, new Date());
  }

  // 判断是否为昨天
  static isYesterday(date: Date): boolean {
    const yesterday = DateUtil.add(new Date(), -1, 'day');
    return DateUtil.isSameDay(date, yesterday);
  }

  // 获取一天的开始时间
  static startOfDay(date: Date): Date {
    const result = new Date(date);
    result.setHours(0, 0, 0, 0);
    return result;
  }

  // 获取一天的结束时间
  static endOfDay(date: Date): Date {
    const result = new Date(date);
    result.setHours(23, 59, 59, 999);
    return result;
  }

  // 获取本周开始时间（周一）
  static startOfWeek(date: Date): Date {
    const result = new Date(date);
    const day = result.getDay();
    const diff = day === 0 ? 6 : day - 1;
    result.setDate(result.getDate() - diff);
    result.setHours(0, 0, 0, 0);
    return result;
  }

  // 获取本月开始时间
  static startOfMonth(date: Date): Date {
    const result = new Date(date);
    result.setDate(1);
    result.setHours(0, 0, 0, 0);
    return result;
  }

  // 获取本年开始时间
  static startOfYear(date: Date): Date {
    const result = new Date(date);
    result.setMonth(0, 1);
    result.setHours(0, 0, 0, 0);
    return result;
  }

  // 获取星期几
  static getWeekDay(date: Date): string {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[date.getDay()];
  }

  // 获取月份天数
  static getDaysInMonth(date: Date): number {
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const nextMonth = new Date(year, month, 0);
    return nextMonth.getDate();
  }

  // 获取某月的第一天是周几
  static getFirstDayOfMonth(date: Date): number {
    const firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
    return firstDay.getDay();
  }

  // 比较日期大小
  static compare(date1: Date, date2: Date): number {
    return date1.getTime() - date2.getTime();
  }

  // 判断日期范围
  static isBetween(date: Date, startDate: Date, endDate: Date): boolean {
    return date.getTime() >= startDate.getTime() && date.getTime() <= endDate.getTime();
  }

  // 获取年龄
  static getAge(birthDate: Date): number {
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  }

  // 格式化时长（毫秒转可读格式）
  static formatDuration(ms: number): string {
    const seconds = Math.floor(ms / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) {
      return `${days}天${hours % 24}小时`;
    } else if (hours > 0) {
      return `${hours}小时${minutes % 60}分`;
    } else if (minutes > 0) {
      return `${minutes}分${seconds % 60}秒`;
    } else {
      return `${seconds}秒`;
    }
  }
}
