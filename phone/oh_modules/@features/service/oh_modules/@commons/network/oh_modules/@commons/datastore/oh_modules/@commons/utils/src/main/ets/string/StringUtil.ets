/**
 * 字符串工具类
 */
export class StringUtil {
  // 首字母大写
  static capitalize(str: string): string {
    if (StringUtil.isEmpty(str)) return str;
    return str.charAt(0).toUpperCase() + str.slice(1);
  }

  // 首字母小写
  static decapitalize(str: string): string {
    if (StringUtil.isEmpty(str)) return str;
    return str.charAt(0).toLowerCase() + str.slice(1);
  }

  // 全部大写
  static upper(str: string): string {
    return str.toUpperCase();
  }

  // 全部小写
  static lower(str: string): string {
    return str.toLowerCase();
  }

  // 驼峰转下划线
  static camelToSnake(str: string): string {
    return str.replace(/([A-Z])/g, '_$1').toLowerCase();
  }

  // 下划线转驼峰
  static snakeToCamel(str: string): string {
    return str.replace(/_([a-z])/g, (_match: string, letter: string): string => letter.toUpperCase());
  }

  // 转换为帕斯卡命名
  static toPascalCase(str: string): string {
    return str.split(/[-_\s]/)
      .filter((word: string) => word.length > 0)
      .map((word: string) => StringUtil.capitalize(word.toLowerCase()))
      .join('');
  }

  // 转换为连字符命名
  static toKebabCase(str: string): string {
    return str
      .replace(/([a-z])([A-Z])/g, '$1-$2')
      .replace(/[\s_]+/g, '-')
      .toLowerCase();
  }

  // 截断字符串
  static truncate(str: string, maxLength: number, suffix: string = '...'): string {
    if (StringUtil.isEmpty(str) || str.length <= maxLength) {
      return str;
    }
    return str.substring(0, maxLength - suffix.length) + suffix;
  }

  // 随机字符串
  static random(length: number = 8, charset?: string): string {
    const chars = charset || 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  // 随机数字字符串
  static randomNumeric(length: number = 6): string {
    return StringUtil.random(length, '0123456789');
  }

  // 判断是否为空字符串
  static isEmpty(str: string | null | undefined): boolean {
    return str === null || str === undefined || str.trim().length === 0;
  }

  // 判断是否不为空
  static isNotEmpty(str: string | null | undefined): boolean {
    return !StringUtil.isEmpty(str);
  }

  // 去除首尾空白
  static trim(str: string): string {
    return str ? str.trim() : str;
  }

  // 去除所有空白
  static trimAll(str: string): string {
    return str ? str.replace(/\s+/g, '') : str;
  }

  // 左侧填充
  static padStart(str: string, targetLength: number, padString: string = '0'): string {
    return str.padStart(targetLength, padString);
  }

  // 右侧填充
  static padEnd(str: string, targetLength: number, padString: string = '0'): string {
    return str.padEnd(targetLength, padString);
  }

  // 反转字符串
  static reverse(str: string): string {
    return str.split('').reverse().join('');
  }

  // 获取字符数（中文算2个字符）
  static getCharLength(str: string): number {
    let len = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      if (char >= 0x4e00 && char <= 0x9fa5) {
        len += 2;
      } else {
        len += 1;
      }
    }
    return len;
  }

  // 字节数组转字符串
  static bytesToString(bytes: ArrayBuffer): string {
    const decoder = new TextDecoder('utf-8');
    return decoder.decode(bytes);
  }

  // 字符串转字节数组
  static stringToBytes(str: string): Uint8Array {
    const encoder = new TextEncoder();
    return encoder.encodeInto(str);
  }

  // Base64编码
  static toBase64(str: string): string {
    return btoa(str);
  }

  // Base64解码
  static fromBase64(base64: string): string {
    return atob(base64);
  }

  // URL编码
  static encodeURL(str: string): string {
    return encodeURIComponent(str);
  }

  // URL解码
  static decodeURL(str: string): string {
    return decodeURIComponent(str);
  }

  // 模板字符串替换
  static template(templateStr: string, data: Record<string, string>): string {
    return templateStr.replace(/\{(\w+)\}/g, (_match: string, key: string): string => data[key] || '');
  }

  // 高级模板替换（支持嵌套和条件）
  static advancedTemplate(templateStr: string, data: Record<string, any>): string {
    return templateStr.replace(/\{\{([^}]+)\}\}/g, (_match: string, key: string): string => {
      const keys = key.split('.');
      let value: any = data;
      for (const k of keys) {
        value = value?.[k];
      }
      return value ?? '';
    });
  }

  // 高亮关键词
  static highlight(str: string, keyword: string, className: string = 'highlight'): string {
    if (StringUtil.isEmpty(keyword)) return str;
    const regex = new RegExp(`(${keyword})`, 'gi');
    return str.replace(regex, `<span class="${className}">$1</span>`);
  }

  // 计算字符串相似度（Levenshtein距离）
  static similarity(str1: string, str2: string): number {
    const len1 = str1.length;
    const len2 = str2.length;
    const matrix: number[][] = [];

    for (let i = 0; i <= len1; i++) {
      matrix[i] = [i];
    }
    for (let j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (let i = 1; i <= len1; i++) {
      for (let j = 1; j <= len2; j++) {
        const cost = str1.charAt(i - 1) === str2.charAt(j - 1) ? 0 : 1;
        matrix[i][j] = Math.min(
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        );
      }
    }

    const maxLen = Math.max(len1, len2);
    return maxLen === 0 ? 1 : (maxLen - matrix[len1][len2]) / maxLen;
  }

  // 生成UUID
  static uuid(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  // 生成短ID
  static shortId(length: number = 8): string {
    return StringUtil.random(length, '0123456789abcdef');
  }

  // 手机号脱敏
  static maskPhone(phone: string): string {
    if (StringUtil.isEmpty(phone) || phone.length < 11) return phone;
    return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
  }

  // 身份证脱敏
  static maskIdCard(idCard: string): string {
    if (StringUtil.isEmpty(idCard) || idCard.length < 18) return idCard;
    return idCard.replace(/(\d{6})\d{8}(\d{4})/, '$1********$2');
  }

  // 姓名脱敏
  static maskName(name: string): string {
    if (StringUtil.isEmpty(name)) return name;
    if (name.length === 2) {
      return name.charAt(0) + '*';
    }
    return name.charAt(0) + '*'.repeat(name.length - 2) + name.charAt(name.length - 1);
  }

  // 邮箱脱敏
  static maskEmail(email: string): string {
    if (StringUtil.isEmpty(email) || !email.includes('@')) return email;
    const [username, domain] = email.split('@');
    if (username.length <= 2) {
      return `${username.charAt(0)}***@${domain}`;
    }
    return `${username.charAt(0)}${'*'.repeat(username.length - 2)}${username.charAt(username.length - 1)}@${domain}`;
  }

  // 分割字符串为数组
  static split(str: string, separator: string | RegExp = ','): string[] {
    return StringUtil.isEmpty(str) ? [] : str.split(separator).filter(s => StringUtil.isNotEmpty(s));
  }

  // 连接数组为字符串
  static join(arr: string[], separator: string = ','): string {
    return arr.join(separator);
  }

  // 统计单词数
  static wordCount(str: string): number {
    return StringUtil.isEmpty(str) ? 0 : str.trim().split(/\s+/).length;
  }

  // 判断是否包含中文
  static hasChinese(str: string): boolean {
    return /[一-龥]/.test(str);
  }

  // 提取中文字符
  static extractChinese(str: string): string {
    return str.replace(/[^一-龥]/g, '');
  }

  // 提取数字
  static extractNumbers(str: string): string {
    return str.replace(/\D/g, '');
  }

  // 格式化金额（千分位）
  static formatMoney(amount: number | string, decimals: number = 2): string {
    const num = typeof amount === 'string' ? parseFloat(amount) : amount;
    return num.toFixed(decimals).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  }

  // 隐藏银行卡号
  static maskBankCard(cardNo: string): string {
    if (StringUtil.isEmpty(cardNo) || cardNo.length < 16) return cardNo;
    return cardNo.replace(/(\d{4})\d+(\d{4})/, '$1 **** **** $2');
  }
}
