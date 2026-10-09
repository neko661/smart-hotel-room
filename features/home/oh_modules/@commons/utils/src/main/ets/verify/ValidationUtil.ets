/**
 * 验证工具类
 */
export class ValidationUtil {
  // 验证手机号
  static isValidPhone(phone: string): boolean {
    const phoneReg = /^1[3-9]\d{9}$/;
    return phoneReg.test(phone);
  }

  // 验证邮箱
  static isValidEmail(email: string): boolean {
    const emailReg = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailReg.test(email);
  }

  // 验证身份证号
  static isValidIdCard(idCard: string): boolean {
    const idCardReg = /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/;
    if (!idCardReg.test(idCard)) {
      return false;
    }
    // 18位身份证校验
    if (idCard.length === 18) {
      const weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
      const checkCodes = ['1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2'];
      let sum = 0;
      for (let i = 0; i < 17; i++) {
        sum += parseInt(idCard.charAt(i)) * weights[i];
      }
      return idCard.charAt(17).toUpperCase() === checkCodes[sum % 11];
    }
    return true;
  }

  // 验证URL
  static isValidUrl(url: string): boolean {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  }

  // 验证密码强度（至少8位，包含字母和数字）
  static isValidPassword(password: string): boolean {
    const passwordReg = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/;
    return passwordReg.test(password);
  }

  // 验证强密码（至少8位，包含大小写字母、数字和特殊字符）
  static isStrongPassword(password: string): boolean {
    const passwordReg = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$/;
    return passwordReg.test(password);
  }

  // 获取密码强度等级
  static getPasswordStrength(password: string): number {
    let strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (/[a-z]/.test(password)) strength++;
    if (/[A-Z]/.test(password)) strength++;
    if (/\d/.test(password)) strength++;
    if (/[@$!%*?&#]/.test(password)) strength++;
    return Math.min(strength, 5);
  }

  // 验证中文姓名
  static isValidChineseName(name: string): boolean {
    const nameReg = /^[一-龥]{2,20}$/;
    return nameReg.test(name);
  }

  // 验证数字
  static isNumber(value: string): boolean {
    return !isNaN(Number(value));
  }

  // 验证正整数
  static isPositiveInteger(value: string): boolean {
    const reg = /^[1-9]\d*$/;
    return reg.test(value);
  }

  // 验证非负整数
  static isNonNegativeInteger(value: string): boolean {
    const reg = /^(0|[1-9]\d*)$/;
    return reg.test(value);
  }

  // 验证金额
  static isAmount(value: string): boolean {
    const reg = /^(0|[1-9]\d*)(\.\d{1,2})?$/;
    return reg.test(value);
  }

  // 验证非空
  static isNotEmpty(value: string): boolean {
    return value !== null && value !== undefined && value.trim().length > 0;
  }

  // 验证为空
  static isEmpty(value: string | null | undefined): boolean {
    return value === null || value === undefined || value.trim().length === 0;
  }

  // 验证长度范围
  static isLengthInRange(value: string, min: number, max: number): boolean {
    return value.length >= min && value.length <= max;
  }

  // 验证IP地址（IPv4）
  static isValidIPv4(ip: string): boolean {
    const ipReg = /^(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)\.(25[0-5]|2[0-4]\d|[01]?\d\d?)$/;
    return ipReg.test(ip);
  }

  // 验证IPv6地址
  static isValidIPv6(ip: string): boolean {
    const ipReg = /^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]+|::(ffff(:0{1,4})?:)?((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1?[0-9])?[0-9])\.){3}(25[0-5]|(2[0-4]|1?[0-9])?[0-9]))$/;
    return ipReg.test(ip);
  }

  // 验证MAC地址
  static isValidMacAddress(mac: string): boolean {
    const macReg = /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/;
    return macReg.test(mac);
  }

  // 验证车牌号
  static isValidLicensePlate(plate: string): boolean {
    // 新能源车牌
    const newEnergyReg = /^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z][A-Z0-9]{5}[A-Z0-9]$/;
    // 普通车牌
    const normalReg = /^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领][A-Z][A-Z0-9]{5}$/;
    return newEnergyReg.test(plate) || normalReg.test(plate);
  }

  // 验证邮政编码
  static isValidPostalCode(code: string): boolean {
    const codeReg = /^\d{6}$/;
    return codeReg.test(code);
  }

  // 验证QQ号
  static isValidQQ(qq: string): boolean {
    const qqReg = /^[1-9][0-9]{4,10}$/;
    return qqReg.test(qq);
  }

  // 验证微信号
  static isValidWeChat(wechat: string): boolean {
    const wechatReg = /^[a-zA-Z][-_a-zA-Z0-9]{5,19}$/;
    return wechatReg.test(wechat);
  }

  // 验证银行卡号
  static isValidBankCard(card: string): boolean {
    const cardReg = /^\d{16,19}$/;
    if (!cardReg.test(card)) {
      return false;
    }
    // Luhn算法验证
    let sum = 0;
    let isEven = false;
    for (let i = card.length - 1; i >= 0; i--) {
      let digit = parseInt(card.charAt(i));
      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      sum += digit;
      isEven = !isEven;
    }
    return sum % 10 === 0;
  }

  // 验证验证码
  static isValidCode(code: string, length: number = 6): boolean {
    const codeReg = new RegExp(`^\\d{${length}}$`);
    return codeReg.test(code);
  }

  // 验证颜色值（Hex）
  static isValidHexColor(color: string): boolean {
    const colorReg = /^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$/;
    return colorReg.test(color);
  }

  // 验证RGB颜色
  static isValidRGBColor(color: string): boolean {
    const rgbReg = /^rgb\(\s*(\d{1,3}%?)\s*,\s*(\d{1,3}%?)\s*,\s*(\d{1,3}%?)\s*\)$/;
    return rgbReg.test(color);
  }

  // 验证日期格式
  static isValidDate(date: string, format: string = 'yyyy-MM-dd'): boolean {
    const regexMap: Record<string, string> = {
      'yyyy-MM-dd': '^\\d{4}-\\d{2}-\\d{2}$',
      'yyyy/MM/dd': '^\\d{4}/\\d{2}/\\d{2}$',
      'yyyy-MM-dd HH:mm:ss': '^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}$'
    };
    const reg = new RegExp(regexMap[format] || regexMap['yyyy-MM-dd']);
    if (!reg.test(date)) {
      return false;
    }
    const d = new Date(date);
    return d instanceof Date && !isNaN(d.getTime());
  }

  // 验证是否包含emoji
  static hasEmoji(str: string): boolean {
    const emojiReg = /[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F1E0}-\u{1F1FF}]/u;
    return emojiReg.test(str);
  }

  // 验证是否全是中文
  static isAllChinese(str: string): boolean {
    const reg = /^[一-龥]+$/;
    return reg.test(str);
  }

  // 验证是否全是英文
  static isAllEnglish(str: string): boolean {
    const reg = /^[a-zA-Z]+$/;
    return reg.test(str);
  }

  // 验证端口范围
  static isValidPort(port: string): boolean {
    const num = parseInt(port);
    return !isNaN(num) && num >= 1 && num <= 65535;
  }
}
